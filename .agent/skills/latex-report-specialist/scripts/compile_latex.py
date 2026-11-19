#!/usr/bin/env python3
"""
LaTeX Compilation & Packaging Automation Utility.
Provides multi-pass compilation, log error diagnosis, auxiliary cleanup,
and one-click Overleaf ZIP packaging.
"""

import argparse
import os
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path


def find_latex_compiler():
    """Detect available LaTeX compilers on system PATH."""
    compilers = ["latexmk", "pdflatex", "xelatex", "lualatex", "tectonic"]
    for comp in compilers:
        if shutil.which(comp):
            return comp
    return None


def clean_auxiliary_files(directory: Path, base_name: str):
    """Remove LaTeX auxiliary artifacts."""
    extensions = [
        ".aux", ".bbl", ".blg", ".fdb_latexmk", ".fls",
        ".log", ".out", ".synctex.gz", ".toc", ".lof",
        ".lot", ".nav", ".snm", ".vrb", ".run.xml", "-blx.bib"
    ]
    cleaned = 0
    for ext in extensions:
        f = directory / f"{base_name}{ext}"
        if f.exists():
            try:
                f.unlink()
                cleaned += 1
            except Exception:
                pass
    return cleaned


def parse_log_for_errors(log_file: Path):
    """Extract actionable errors and line numbers from LaTeX log file."""
    if not log_file.exists():
        return []

    errors = []
    current_error = []
    is_capturing = False

    try:
        with open(log_file, "r", encoding="utf-8", errors="replace") as f:
            for line in f:
                if line.startswith("!"):
                    if current_error:
                        errors.append("\n".join(current_error))
                        current_error = []
                    is_capturing = True
                    current_error.append(line.strip())
                elif is_capturing:
                    if line.startswith("l.") or "line" in line.lower():
                        current_error.append(line.strip())
                        errors.append("\n".join(current_error))
                        current_error = []
                        is_capturing = False
                    elif line.strip() == "":
                        errors.append("\n".join(current_error))
                        current_error = []
                        is_capturing = False
                    else:
                        current_error.append(line.strip())
        if current_error:
            errors.append("\n".join(current_error))
    except Exception as e:
        errors.append(f"Could not read log file: {e}")

    return errors


def package_for_overleaf(source_dir: Path, output_zip: Path):
    """Package document directory into an Overleaf-ready ZIP file."""
    ignored_exts = {".aux", ".log", ".out", ".toc", ".synctex.gz", ".pdf", ".zip"}
    
    with zipfile.ZipFile(output_zip, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(source_dir):
            # Skip hidden dirs
            dirs[:] = [d for d in dirs if not d.startswith(".")]
            for file in files:
                p = Path(root) / file
                if p.suffix.lower() in ignored_exts:
                    continue
                arcname = p.relative_to(source_dir)
                zipf.write(p, arcname)
    print(f"[OK] Overleaf package created: {output_zip.resolve()}")


def compile_latex(file_path: Path, compiler: str, passes: int = 2):
    """Compile LaTeX document through multiple passes."""
    work_dir = file_path.parent.resolve()
    base_name = file_path.stem
    tex_name = file_path.name
    log_path = work_dir / f"{base_name}.log"
    pdf_path = work_dir / f"{base_name}.pdf"

    print(f"[*] Compiling {tex_name} with {compiler} ({passes} passes)...")

    if compiler == "latexmk":
        cmd = ["latexmk", "-pdf", "-interaction=nonstopmode", tex_name]
        res = subprocess.run(cmd, cwd=work_dir, capture_output=True, text=True)
    else:
        for p in range(1, passes + 1):
            print(f"    -> Pass {p}/{passes}...")
            cmd = [compiler, "-interaction=nonstopmode", tex_name]
            res = subprocess.run(cmd, cwd=work_dir, capture_output=True, text=True)

    if pdf_path.exists():
        print(f"[SUCCESS] PDF generated: {pdf_path}")
        return True
    else:
        print("[ERROR] PDF generation failed!")
        errors = parse_log_for_errors(log_path)
        if errors:
            print("\n--- Diagnostic Errors from LaTeX Engine ---")
            for err in errors[:5]:
                print(f"  {err}")
        return False


def main():
    parser = argparse.ArgumentParser(description="LaTeX Build & Package Automation Helper")
    parser.add_argument("--file", "-f", default="main.tex", help="Path to main .tex file")
    parser.add_argument("--clean", "-c", action="store_true", help="Clean auxiliary files")
    parser.add_argument("--zip", "-z", help="Create an Overleaf-ready ZIP archive at specified path")
    parser.add_argument("--compiler", choices=["pdflatex", "xelatex", "lualatex", "latexmk", "tectonic"], help="Specify compiler")

    args = parser.parse_args()
    tex_path = Path(args.file).resolve()

    if args.zip:
        zip_path = Path(args.zip)
        package_for_overleaf(tex_path.parent, zip_path)
        return 0

    if args.clean:
        cleaned = clean_auxiliary_files(tex_path.parent, tex_path.stem)
        print(f"[OK] Cleaned {cleaned} auxiliary files.")
        return 0

    compiler = args.compiler or find_latex_compiler()

    if not compiler:
        print("\n" + "=" * 60)
        print(" [!] No local LaTeX compiler found on PATH.")
        print("=" * 60)
        print("You can easily compile your document using one of these options:")
        print(" 1. Overleaf (Recommended - Zero Installation):")
        print(f"    Run: python {sys.argv[0]} --file {tex_path.name} --zip report_overleaf.zip")
        print("    Then simply drag and drop 'report_overleaf.zip' into Overleaf.")
        print("\n 2. Install MiKTeX on Windows:")
        print("    winget install MiKTeX.MiKTeX")
        print("=" * 60 + "\n")
        return 1

    success = compile_latex(tex_path, compiler)
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
