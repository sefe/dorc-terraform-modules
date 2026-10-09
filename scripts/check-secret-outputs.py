#!/usr/bin/env python3
"""Forbid 'sensitive = false' (or a missing sensitive attribute) on
secret-pattern outputs, mirroring sefe/dorc Tools.TerraformLint
secret-outputs. Terraform accepts output blocks in any .tf file, so every
.tf file under the given directory is scanned."""
import re
import sys
from pathlib import Path

SECRET_NAME = re.compile(r"(?i)(token|pat|secret|password|key|connectionstring)")
OUTPUT_START = re.compile(r'^\s*output\s+"([^"]+)"\s*\{')
SENSITIVE_ATTR = re.compile(r"^\s*sensitive\s*=\s*(true|false)\b")


def output_blocks(text):
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        m = OUTPUT_START.match(lines[i])
        if not m:
            i += 1
            continue
        depth = lines[i].count("{") - lines[i].count("}")
        block, start = [lines[i]], i + 1
        i += 1
        while i < len(lines) and depth > 0:
            depth += lines[i].count("{") - lines[i].count("}")
            block.append(lines[i])
            i += 1
        yield m.group(1), start, block


def main(root):
    failures = []
    for tf in sorted(Path(root).rglob("*.tf")):
        if ".terraform" in tf.parts:
            continue
        for name, line, block in output_blocks(tf.read_text(encoding="utf-8")):
            if not SECRET_NAME.search(name):
                continue
            sensitive = None
            for ln in block:
                m = SENSITIVE_ATTR.match(ln)
                if m:
                    sensitive = m.group(1)
            if sensitive != "true":
                why = "sensitive = false" if sensitive == "false" else "missing explicit sensitive = true"
                failures.append(f"{tf}:{line}: output \"{name}\" - {why}")
    for f in failures:
        print(f, file=sys.stderr)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1] if len(sys.argv) > 1 else "stock-modules"))
