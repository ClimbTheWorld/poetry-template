#!/usr/bin/env python3

import sys
from pathlib import Path


def normalize_line(line: str) -> str:
    """Ensure line ends with two spaces before newline (or end)."""
    return line.rstrip() + "  \n" if line.strip() else "\n"


def process_file(filepath: Path) -> bool:
    with open(filepath, "r", encoding="utf-8") as f:
        original_lines = f.readlines()

    processed_lines = [normalize_line(line) for line in original_lines]

    if processed_lines != original_lines:
        with open(filepath, "w", encoding="utf-8") as f:
            f.writelines(processed_lines)
        print(f"Updated: {filepath}")
        return True

    return False


def main():
    changed = False
    for arg in sys.argv[1:]:
        file = Path(arg)
        if file.suffix == ".md" and file.is_file():
            if process_file(file):
                changed = True

    sys.exit(1 if changed else 0)


if __name__ == "__main__":
    main()
