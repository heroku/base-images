//! HTML-table rendering of the current package set across stacks for the
//! Heroku DevCenter stack-packages article.

use std::collections::{BTreeMap, BTreeSet};

use regex::Regex;

use crate::arch_normalize::normalize_arch_in_package_name;
use crate::stack_package_list::StackPackageListCollection;
use crate::stack_package_list_id::StackVariant;

pub(crate) fn render_package_list_devcenter(
    stack_names: &[String],
    current_stack_packages: &StackPackageListCollection,
) -> String {
    let raw_names = current_stack_packages.package_names_for_stacks(stack_names);
    let package_name_groups = group_by_normalized_name(&raw_names);

    let mut result = String::new();
    result.push_str("<table>\n");
    result.push_str("  <thead>\n");
    result.push_str("    <tr>\n");
    result.push_str("      <th>Package</th>\n");
    for stack_name in stack_names {
        result.push_str(&format!(
            "      <th><code>{stack_name}</code> version</th>\n"
        ));
    }
    result.push_str("    </tr>\n");
    result.push_str("  </thead>\n");
    result.push_str("  <tbody>\n");

    for (normalized_name, raw_names_in_row) in &package_name_groups {
        let primary_package_name = raw_names_in_row
            .first()
            .expect("group must contain at least one raw name");

        let names_html = raw_names_in_row
            .iter()
            .map(|raw| format!("<code>{raw}</code>"))
            .collect::<Vec<_>>()
            .join("<br />");

        result.push_str(&format!("    <tr id=\"{normalized_name}\">\n"));
        result.push_str("      <td style=\"white-space: nowrap\">");
        result.push_str(&names_html);
        result.push_str("</td>\n");

        for stack_name in stack_names {
            let version_td_html = match current_stack_packages
                .version_for_package(stack_name, primary_package_name)
            {
                Some((StackVariant::Build, version)) => format!(
                    "<td style=\"background-color: #fff3c5; color: #856800\">{}</td>",
                    insert_zero_width_space_after_git_marker(&version)
                ),
                Some((StackVariant::Base, version)) => format!(
                    "<td>{}</td>",
                    insert_zero_width_space_after_git_marker(&version)
                ),
                None => String::from("<td>&#xa0;</td>"),
            };

            result.push_str(&format!("      {version_td_html}\n"));
        }

        result.push_str("    </tr>\n");
    }

    result.push_str("  </tbody>\n");
    result.push_str("</table>\n");

    result
}

pub(crate) fn group_by_normalized_name(
    raw_names: &BTreeSet<String>,
) -> BTreeMap<String, BTreeSet<String>> {
    let mut groups: BTreeMap<String, BTreeSet<String>> = BTreeMap::new();
    for raw in raw_names {
        let normalized = normalize_arch_in_package_name(raw);
        groups.entry(normalized).or_default().insert(raw.clone());
    }
    groups
}

// Some Ubuntu package versions contain a long `git…` segment whose only
// internal separators are `+` or `.` (e.g. `0.5.11+git20210903+057cd650a4ed-3build1`).
// Browsers treat that as one unbreakable token and the table column blows
// out horizontally. Inserting a zero-width space after the `git…` segment
// gives the browser an invisible break opportunity.
fn insert_zero_width_space_after_git_marker(version: &str) -> String {
    Regex::new(r"\b(git\w+)([^-\w])(\w+)")
        .expect("regex should compile")
        .replace(version, "${1}&#x200b;${2}${3}")
        .into_owned()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::stack_package_list::StackPackageList;
    use crate::stack_package_list_id::{Architecture, Stack, StackPackageListId};
    use indoc::indoc;

    #[test]
    #[allow(clippy::too_many_lines)]
    fn renders_full_devcenter_table_covers_all_features() {
        let current_stack_packages = vec![
            // heroku-22 base
            build_stack_packages(
                "heroku-22",
                StackVariant::Base,
                Architecture::Amd64,
                &[
                    ("apt", "123"),
                    ("binutils-x86-64-linux-gnu", "2.38-4ubuntu2.6"),
                    ("sudo", "456"),
                    ("syslinux", "3:6.04~git20190206.bf6db5b4+dfsg1-3ubuntu1"),
                ],
            ),
            build_stack_packages(
                "heroku-22",
                StackVariant::Base,
                Architecture::Arm64,
                &[
                    ("apt", "123"),
                    ("binutils-aarch64-linux-gnu", "2.38-4ubuntu2.6"),
                    ("sudo", "456"),
                    ("syslinux", "3:6.04~git20190206.bf6db5b4+dfsg1-3ubuntu1"),
                ],
            ),
            // heroku-22 build
            build_stack_packages(
                "heroku-22",
                StackVariant::Build,
                Architecture::Amd64,
                &[
                    ("apt", "123"),
                    ("binutils-x86-64-linux-gnu", "2.38-4ubuntu2.6"),
                    ("cpp-x86-64-linux-gnu", "4:13.2.0-7ubuntu1"),
                    ("sudo", "456"),
                    ("sudo-dev", "456"),
                    ("syslinux", "3:6.04~git20190206.bf6db5b4+dfsg1-3ubuntu1"),
                ],
            ),
            build_stack_packages(
                "heroku-22",
                StackVariant::Build,
                Architecture::Arm64,
                &[
                    ("apt", "123"),
                    ("binutils-aarch64-linux-gnu", "2.38-4ubuntu2.6"),
                    ("cpp-aarch64-linux-gnu", "4:13.2.0-7ubuntu1"),
                    ("sudo", "456"),
                    ("sudo-dev", "456"),
                    ("syslinux", "3:6.04~git20190206.bf6db5b4+dfsg1-3ubuntu1"),
                ],
            ),
            // heroku-24 base
            build_stack_packages(
                "heroku-24",
                StackVariant::Base,
                Architecture::Amd64,
                &[
                    ("apt", "123"),
                    ("binutils-x86-64-linux-gnu", "2.38-4ubuntu2.6"),
                    ("dash", "0.5.11+git20210903+057cd650a4ed-3build1"),
                    ("gcc-13-x86-64-linux-gnu", "13.2.0-23ubuntu4"),
                    ("sudo", "456"),
                    ("syslinux", "3:6.04~git20190206.bf6db5b4+dfsg1-3ubuntu1"),
                ],
            ),
            build_stack_packages(
                "heroku-24",
                StackVariant::Base,
                Architecture::Arm64,
                &[
                    ("apt", "123"),
                    ("binutils-aarch64-linux-gnu", "2.38-4ubuntu2.6"),
                    ("dash", "0.5.11+git20210903+057cd650a4ed-3build1"),
                    ("gcc-13-aarch64-linux-gnu", "13.2.0-23ubuntu4"),
                    ("sudo", "456"),
                    ("syslinux", "3:6.04~git20190206.bf6db5b4+dfsg1-3ubuntu1"),
                ],
            ),
            // heroku-24 build
            build_stack_packages(
                "heroku-24",
                StackVariant::Build,
                Architecture::Amd64,
                &[
                    ("apt", "123"),
                    ("binutils-x86-64-linux-gnu", "2.38-4ubuntu2.6"),
                    ("cpp-x86-64-linux-gnu", "4:13.2.0-7ubuntu1"),
                    ("dash", "0.5.11+git20210903+057cd650a4ed-3build1"),
                    ("gcc-13-x86-64-linux-gnu", "13.2.0-23ubuntu4"),
                    ("sudo", "456"),
                    ("sudo-dev", "456"),
                    ("syslinux", "3:6.04~git20190206.bf6db5b4+dfsg1-3ubuntu1"),
                ],
            ),
            build_stack_packages(
                "heroku-24",
                StackVariant::Build,
                Architecture::Arm64,
                &[
                    ("apt", "123"),
                    ("binutils-aarch64-linux-gnu", "2.38-4ubuntu2.6"),
                    ("cpp-aarch64-linux-gnu", "4:13.2.0-7ubuntu1"),
                    ("dash", "0.5.11+git20210903+057cd650a4ed-3build1"),
                    ("gcc-13-aarch64-linux-gnu", "13.2.0-23ubuntu4"),
                    ("sudo", "456"),
                    ("sudo-dev", "456"),
                    ("syslinux", "3:6.04~git20190206.bf6db5b4+dfsg1-3ubuntu1"),
                ],
            ),
        ];

        let stack_order = vec!["heroku-22".to_string(), "heroku-24".to_string()];

        let expected = indoc! {r#"
            <table>
              <thead>
                <tr>
                  <th>Package</th>
                  <th><code>heroku-22</code> version</th>
                  <th><code>heroku-24</code> version</th>
                </tr>
              </thead>
              <tbody>
                <tr id="apt">
                  <td style="white-space: nowrap"><code>apt</code></td>
                  <td>123</td>
                  <td>123</td>
                </tr>
                <tr id="binutils-${arch}-linux-gnu">
                  <td style="white-space: nowrap"><code>binutils-aarch64-linux-gnu</code><br /><code>binutils-x86-64-linux-gnu</code></td>
                  <td>2.38-4ubuntu2.6</td>
                  <td>2.38-4ubuntu2.6</td>
                </tr>
                <tr id="cpp-${arch}-linux-gnu">
                  <td style="white-space: nowrap"><code>cpp-aarch64-linux-gnu</code><br /><code>cpp-x86-64-linux-gnu</code></td>
                  <td style="background-color: #fff3c5; color: #856800">4:13.2.0-7ubuntu1</td>
                  <td style="background-color: #fff3c5; color: #856800">4:13.2.0-7ubuntu1</td>
                </tr>
                <tr id="dash">
                  <td style="white-space: nowrap"><code>dash</code></td>
                  <td>&#xa0;</td>
                  <td>0.5.11+git20210903&#x200b;+057cd650a4ed-3build1</td>
                </tr>
                <tr id="gcc-13-${arch}-linux-gnu">
                  <td style="white-space: nowrap"><code>gcc-13-aarch64-linux-gnu</code><br /><code>gcc-13-x86-64-linux-gnu</code></td>
                  <td>&#xa0;</td>
                  <td>13.2.0-23ubuntu4</td>
                </tr>
                <tr id="sudo">
                  <td style="white-space: nowrap"><code>sudo</code></td>
                  <td>456</td>
                  <td>456</td>
                </tr>
                <tr id="sudo-dev">
                  <td style="white-space: nowrap"><code>sudo-dev</code></td>
                  <td style="background-color: #fff3c5; color: #856800">456</td>
                  <td style="background-color: #fff3c5; color: #856800">456</td>
                </tr>
                <tr id="syslinux">
                  <td style="white-space: nowrap"><code>syslinux</code></td>
                  <td>3:6.04~git20190206&#x200b;.bf6db5b4+dfsg1-3ubuntu1</td>
                  <td>3:6.04~git20190206&#x200b;.bf6db5b4+dfsg1-3ubuntu1</td>
                </tr>
              </tbody>
            </table>
        "#};
        assert_eq!(
            render_package_list_devcenter(
                &stack_order,
                &StackPackageListCollection(current_stack_packages),
            ),
            expected
        );
    }

    #[test]
    fn single_arch_package_renders_only_observed_arch() {
        let current = StackPackageListCollection(vec![build_stack_packages(
            "heroku-24",
            StackVariant::Base,
            Architecture::Amd64,
            &[("intel-only-x86-64-linux-gnu", "0.1")],
        )]);
        let stack_order = vec!["heroku-24".to_string()];

        let output = render_package_list_devcenter(&stack_order, &current);
        assert!(output.contains("<code>intel-only-x86-64-linux-gnu</code></td>"));
        assert!(!output.contains("intel-only-aarch64-linux-gnu"));
    }

    #[test]
    fn build_only_package_gets_yellow_style() {
        let current = StackPackageListCollection(vec![build_stack_packages(
            "heroku-24",
            StackVariant::Build,
            Architecture::Amd64,
            &[("make", "4.4")],
        )]);
        let stack_order = vec!["heroku-24".to_string()];

        let output = render_package_list_devcenter(&stack_order, &current);
        assert!(
            output.contains("<td style=\"background-color: #fff3c5; color: #856800\">4.4</td>")
        );
    }

    #[test]
    fn zero_width_space_inserted_after_git_marker() {
        assert_eq!(
            insert_zero_width_space_after_git_marker("0.5.11+git20210903+057cd650a4ed-3build1"),
            "0.5.11+git20210903&#x200b;+057cd650a4ed-3build1"
        );
        assert_eq!(
            insert_zero_width_space_after_git_marker("3:6.04~git20190206.bf6db5b4+dfsg1-3ubuntu1"),
            "3:6.04~git20190206&#x200b;.bf6db5b4+dfsg1-3ubuntu1"
        );
        assert_eq!(insert_zero_width_space_after_git_marker("1.2.3"), "1.2.3");
    }

    #[test]
    fn stack_order_controls_columns() {
        let current = StackPackageListCollection(vec![
            build_stack_packages(
                "heroku-22",
                StackVariant::Base,
                Architecture::Amd64,
                &[("apt", "1")],
            ),
            build_stack_packages(
                "heroku-24",
                StackVariant::Base,
                Architecture::Amd64,
                &[("apt", "2")],
            ),
        ]);

        let reversed = vec!["heroku-24".to_string(), "heroku-22".to_string()];
        let output = render_package_list_devcenter(&reversed, &current);

        let h24_idx = output.find("heroku-24").unwrap();
        let h22_idx = output.find("heroku-22").unwrap();
        assert!(h24_idx < h22_idx);

        let v2_idx = output.find(">2<").unwrap();
        let v1_idx = output.find(">1<").unwrap();
        assert!(v2_idx < v1_idx);
    }

    #[test]
    fn stack_filter_excludes_unlisted_stacks() {
        let current = StackPackageListCollection(vec![
            build_stack_packages(
                "heroku-24",
                StackVariant::Base,
                Architecture::Amd64,
                &[("apt", "kept")],
            ),
            build_stack_packages(
                "cedar-14",
                StackVariant::Base,
                Architecture::Amd64,
                &[("legacy-pkg", "dropped")],
            ),
        ]);

        let stack_order = vec!["heroku-24".to_string()];
        let output = render_package_list_devcenter(&stack_order, &current);

        assert!(output.contains("apt"));
        assert!(!output.contains("legacy-pkg"));
        assert!(!output.contains("cedar-14"));
    }

    #[test]
    fn package_names_for_stacks_collects_raw_names_across_arches_and_variants() {
        let stack_packages = StackPackageListCollection(vec![
            build_stack_packages(
                "heroku-24",
                StackVariant::Base,
                Architecture::Amd64,
                &[("apt", "1"), ("binutils-x86-64-linux-gnu", "2.38")],
            ),
            build_stack_packages(
                "heroku-24",
                StackVariant::Base,
                Architecture::Arm64,
                &[("apt", "1"), ("binutils-aarch64-linux-gnu", "2.38")],
            ),
            build_stack_packages(
                "heroku-24",
                StackVariant::Build,
                Architecture::Amd64,
                &[("apt", "1"), ("make", "4.4")],
            ),
            build_stack_packages(
                "cedar-14",
                StackVariant::Base,
                Architecture::Amd64,
                &[("legacy-pkg", "0.1")],
            ),
        ]);

        let names = stack_packages.package_names_for_stacks(&["heroku-24".to_string()]);

        let expected: BTreeSet<String> = [
            "apt",
            "binutils-aarch64-linux-gnu",
            "binutils-x86-64-linux-gnu",
            "make",
        ]
        .into_iter()
        .map(String::from)
        .collect();
        assert_eq!(names, expected);
    }

    #[test]
    fn version_for_package_prefers_base_over_build() {
        let stack_packages = StackPackageListCollection(vec![
            build_stack_packages(
                "heroku-24",
                StackVariant::Base,
                Architecture::Amd64,
                &[("apt", "base-version")],
            ),
            build_stack_packages(
                "heroku-24",
                StackVariant::Build,
                Architecture::Amd64,
                &[("apt", "build-version")],
            ),
        ]);

        assert_eq!(
            stack_packages.version_for_package("heroku-24", "apt"),
            Some((StackVariant::Base, "base-version".to_string()))
        );
    }

    #[test]
    fn version_for_package_falls_back_to_build_when_base_missing() {
        let stack_packages = StackPackageListCollection(vec![build_stack_packages(
            "heroku-24",
            StackVariant::Build,
            Architecture::Amd64,
            &[("make", "4.4")],
        )]);

        assert_eq!(
            stack_packages.version_for_package("heroku-24", "make"),
            Some((StackVariant::Build, "4.4".to_string()))
        );
    }

    #[test]
    fn version_for_package_returns_none_when_absent() {
        let stack_packages = StackPackageListCollection(vec![build_stack_packages(
            "heroku-24",
            StackVariant::Base,
            Architecture::Amd64,
            &[("apt", "1")],
        )]);

        assert_eq!(
            stack_packages.version_for_package("heroku-24", "missing"),
            None
        );
    }

    #[test]
    fn version_for_package_scopes_to_requested_stack() {
        let stack_packages = StackPackageListCollection(vec![
            build_stack_packages(
                "heroku-22",
                StackVariant::Base,
                Architecture::Amd64,
                &[("apt", "old")],
            ),
            build_stack_packages(
                "heroku-24",
                StackVariant::Base,
                Architecture::Amd64,
                &[("apt", "new")],
            ),
        ]);

        assert_eq!(
            stack_packages.version_for_package("heroku-24", "apt"),
            Some((StackVariant::Base, "new".to_string()))
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
