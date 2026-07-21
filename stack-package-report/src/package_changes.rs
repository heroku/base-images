//! Types that describe per-package changes between two snapshots, along
//! with the operations to derive and combine those change sets.

use std::collections::{BTreeMap, HashSet};

/// A single change in a package's presence or version between two snapshots.
#[derive(Clone, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub(crate) enum PackageChange {
    Added {
        version: String,
    },
    Removed {
        version: String,
    },
    Updated {
        previous_version: String,
        current_version: String,
    },
}

/// Compares two package-name-to-version maps and returns the set of changes
/// between them.
pub(crate) fn determine_package_changes(
    previous: &BTreeMap<String, String>,
    current: &BTreeMap<String, String>,
) -> BTreeMap<String, PackageChange> {
    let combined_package_names = previous
        .keys()
        .chain(current.keys())
        .cloned()
        .collect::<HashSet<_>>();

    combined_package_names
        .into_iter()
        .filter_map(|package_name| {
            match (
                previous.get(&package_name).cloned(),
                current.get(&package_name).cloned(),
            ) {
                (None, Some(current_version)) => Some((
                    package_name,
                    PackageChange::Added {
                        version: current_version.clone(),
                    },
                )),
                (Some(previous_version), None) => Some((
                    package_name,
                    PackageChange::Removed {
                        version: previous_version.clone(),
                    },
                )),
                (Some(previous_version), Some(current_version))
                    if previous_version != current_version =>
                {
                    Some((
                        package_name,
                        PackageChange::Updated {
                            previous_version,
                            current_version,
                        },
                    ))
                }
                _ => None,
            }
        })
        .collect()
}

/// Returns the entries of `changes` that do not appear verbatim in `other`.
///
/// An entry is considered to appear in `other` only when both the package
/// name and the [`PackageChange`] match exactly; entries with the same name
/// but a differing change are kept.
pub(crate) fn difference(
    changes: &BTreeMap<String, PackageChange>,
    other: &BTreeMap<String, PackageChange>,
) -> BTreeMap<String, PackageChange> {
    changes
        .iter()
        .filter(|(name, change)| other.get(*name) != Some(*change))
        .map(|(name, change)| (name.clone(), change.clone()))
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn determine_package_changes_detects_add_remove_update_skips_unchanged() {
        let previous_packages =
            build_packages_map([("bash", "5.1"), ("libfoo", "1.0"), ("old-pkg", "2.0")]);

        let current_packages =
            build_packages_map([("bash", "5.1"), ("libfoo", "1.1"), ("new-pkg", "3.0")]);

        let expected_changes = build_package_changes_map([
            (
                "libfoo",
                PackageChange::Updated {
                    previous_version: String::from("1.0"),
                    current_version: String::from("1.1"),
                },
            ),
            (
                "new-pkg",
                PackageChange::Added {
                    version: String::from("3.0"),
                },
            ),
            (
                "old-pkg",
                PackageChange::Removed {
                    version: String::from("2.0"),
                },
            ),
        ]);

        assert_eq!(
            determine_package_changes(&previous_packages, &current_packages),
            expected_changes
        );
    }

    #[test]
    fn difference_drops_entries_matching_other_verbatim() {
        let base_changes = build_package_changes_map([(
            "bash",
            PackageChange::Updated {
                previous_version: String::from("5.1"),
                current_version: String::from("5.2"),
            },
        )]);

        let build_changes = build_package_changes_map([
            (
                "bash",
                PackageChange::Updated {
                    previous_version: String::from("5.1"),
                    current_version: String::from("5.2"),
                },
            ),
            (
                "gcc",
                PackageChange::Added {
                    version: String::from("12.3"),
                },
            ),
        ]);

        let expected_changes = build_package_changes_map([(
            "gcc",
            PackageChange::Added {
                version: String::from("12.3"),
            },
        )]);

        assert_eq!(difference(&build_changes, &base_changes), expected_changes);
    }

    fn build_packages_map<'a>(
        pairs: impl IntoIterator<Item = (&'a str, &'a str)>,
    ) -> BTreeMap<String, String> {
        pairs
            .into_iter()
            .map(|(package_name, package_version)| {
                (package_name.to_string(), package_version.to_string())
            })
            .collect()
    }

    fn build_package_changes_map<'a>(
        pairs: impl IntoIterator<Item = (&'a str, PackageChange)>,
    ) -> BTreeMap<String, PackageChange> {
        pairs
            .into_iter()
            .map(|(package_name, package_change)| (package_name.to_string(), package_change))
            .collect()
    }
}
