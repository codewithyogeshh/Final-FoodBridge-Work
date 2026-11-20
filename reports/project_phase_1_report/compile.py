#!/usr/bin/env python3
"""
Quick Compiler & Overleaf Exporter for FoodBridge Project Report.
Usage:
    python compile.py         # Compiles using local LaTeX (pdflatex/xelatex/latexmk)
    python compile.py --zip   # Creates foodbridge_report_phase1_overleaf.zip for 1-click Overleaf import
    python compile.py --clean # Cleans auxiliary build files
"""

import sys
import os
from pathlib import Path

# Add global script to path or run inline
script_path = Path(r"C:\Users\DELL\.gemini\config\skills\latex-report-specialist\scripts\compile_latex.py")

if __name__ == "__main__":
    current_dir = Path(__file__).parent.resolve()
    main_tex = current_dir / "main.tex"
    
    if "--zip" in sys.argv:
        import zipfile
        out_zip = current_dir / "foodbridge_report_phase1_overleaf.zip"
        ignored_exts = {".aux", ".log", ".out", ".toc", ".synctex.gz", ".pdf", ".zip"}
        
        with zipfile.ZipFile(out_zip, "w", zipfile.ZIP_DEFLATED) as zipf:
            for root, dirs, files in os.walk(current_dir):
                dirs[:] = [d for d in dirs if not d.startswith(".")]
                for file in files:
                    p = Path(root) / file
                    if p.suffix.lower() in ignored_exts or p.name in ("compile.py", "build_full_report.py", "generate_report_figures.py"):
                        continue
                    arcname = p.relative_to(current_dir)
                    zipf.write(p, arcname)
        print(f"\n[SUCCESS] Overleaf Package Created:")
        print(f" -> {out_zip.resolve()}")
        print("\nDrag and drop this .zip file directly into Overleaf (https://www.overleaf.com) to compile online!\n")
        sys.exit(0)

    # If python compiler script is present, run it
    if script_path.exists():
        os.system(f'python "{script_path}" --file "{main_tex}" {" ".join(sys.argv[1:])}')
    else:
        print(f"Please compile {main_tex} using your preferred LaTeX editor or run with --zip to upload to Overleaf.")
