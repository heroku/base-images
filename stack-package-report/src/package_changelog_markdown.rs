//! Markdown rendering of the package changes between two sets of stack
//! package snapshots.

use std::collections::BTreeMap;

use crate::arch_normalize::normalize_arch_in_package_name;
use crate::package_changes::{PackageChange, determine_package_changes, difference};
use crate::stack_package_list::StackPackageListCollection;
use crate::stack_package_list_id::StackVariant;

pub(crate) fn render_package_changelog_markdown(
    previous_stack_packages: &StackPackageListCollection,
    current_stack_packages: &StackPackageListCollection,
) -> String {
    let mut result = String::new();
    result.push_str("## Changelog of packages\n\n");

    let mut stack_names = previous_stack_packages.stack_names();
    stack_names.extend(current_stack_packages.stack_names());

    for stack_name in stack_names {
        let base_package_changes = determine_package_changes(
            &previous_stack_packages.packages_for_variant(&stack_name, StackVariant::Base),
            &current_stack_packages.packages_for_variant(&stack_name, StackVariant::Base),
        );

        let build_package_changes = determine_package_changes(
            &previous_stack_packages.packages_for_variant(&stack_name, StackVariant::Build),
            &current_stack_packages.packages_for_variant(&stack_name, StackVariant::Build),
        );

        let unique_build_package_changes =
            difference(&build_package_changes, &base_package_changes);

        result.push_str(&format!("### Stack: {stack_name}\n\n"));
        result.push_str(&render_changes_as_bullet_list(&base_package_changes));
        result.push('\n');

        if !unique_build_package_changes.is_empty() {
            result.push_str("#### Updates to packages available at build time only\n\n");
            result.push_str(&render_changes_as_bullet_list(
                &unique_build_package_changes,
            ));
        }
    }

    result
}

fn render_changes_as_bullet_list(package_changes: &BTreeMap<String, PackageChange>) -> String {
    group_by_normalized_key(package_changes, |package_name| {
        normalize_arch_in_package_name(package_name)
    })
        .map(|(package_names, package_change)| {
            let combined_package_names = package_names
                .into_iter()
                .map(|package_name| format!("`{package_name}`"))
                .collect::<Vec<_>>()
                .join("/");

            match package_change {
                PackageChange::Added { version } => {
                    format!("- Added {combined_package_names} version `{version}`\n")
                }
                PackageChange::Removed { .. } => format!("- Removed {combined_package_names}\n"),
                PackageChange::Updated {
                    previous_version,
                    current_version,
                } => format!(
                    "- Updated {combined_package_names} from version `{previous_version}` to `{current_version}`\n"
                ),
            }
        })
        .collect()
}

fn group_by_normalized_key<K: Clone + Ord, V: Clone + Ord>(
    entries: &BTreeMap<K, V>,
    normalizer: impl Fn(&K) -> K,
) -> impl Iterator<Item = (Vec<K>, V)> {
    let mut groups: BTreeMap<(K, V), Vec<K>> = BTreeMap::new();

    for (key, value) in entries {
        let normalized_key = normalizer(key);

        groups
            .entry((normalized_key, value.clone()))
            .or_default()
            .push(key.clone());
    }

    groups.into_iter().map(|((_, value), keys)| (keys, value))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::stack_package_list::StackPackageList;
    use crate::stack_package_list_id::{Architecture, Stack, StackPackageListId};
    use indoc::indoc;

    #[test]
    #[allow(clippy::too_many_lines)]
    fn render_package_changelog_markdown_covers_all_features() {
        let previous_stack_packages = vec![
            build_stack_packages(
                "heroku-24",
                StackVariant::Base,
                Architecture::Amd64,
                &[
                    ("bash", "5.1"),
                    ("libfoo", "1.0"),
                    ("old-pkg", "2.0"),
                    ("binutils-x86-64-linux-gnu", "2.38"),
                    ("libthing-x86-64-linux-gnu", "1.0"),
                    ("helper-x86-64-linux-gnu", "0.9"),
                ],
            ),
            build_stack_packages(
                "heroku-24",
                StackVariant::Base,
                Architecture::Arm64,
                &[
                    ("bash", "5.1"),
                    ("libfoo", "1.0"),
                    ("old-pkg", "2.0"),
                    ("binutils-aarch64-linux-gnu", "2.38"),
                    ("libthing-aarch64-linux-gnu", "1.0"),
                ],
            ),
            build_stack_packages(
                "heroku-24",
                StackVariant::Build,
                Architecture::Amd64,
                &[
                    ("bash", "5.1"),
                    ("libfoo", "1.0"),
                    ("old-pkg", "2.0"),
                    ("binutils-x86-64-linux-gnu", "2.38"),
                    ("libthing-x86-64-linux-gnu", "1.0"),
                    ("helper-x86-64-linux-gnu", "0.9"),
                    ("make", "4.3"),
                ],
            ),
            build_stack_packages(
                "heroku-24",
                StackVariant::Build,
                Architecture::Arm64,
                &[
                    ("bash", "5.1"),
                    ("libfoo", "1.0"),
                    ("old-pkg", "2.0"),
                    ("binutils-aarch64-linux-gnu", "2.38"),
                    ("libthing-aarch64-linux-gnu", "1.0"),
                    ("make", "4.3"),
                ],
            ),
        ];

        let current_stack_packages = vec![
            build_stack_packages(
                "heroku-24",
                StackVariant::Base,
                Architecture::Amd64,
                &[
                    ("bash", "5.1"),
                    ("libfoo", "1.1"),
                    ("new-pkg", "3.0"),
                    ("binutils-x86-64-linux-gnu", "2.39"),
                    ("libthing-x86-64-linux-gnu", "1.1"),
                    ("helper-x86-64-linux-gnu", "1.0"),
                    ("intel-only-x86-64-linux-gnu", "0.1"),
                ],
            ),
            build_stack_packages(
                "heroku-24",
                StackVariant::Base,
                Architecture::Arm64,
                &[
                    ("bash", "5.1"),
                    ("libfoo", "1.1"),
                    ("new-pkg", "3.0"),
                    ("binutils-aarch64-linux-gnu", "2.39"),
                    ("libthing-aarch64-linux-gnu", "1.2"),
                    ("helper-aarch64-linux-gnu", "1.0"),
                ],
            ),
            build_stack_packages(
                "heroku-24",
                StackVariant::Build,
                Architecture::Amd64,
                &[
                    ("bash", "5.1"),
                    ("libfoo", "1.1"),
                    ("new-pkg", "3.0"),
                    ("binutils-x86-64-linux-gnu", "2.39"),
                    ("libthing-x86-64-linux-gnu", "1.1"),
                    ("helper-x86-64-linux-gnu", "1.0"),
                    ("intel-only-x86-64-linux-gnu", "0.1"),
                    ("make", "4.4"),
                ],
            ),
            build_stack_packages(
                "heroku-24",
                StackVariant::Build,
                Architecture::Arm64,
                &[
                    ("bash", "5.1"),
                    ("libfoo", "1.1"),
                    ("new-pkg", "3.0"),
                    ("binutils-aarch64-linux-gnu", "2.39"),
                    ("libthing-aarch64-linux-gnu", "1.2"),
                    ("helper-aarch64-linux-gnu", "1.0"),
                    ("make", "4.4"),
                ],
            ),
        ];
        let expected = indoc! {"
            ## Changelog of packages

            ### Stack: heroku-24

            - Updated `binutils-aarch64-linux-gnu`/`binutils-x86-64-linux-gnu` from version `2.38` to `2.39`
            - Added `helper-aarch64-linux-gnu` version `1.0`
            - Updated `helper-x86-64-linux-gnu` from version `0.9` to `1.0`
            - Added `intel-only-x86-64-linux-gnu` version `0.1`
            - Updated `libfoo` from version `1.0` to `1.1`
            - Updated `libthing-x86-64-linux-gnu` from version `1.0` to `1.1`
            - Updated `libthing-aarch64-linux-gnu` from version `1.0` to `1.2`
            - Added `new-pkg` version `3.0`
            - Removed `old-pkg`

            #### Updates to packages available at build time only

            - Updated `make` from version `4.3` to `4.4`
        "};
        assert_eq!(
            render_package_changelog_markdown(
                &StackPackageListCollection(previous_stack_packages),
                &StackPackageListCollection(current_stack_packages),
            ),
            expected
        );
    }

    fn build_stack_packages(
        stack_name: &str,
        stack_variant: StackVariant,
        stack_arch: Architecture,
        packages: &[(&str, &str)],
    ) -> StackPackageList {
        StackPackageList {
            id: StackPackageListId {
                stack: Stack {
                    name: stack_name.to_string(),
                    variant: stack_variant,
                },
                arch: stack_arch,
            },
            packages: packages
                .iter()
                .map(|(package_name, package_version)| {
                    (package_name.to_string(), package_version.to_string())
                })
                .collect(),
        }
    }
}
