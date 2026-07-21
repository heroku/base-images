use std::path::Path;

mod arch_normalize;
mod package_changelog_markdown;
mod package_changes;
mod package_list_devcenter;
mod stack_package_list;
mod stack_package_list_id;
mod tsv;

use indoc::indoc;

use crate::package_changelog_markdown::render_package_changelog_markdown;
use crate::package_list_devcenter::render_package_list_devcenter;
use crate::stack_package_list::parse_stack_package_list_dir;

fn main() {
    let args: Vec<String> = std::env::args().collect();

    let exit_code = match args.get(1).map(String::as_str) {
        Some("package-changelog-markdown") => run_package_changelog_markdown(&args[2..]),
        Some("devcenter-package-table") => run_devcenter_package_table(&args[2..]),
        _ => {
            print_usage();
            1
        }
    };

    std::process::exit(exit_code);
}

fn run_package_changelog_markdown(args: &[String]) -> i32 {
    let [previous_dir, current_dir] = args else {
        print_usage();
        return 1;
    };

    let previous_stack_packages = match parse_stack_package_list_dir(Path::new(previous_dir)) {
        Ok(value) => value,
        Err(e) => {
            eprintln!("failed to load {previous_dir}: {e}");
            return 1;
        }
    };

    let current_stack_packages = match parse_stack_package_list_dir(Path::new(current_dir)) {
        Ok(value) => value,
        Err(e) => {
            eprintln!("failed to load {current_dir}: {e}");
            return 1;
        }
    };

    println!(
        "{}",
        render_package_changelog_markdown(&previous_stack_packages, &current_stack_packages)
    );
    0
}

fn run_devcenter_package_table(args: &[String]) -> i32 {
    let [stacks @ .., current_dir] = args else {
        print_usage();
        return 1;
    };

    if stacks.is_empty() {
        print_usage();
        return 1;
    }

    let current_stack_packages = match parse_stack_package_list_dir(Path::new(current_dir)) {
        Ok(value) => value,
        Err(e) => {
            eprintln!("failed to load {current_dir}: {e}");
            return 1;
        }
    };

    print!(
        "{}",
        render_package_list_devcenter(stacks, &current_stack_packages)
    );
    0
}

fn print_usage() {
    eprint!(
        "{}",
        indoc! {"
            Usage:
              stack-package-report package-changelog-markdown <previous-tsv-dir> <current-tsv-dir>
              stack-package-report devcenter-package-table <stack-name>... <current-tsv-dir>
        "}
    );
}
