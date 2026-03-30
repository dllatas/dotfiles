#!/usr/bin/env python3
from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
import re
import tomllib


TABLE_HEADER_RE = re.compile(r"^\s*\[[^\]]+\]\s*$")
KEY_LINE_RE = re.compile(r"^\s*([A-Za-z0-9_-]+)\s*=")


@dataclass
class Section:
    header: str
    content: list[str]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Reconcile stable Codex defaults into an existing config.toml.",
    )
    parser.add_argument("source", type=Path, help="Tracked source config.toml")
    parser.add_argument("dest", type=Path, help="Live ~/.codex/config.toml")
    return parser.parse_args()


def split_sections(lines: list[str]) -> tuple[list[str], list[Section]]:
    root_lines: list[str] = []
    sections: list[Section] = []
    current_header: str | None = None
    current_content: list[str] = []

    for line in lines:
        if TABLE_HEADER_RE.match(line):
            if current_header is None:
                current_header = line
            else:
                sections.append(Section(header=current_header, content=current_content))
                current_header = line
                current_content = []
            continue

        if current_header is None:
            root_lines.append(line)
        else:
            current_content.append(line)

    if current_header is not None:
        sections.append(Section(header=current_header, content=current_content))

    return root_lines, sections


def strip_managed_key_lines(lines: list[str], managed_keys: set[str]) -> list[str]:
    kept: list[str] = []
    for line in lines:
        match = KEY_LINE_RE.match(line)
        if match and match.group(1) in managed_keys:
            continue
        kept.append(line)
    return kept


def trim_blank_edges(lines: list[str]) -> list[str]:
    start = 0
    end = len(lines)

    while start < end and lines[start].strip() == "":
        start += 1

    while end > start and lines[end - 1].strip() == "":
        end -= 1

    return lines[start:end]


def is_comment_only(lines: list[str]) -> bool:
    trimmed = trim_blank_edges(lines)
    if not trimmed:
        return True
    return all(line.lstrip().startswith("#") for line in trimmed)


def ensure_blank_line(lines: list[str]) -> list[str]:
    if not lines:
        return []
    if lines[-1].strip() != "":
        return [*lines, "\n"]
    return lines


def remove_prefix(lines: list[str], prefix: list[str]) -> list[str]:
    if prefix and lines[: len(prefix)] == prefix:
        return lines[len(prefix) :]
    return lines


def extract_leading_comment_block(lines: list[str]) -> list[str]:
    block: list[str] = []
    for line in lines:
        if KEY_LINE_RE.match(line):
            break
        block.append(line)
    return block


def render(
    managed_root_lines: list[str],
    extra_root_lines: list[str],
    managed_feature_lines: list[str],
    extra_feature_lines: list[str],
    sections: list[Section],
) -> str:
    output: list[str] = []
    output.extend(ensure_blank_line(managed_root_lines))

    trimmed_extra_root = trim_blank_edges(extra_root_lines)
    if trimmed_extra_root:
        output.extend(trimmed_extra_root)
        output = ensure_blank_line(output)

    output.extend(managed_feature_lines)

    trimmed_extra_feature = trim_blank_edges(extra_feature_lines)
    if trimmed_extra_feature:
        output = ensure_blank_line(output)
        output.extend(trimmed_extra_feature)

    if sections:
        output = ensure_blank_line(output)

    for index, section in enumerate(sections):
        if index > 0 and output and output[-1].strip() != "":
            output.append("\n")
        output.append(section.header)
        output.extend(section.content)
        output = ensure_blank_line(output)

    rendered = "".join(output).rstrip("\n")
    return f"{rendered}\n"


def main() -> int:
    args = parse_args()

    source_text = args.source.read_text(encoding="utf-8")
    source_data = tomllib.loads(source_text)
    managed_root_keys = {key for key in source_data.keys() if key != "features"}
    managed_feature_keys = set(source_data.get("features", {}).keys())

    source_lines = source_text.splitlines(keepends=True)
    _, source_sections = split_sections(source_lines)

    managed_root_lines: list[str] = []
    managed_feature_lines: list[str] = []
    for section in source_sections:
        if section.header.strip() == "[features]":
            managed_feature_lines = [section.header, *section.content]
            break

    if managed_feature_lines:
        feature_start = source_lines.index(managed_feature_lines[0])
        managed_root_lines = source_lines[:feature_start]
    else:
        managed_root_lines = source_lines
    managed_comment_lines = extract_leading_comment_block(managed_root_lines)

    dest_text = args.dest.read_text(encoding="utf-8")
    dest_lines = dest_text.splitlines(keepends=True)
    extra_root_lines, dest_sections = split_sections(dest_lines)
    extra_root_lines = remove_prefix(extra_root_lines, managed_root_lines)
    while managed_comment_lines and extra_root_lines[: len(managed_comment_lines)] == managed_comment_lines:
        extra_root_lines = extra_root_lines[len(managed_comment_lines) :]
    extra_root_lines = strip_managed_key_lines(extra_root_lines, managed_root_keys)
    if is_comment_only(extra_root_lines):
        extra_root_lines = []

    extra_feature_lines: list[str] = []
    kept_sections: list[Section] = []

    for section in dest_sections:
        header = section.header.strip()

        if header == "[features]":
            extra_feature_lines.extend(
                strip_managed_key_lines(section.content, managed_feature_keys)
            )
            continue

        cleaned_content = strip_managed_key_lines(section.content, managed_root_keys)
        kept_sections.append(Section(header=section.header, content=cleaned_content))

    rendered = render(
        managed_root_lines=managed_root_lines,
        extra_root_lines=extra_root_lines,
        managed_feature_lines=managed_feature_lines,
        extra_feature_lines=extra_feature_lines,
        sections=kept_sections,
    )

    if rendered == dest_text:
        print("unchanged")
        return 0

    args.dest.write_text(rendered, encoding="utf-8")
    print("changed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
