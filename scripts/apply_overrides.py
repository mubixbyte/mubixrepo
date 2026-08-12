#!/usr/bin/env python3
import json
import pathlib
import sys

packages_path = pathlib.Path(sys.argv[1])
overrides_path = pathlib.Path(sys.argv[2])
overrides = json.loads(overrides_path.read_text(encoding="utf-8"))

paragraphs = packages_path.read_text(encoding="utf-8").strip().split("\n\n")
result = []
for paragraph in paragraphs:
    lines = paragraph.splitlines()
    fields = {}
    for line in lines:
        if ": " in line:
            key, value = line.split(": ", 1)
            fields[key] = value
    package_overrides = overrides.get(fields.get("Package"), {})
    for key, value in package_overrides.items():
        replacement = f"{key}: {value}"
        for index, line in enumerate(lines):
            if line.startswith(f"{key}: "):
                lines[index] = replacement
                break
        else:
            lines.append(replacement)
    result.append("\n".join(lines))

packages_path.write_text("\n\n".join(result) + "\n", encoding="utf-8")
