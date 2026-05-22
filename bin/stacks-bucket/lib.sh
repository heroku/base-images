# shellcheck shell=bash
# Sourced by stacks-bucket scripts. Not executed directly.

# Output helpers. All write to stderr except `print_ok`, which writes to stdout
# because successful results (e.g. published release paths) are part of the
# command's payload, not progress.
print_err()  { printf '%s\n' "${*}" >&2; }
print_warn() { printf '%s\n' "${*}" >&2; }
print_info() { printf '%s\n' "${*}" >&2; }
print_ok()   { printf '%s\n' "${*}"; }

# Verify the complete setup for the stacks-bucket suite: required env vars
# are set, required tools are installed, AWS auth works against the configured
# bucket, and GPG signing works with the configured key. Prints a helpful
# message and exits non-zero on the first failure.
verify_setup() {
	local required=(MANIFEST_BUCKET GPG_SIGNER GPG_PASSPHRASE IMAGE_DOWNLOAD_URL_PREFIX)
	local missing=()
	for var in "${required[@]}"; do
		if [[ -z "${!var:-}" ]]; then
			missing+=("${var}")
		fi
	done
	if [[ "${#missing[@]}" -gt 0 ]]; then
		print_err "Missing required environment variables: ${missing[*]}"
		cat >&2 <<-EOF

			Set them in your shell before running this command:

			  export MANIFEST_BUCKET=<bucket name>
			  export GPG_SIGNER=<key id or email of the signing key>
			  export GPG_PASSPHRASE=<passphrase for that key>
			  export IMAGE_DOWNLOAD_URL_PREFIX=<https url prefix consumers download images from>

			For local testing against your own bucket, use whatever you bootstrapped with.
			In CI, these come from repository secrets.
		EOF
		exit 1
	fi

	local tool
	for tool in aws gpg yq; do
		if ! command -v "${tool}" >/dev/null 2>&1; then
			print_err "Missing required tool: ${tool}"
			print_err "Install it before running this command."
			exit 1
		fi
	done

	if ! aws sts get-caller-identity >/dev/null 2>&1; then
		print_err "AWS credentials are not configured or are invalid."
		cat >&2 <<-EOF

			Configure them with one of:
			  aws configure
			  export AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=...
			  export AWS_PROFILE=<profile-name>
		EOF
		exit 1
	fi

	if ! aws s3api head-bucket --bucket "${MANIFEST_BUCKET}" >/dev/null 2>&1; then
		print_err "Cannot access bucket: ${MANIFEST_BUCKET}"
		print_err "Check the bucket name and that the configured AWS identity has access to it."
		exit 1
	fi

	if ! echo test | gpg --batch --pinentry-mode loopback \
		--passphrase-fd 3 --local-user "${GPG_SIGNER}" \
		--clearsign >/dev/null 2>&1 3< <(printf '%s' "${GPG_PASSPHRASE}"); then
		print_err "GPG signing test failed."
		cat >&2 <<-EOF

			Verify that:
			  - The key for "${GPG_SIGNER}" is in your local keyring (gpg --list-secret-keys).
			  - GPG_PASSPHRASE matches that key.
		EOF
		exit 1
	fi
}

VALID_ENVS=(staging canary production)

# Validate that the given string is a known environment name. Exits non-zero
# with a friendly message otherwise.
validate_deployment_env() {
	local env="${1}" valid
	for valid in "${VALID_ENVS[@]}"; do
		if [[ "${env}" == "${valid}" ]]; then
			return 0
		fi
	done
	print_err "Invalid environment: '${env}'"
	print_err "Valid environments: ${VALID_ENVS[*]}"
	exit 1
}

# Validate that every name in <csv> is present (as `.name`) in the YAML array
# at <yaml-file>. Exits non-zero with a friendly message listing unknowns.
validate_stacks_in() {
	local csv="${1}" yaml="${2}" context="${3}"
	local unknown=()
	mapfile -t known < <(yq -P '.[].name' "${yaml}")

	IFS=',' read -ra requested <<<"${csv}"
	for stack in "${requested[@]}"; do
		stack="${stack// /}"
		if [[ -z "${stack}" ]]; then
			continue
		fi
		local found=0
		for known_stack in "${known[@]}"; do
			if [[ "${stack}" == "${known_stack}" ]]; then
				found=1
				break
			fi
		done
		if [[ "${found}" -eq 0 ]]; then
			unknown+=("${stack}")
		fi
	done

	if [[ "${#unknown[@]}" -eq 0 ]]; then
		return 0
	fi
	print_err "Unknown stacks for ${context}: ${unknown[*]}"
	print_err "Known stacks: $(IFS=,; echo "${known[*]}")"
	exit 1
}

get_live_manifest_path() {
	case "${1}" in
		staging)    echo "manifest-staging.yml" ;;
		canary)     echo "manifest-canary.yml" ;;
		production) echo "manifest.yml" ;;
		*)
			print_err "Unknown env: ${1}"
			return 1
			;;
	esac
}

get_release_prefix() {
	case "${1}" in
		staging|canary|production) echo "releases/${1}/" ;;
		*)
			print_err "Unknown env: ${1}"
			return 1
			;;
	esac
}

generate_release_manifest_path() {
	local env="${1}"
	printf '%s%s.yml.signed' "$(get_release_prefix "${env}")" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}

build_s3_uri() {
	echo "s3://${MANIFEST_BUCKET}/${1}"
}

# Download a manifest, verify its signature, and write the cleartext YAML.
fetch_manifest() {
	local env="${1}" output_file="${2}"
	local signed_manifest_path
	signed_manifest_path="$(get_live_manifest_path "${env}").signed"

	aws s3 cp "$(build_s3_uri "${signed_manifest_path}")" - | gpg --decrypt --no-tty >"${output_file}"

	if [[ ! -s "${output_file}" ]]; then
		print_err "Empty manifest for ${env}"
		return 1
	fi
}

# Sign the given manifest and publish it as a new release for the given env.
# Writes three S3 objects:
#   - releases/<env>/<ts>.yml.signed  (new, immutable historical copy)
#   - manifest-<env>.yml.signed       (overwrites the live signed manifest consumers fetch)
#   - manifest-<env>.yml              (overwrites the live unsigned copy)
publish_signed_manifest() {
	local env="${1}" manifest_file="${2}"
	local released_manifest_path live_manifest_path signed_manifest_file

	released_manifest_path="$(generate_release_manifest_path "${env}")"
	live_manifest_path="$(get_live_manifest_path "${env}")"
	signed_manifest_file="$(mktemp)"

	printf '%s' "${GPG_PASSPHRASE}" \
		| gpg --batch --yes --pinentry-mode loopback --passphrase-fd 0 \
			--local-user "${GPG_SIGNER}" --clearsign --output "${signed_manifest_file}" "${manifest_file}"

	aws s3 cp "${signed_manifest_file}" "$(build_s3_uri "${released_manifest_path}")" \
		--content-type text/plain >/dev/null

	aws s3 cp "${signed_manifest_file}" "$(build_s3_uri "${live_manifest_path}.signed")" \
		--content-type text/plain >/dev/null
	aws s3 cp "${manifest_file}" "$(build_s3_uri "${live_manifest_path}")" \
		--content-type text/plain >/dev/null

	rm -f "${signed_manifest_file}"
	print_ok "Published ${released_manifest_path}"
}
