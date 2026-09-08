//! Collapses architecture-specific package name infixes
//! (e.g. `binutils-x86-64-linux-gnu` → `binutils-${arch}-linux-gnu`).

const ARCH_PLACEHOLDER: &str = "-${arch}-";
const ARCH_AARCH64_INFIX: &str = "-aarch64-";
const ARCH_AMD64_INFIX: &str = "-x86-64-";

pub(crate) fn normalize_arch_in_package_name(name: &str) -> String {
    name.replace(ARCH_AMD64_INFIX, ARCH_PLACEHOLDER)
        .replace(ARCH_AARCH64_INFIX, ARCH_PLACEHOLDER)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn normalize_replaces_amd64_infix() {
        assert_eq!(
            normalize_arch_in_package_name("binutils-x86-64-linux-gnu"),
            "binutils-${arch}-linux-gnu"
        );
    }

    #[test]
    fn normalize_replaces_aarch64_infix() {
        assert_eq!(
            normalize_arch_in_package_name("binutils-aarch64-linux-gnu"),
            "binutils-${arch}-linux-gnu"
        );
    }

    #[test]
    fn normalize_leaves_unsuffixed_names_unchanged() {
        assert_eq!(normalize_arch_in_package_name("bash"), "bash");
        assert_eq!(normalize_arch_in_package_name("libfoo"), "libfoo");
    }
}
