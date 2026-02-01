#!/usr/bin/env python3
"""Check that markdown files in docs/ and standards/ don't link to submodule files.

Links to files inside submodules will be dead links when viewed on GitHub
because submodules appear as references to other repositories, not directories.
"""

import configparser
import re
import sys
from pathlib import Path


def get_submodule_paths(repo_root: Path) -> set[str]:
    """Parse .gitmodules to get submodule directory paths."""
    gitmodules_path = repo_root / ".gitmodules"
    if not gitmodules_path.exists():
        return set()

    config = configparser.ConfigParser()
    config.read(gitmodules_path)

    paths = set()
    for section in config.sections():
        if section.startswith("submodule"):
            path = config.get(section, "path", fallback=None)
            if path:
                paths.add(path)

    return paths


def find_markdown_links(content: str) -> list[tuple[str, int]]:
    """Extract markdown links and their line numbers from content.

    Returns list of (link_target, line_number) tuples.
    Only returns relative links (not http/https URLs).
    """
    links = []
    lines = content.split("\n")

    # Match markdown links: [text](url)
    link_pattern = re.compile(r"\[([^\]]*)\]\(([^)]+)\)")

    for line_num, line in enumerate(lines, start=1):
        for match in link_pattern.finditer(line):
            target = match.group(2)
            # Skip external URLs and anchors
            if target.startswith(("http://", "https://", "#", "mailto:")):
                continue
            # Remove anchor from link if present
            target = target.split("#")[0]
            if target:
                links.append((target, line_num))

    return links


def resolve_link(source_file: Path, link_target: str, repo_root: Path) -> Path | None:
    """Resolve a relative link to an absolute path within the repo."""
    # Get the directory containing the source file
    source_dir = source_file.parent

    # Resolve the link relative to the source file's directory
    resolved = (source_dir / link_target).resolve()

    # Check if it's within the repo
    try:
        resolved.relative_to(repo_root)
        return resolved
    except ValueError:
        # Link points outside the repo
        return None


def is_in_submodule(path: Path, submodule_paths: set[str], repo_root: Path) -> str | None:
    """Check if a path is inside a submodule directory.

    Returns the submodule name if inside one, None otherwise.
    """
    try:
        relative = path.relative_to(repo_root)
    except ValueError:
        return None

    # Check each submodule path
    for submodule in submodule_paths:
        submodule_parts = Path(submodule).parts
        if len(relative.parts) >= len(submodule_parts):
            if relative.parts[: len(submodule_parts)] == submodule_parts:
                return submodule

    return None


def check_file(
    md_file: Path, submodule_paths: set[str], repo_root: Path
) -> list[tuple[Path, int, str, str]]:
    """Check a markdown file for links to submodules.

    Returns list of (file, line_num, link, submodule) tuples for violations.
    """
    violations = []

    try:
        content = md_file.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError) as e:
        print(f"Warning: Could not read {md_file}: {e}", file=sys.stderr)
        return violations

    links = find_markdown_links(content)

    for link_target, line_num in links:
        resolved = resolve_link(md_file, link_target, repo_root)
        if resolved:
            submodule = is_in_submodule(resolved, submodule_paths, repo_root)
            if submodule:
                violations.append((md_file, line_num, link_target, submodule))

    return violations


def main() -> int:
    """Main entry point."""
    repo_root = Path.cwd()

    # Get submodule paths
    submodule_paths = get_submodule_paths(repo_root)
    if not submodule_paths:
        print("No submodules found in .gitmodules")
        return 0

    # Find markdown files to check in docs/ and standards/
    dirs_to_check = ["docs", "standards"]
    md_files: list[Path] = []

    for dir_name in dirs_to_check:
        dir_path = repo_root / dir_name
        if dir_path.exists():
            md_files.extend(dir_path.rglob("*.md"))

    if not md_files:
        print("No markdown files found to check")
        return 0

    # Check each file
    all_violations: list[tuple[Path, int, str, str]] = []
    for md_file in sorted(md_files):
        violations = check_file(md_file, submodule_paths, repo_root)
        all_violations.extend(violations)

    # Report results
    if all_violations:
        print("ERROR: Found links to submodule files (dead links on GitHub):\n")
        for file_path, line_num, link, submodule in all_violations:
            relative_file = file_path.relative_to(repo_root)
            print(f"  {relative_file}:{line_num}: '{link}' -> submodule '{submodule}'")
        print(
            f"\nFound {len(all_violations)} link(s) to submodule files."
        )
        print("These links will be broken when viewed on GitHub.")
        print("Use external URLs (https://github.com/...) instead.")
        return 1

    print(f"Checked {len(md_files)} markdown file(s) - no submodule links found")
    return 0


if __name__ == "__main__":
    sys.exit(main())
