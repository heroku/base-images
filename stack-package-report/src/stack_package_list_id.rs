//! Types that identify a package list by stack, variant, and architecture,
//! along with conversion to and from the on-disk TSV filename.

use thiserror::Error;

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct StackPackageListId {
    pub(crate) stack: Stack,
    pub(crate) arch: Architecture,
}

#[derive(Clone, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub(crate) struct Stack {
    pub(crate) name: String,
    pub(crate) variant: StackVariant,
}

#[derive(Copy, Clone, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub(crate) enum StackVariant {
    Base,
    Build,
}

#[derive(Copy, Clone, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub(crate) enum Architecture {
    Amd64,
    Arm64,
}

impl StackPackageListId {
    #[allow(unused)]
    pub(crate) fn to_file_name(&self) -> String {
        let stack_name = &self.stack.name;

        let stack_variant_suffix = match self.stack.variant {
            StackVariant::Base => "",
            StackVariant::Build => "-build",
        };

        let arch = match self.arch {
            Architecture::Amd64 => "amd64",
            Architecture::Arm64 => "arm64",
        };

        format!("{stack_name}{stack_variant_suffix}_linux-{arch}-packages.tsv")
    }

    pub(crate) fn from_file_name(filename: &str) -> Result<Self, FromFilenameError> {
        let body = filename
            .strip_suffix("-packages.tsv")
            .ok_or(FromFilenameError)?;

        let (stack_segment, arch_str) = body.rsplit_once("_linux-").ok_or(FromFilenameError)?;

        let arch = match arch_str {
            "amd64" => Architecture::Amd64,
            "arm64" => Architecture::Arm64,
            _ => return Err(FromFilenameError),
        };

        let (stack_name, variant) = match stack_segment.strip_suffix("-build") {
            Some(name) => (name, StackVariant::Build),
            None => (stack_segment, StackVariant::Base),
        };

        if stack_name.is_empty() {
            return Err(FromFilenameError);
        }

        Ok(StackPackageListId {
            stack: Stack {
                name: stack_name.to_string(),
                variant,
            },
            arch,
        })
    }
}

#[derive(Debug, Eq, Error, PartialEq)]
#[error("filename does not match expected pattern")]
pub(crate) struct FromFilenameError;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn file_name_serialization_is_isomorphic() {
        for name in &[
            "heroku-22_linux-amd64-packages.tsv",
            "heroku-22-build_linux-amd64-packages.tsv",
            "heroku-24_linux-arm64-packages.tsv",
            "heroku-26-build_linux-amd64-packages.tsv",
        ] {
            let parsed = StackPackageListId::from_file_name(name).unwrap();
            assert_eq!(&parsed.to_file_name(), name);
        }
    }

    #[test]
    fn from_file_name_recognizes_base_variant() {
        assert_eq!(
            StackPackageListId::from_file_name("heroku-24_linux-amd64-packages.tsv"),
            Ok(StackPackageListId {
                stack: Stack {
                    name: String::from("heroku-24"),
                    variant: StackVariant::Base,
                },
                arch: Architecture::Amd64,
            })
        );
    }

    #[test]
    fn from_file_name_recognizes_build_variant() {
        assert_eq!(
            StackPackageListId::from_file_name("heroku-26-build_linux-amd64-packages.tsv"),
            Ok(StackPackageListId {
                stack: Stack {
                    name: String::from("heroku-26"),
                    variant: StackVariant::Build,
                },
                arch: Architecture::Amd64,
            })
        );
    }

    #[test]
    fn from_file_name_recognizes_arm64() {
        assert_eq!(
            StackPackageListId::from_file_name("heroku-24_linux-arm64-packages.tsv"),
            Ok(StackPackageListId {
                stack: Stack {
                    name: String::from("heroku-24"),
                    variant: StackVariant::Base,
                },
                arch: Architecture::Arm64,
            })
        );
    }

    #[test]
    fn from_file_name_rejects_unknown_arch() {
        assert_eq!(
            StackPackageListId::from_file_name("heroku-24_linux-riscv-packages.tsv"),
            Err(FromFilenameError)
        );
    }

    #[test]
    fn from_file_name_rejects_missing_suffix() {
        assert_eq!(
            StackPackageListId::from_file_name("heroku-24_linux-amd64.tsv"),
            Err(FromFilenameError)
        );
    }
}
