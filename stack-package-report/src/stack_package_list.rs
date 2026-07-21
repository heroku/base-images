//! The contents of a single package list, a collection of those lists,
//! and the routine that loads them from disk.

use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::io;
use std::path::Path;

use thiserror::Error;

use crate::stack_package_list_id::{FromFilenameError, StackPackageListId, StackVariant};
use crate::tsv::{self, TsvParseError, UnexpectedColumnCountError};

#[derive(Debug)]
pub(crate) struct StackPackageList {
    pub(crate) id: StackPackageListId,
    pub(crate) packages: BTreeMap<String, String>,
}

#[derive(Debug)]
pub(crate) struct StackPackageListCollection(pub(crate) Vec<StackPackageList>);

impl StackPackageListCollection {
    #[cfg(test)]
    pub(crate) fn iter(&self) -> impl Iterator<Item = &StackPackageList> {
        self.0.iter()
    }

    pub(crate) fn stack_names(&self) -> BTreeSet<String> {
        self.0
            .iter()
            .map(|list| list.id.stack.name.clone())
            .collect()
    }

    pub(crate) fn package_names_for_stacks(&self, stack_names: &[String]) -> BTreeSet<String> {
        let stack_filter: BTreeSet<&str> = stack_names.iter().map(String::as_str).collect();

        self.0
            .iter()
            .filter(|list| stack_filter.contains(list.id.stack.name.as_str()))
            .flat_map(|list| list.packages.keys().cloned())
            .collect()
    }

    pub(crate) fn version_for_package(
        &self,
        stack_name: &str,
        package_name: &str,
    ) -> Option<(StackVariant, String)> {
        [StackVariant::Base, StackVariant::Build]
            .into_iter()
            .find_map(|variant| {
                self.0
                    .iter()
                    .filter(|list| {
                        list.id.stack.name == stack_name && list.id.stack.variant == variant
                    })
                    .find_map(|list| list.packages.get(package_name).cloned())
                    .map(|version| (variant, version))
            })
    }

    pub(crate) fn packages_for_variant(
        &self,
        stack_name: &str,
        variant: StackVariant,
    ) -> BTreeMap<String, String> {
        self.0
            .iter()
            .filter(|list| list.id.stack.name == stack_name && list.id.stack.variant == variant)
            .flat_map(|list| list.packages.clone())
            .collect()
    }
}

/// Parses every entry in `dir` as a `StackPackageList`.
///
/// Every entry in `dir` must be a TSV file matching the
/// `<stack>[-build]_linux-<arch>-packages.tsv` naming convention. Stray
/// files such as `.DS_Store` or `README.md` cause this function to return
/// `FromFilenameError`. Filter the input directory before calling.
pub(crate) fn parse_stack_package_list_dir(
    dir: &Path,
) -> Result<StackPackageListCollection, ParseStackPackageListDirError> {
    let mut result = vec![];

    let read_dir = fs::read_dir(dir)?;
    for dir_entry in read_dir {
        let dir_entry = dir_entry?;
        let file = fs::File::open(dir.join(dir_entry.file_name()))?;

        let stack_package_list_id =
            StackPackageListId::from_file_name(&dir_entry.file_name().to_string_lossy())?;

        let packages = tsv::parse_key_value_map(file)?;

        result.push(StackPackageList {
            id: stack_package_list_id,
            packages,
        });
    }

    Ok(StackPackageListCollection(result))
}

#[derive(Debug, Error)]
pub(crate) enum ParseStackPackageListDirError {
    #[error(transparent)]
    Io(#[from] io::Error),
    #[error(transparent)]
    FromFilenameError(#[from] FromFilenameError),
    #[error(transparent)]
    TsvParseError(#[from] TsvParseError<UnexpectedColumnCountError>),
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::stack_package_list_id::{Architecture, Stack, StackVariant};
    use std::path::PathBuf;

    fn make_temp_dir() -> PathBuf {
        let dir = std::env::temp_dir().join(format!(
            "stack-package-report-test-{}",
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_nanos()
        ));
        fs::create_dir(&dir).unwrap();
        dir
    }

    #[test]
    fn parse_stack_package_list_dir_yields_one_entry_per_tsv_file() {
        let dir = make_temp_dir();
        fs::write(
            dir.join("heroku-24_linux-amd64-packages.tsv"),
            "bash\t5.1\nbinutils-x86-64-linux-gnu\t2.38\n",
        )
        .unwrap();
        fs::write(
            dir.join("heroku-24-build_linux-arm64-packages.tsv"),
            "bash\t5.1\nbinutils-aarch64-linux-gnu\t2.38\n",
        )
        .unwrap();

        let parsed = parse_stack_package_list_dir(&dir).unwrap();
        let mut parsed: Vec<&StackPackageList> = parsed.iter().collect();
        parsed.sort_by(|a, b| a.id.stack.cmp(&b.id.stack));

        assert_eq!(parsed.len(), 2);

        assert_eq!(
            parsed[0].id,
            StackPackageListId {
                stack: Stack {
                    name: String::from("heroku-24"),
                    variant: StackVariant::Base,
                },
                arch: Architecture::Amd64,
            }
        );
        assert_eq!(
            parsed[0].packages,
            [
                (String::from("bash"), String::from("5.1")),
                (
                    String::from("binutils-x86-64-linux-gnu"),
                    String::from("2.38"),
                ),
            ]
            .into_iter()
            .collect()
        );

        assert_eq!(
            parsed[1].id,
            StackPackageListId {
                stack: Stack {
                    name: String::from("heroku-24"),
                    variant: StackVariant::Build,
                },
                arch: Architecture::Arm64,
            }
        );
        assert_eq!(
            parsed[1].packages,
            [
                (String::from("bash"), String::from("5.1")),
                (
                    String::from("binutils-aarch64-linux-gnu"),
                    String::from("2.38"),
                ),
            ]
            .into_iter()
            .collect()
        );

        fs::remove_dir_all(&dir).unwrap();
    }

    #[test]
    fn parse_stack_package_list_dir_errors_on_unparseable_filename() {
        let dir = make_temp_dir();
        fs::write(dir.join("README.md"), "").unwrap();

        let result = parse_stack_package_list_dir(&dir);
        assert!(matches!(
            result,
            Err(ParseStackPackageListDirError::FromFilenameError(_))
        ));

        fs::remove_dir_all(&dir).unwrap();
    }
}
