---
name: latex-report-specialist
description: Author, structure, format, and compile professional LaTeX reports, technical documentation, academic papers, and project theses with beautiful typography, figures, algorithms, and automated compilation. Use when creating, converting, or formatting LaTeX documents, reports, or Overleaf projects.
metadata:
  version: 1.0.0
  category: documentation-and-publishing
---

# LaTeX Report Specialist

A comprehensive, production-grade guide and toolkit for authoring, styling, and compiling high-craft LaTeX reports. Whether building an academic thesis, a college/university final year project report, an IEEE-style conference paper, or an executive industry technical report, this skill provides standard architectures, typography tokens, preambles, and automation workflows.

---

## 1. When to Use This Skill

- Creating academic, university, or engineering project reports (B.Tech, M.Tech, PhD theses, seminar reports).
- Formatting professional corporate, white-paper, or technical documentation reports.
- Designing elegant title pages, multi-chapter layouts, and front matter (Certificate, Declaration, Acknowledgements, Abstract, TOC, List of Figures, List of Tables).
- Structuring mathematical equations, theorem environments, pseudocode algorithms, and syntax-highlighted code snippets.
- Designing publication-quality tables (using `booktabs`, `tabularx`) and vector figures (TikZ, pgfplots).
- Managing citations, bibliographies, and cross-references using BibTeX or BibLaTeX.
- Troubleshooting LaTeX syntax errors, overfull/underfull hbox warnings, or citation `??` issues.
- Setting up local compilation (`latexmk`, `pdflatex`, `xelatex`, `lualatex`, `tectonic`) or generating export packages for Overleaf.

---

## 2. Core Architectural Philosophy

### A. Modular File Structure (Multi-Chapter Projects)
Never write a 50+ page report in a single `.tex` file. Always organize modularly:

```
my-report/
├── main.tex                  # Root document (loads preamble, includes chapters)
├── preamble.tex              # All package imports, custom colors, environments
├── references.bib            # BibTeX database
├── figures/                  # Images, screenshots, diagrams (.png, .jpg, .pdf)
│   ├── architecture.png
│   └── flowchart.pdf
├── chapters/                 # Individual chapter content
│   ├── 00_frontmatter.tex    # Certificate, declaration, abstract
│   ├── 01_introduction.tex
│   ├── 02_literature_survey.tex
│   ├── 03_system_architecture.tex
│   ├── 04_implementation.tex
│   ├── 05_results_and_discussion.tex
│   └── 06_conclusion.tex
└── appendices/
    └── app_code_and_schematics.tex
```

### B. The 60-30-10 Aesthetic in Document Design
Apply modern graphic design restraint to LaTeX documents:
- **Base (60%)**: Clean, legible, high-contrast serif or modern sans-serif body typography on crisp white background.
- **Structural (30%)**: Muted slate/charcoal for section dividers, table borders (`booktabs`), chapter number ornaments, and footer rules.
- **Accent (10%)**: A single cohesive theme color (e.g. Deep Forest Green `#0F4D2E`, Royal Navy `#1A365D`, or Burgundy `#702459`) for chapter headings, table header accents, callout box borders, and hyperlinks.

---

## 3. Recommended Preamble & Essential Packages

A robust, conflict-free standard preamble:

```latex
% ==============================================================================
% DOCUMENT CLASS & GEOMETRY
% ==============================================================================
\documentclass[12pt,a4paper,oneside]{report} % Or scrreprt for KOMA-Script
\usepackage[
    top=1.0in,
    bottom=1.0in,
    left=1.25in,  % Extra margin on the left for binding
    right=1.0in,
    headheight=15pt
]{geometry}

% ==============================================================================
% TYPOGRAPHY & ENCODING
% ==============================================================================
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{lmodern}           % Crisp Latin Modern fonts
\usepackage{microtype}         % Subtle font expansion & protrusion (less hyphenation)
\usepackage{setspace}
\onehalfspacing                % Standard 1.5 line spacing for academic reports

% ==============================================================================
% MATHEMATICS & SYMBOLS
% ==============================================================================
\usepackage{amsmath,amssymb,amsfonts,mathtools}
\usepackage{amsthm}

% ==============================================================================
% GRAPHICS, FIGURES & CAPTIONS
% ==============================================================================
\usepackage{graphicx}
\usepackage{float}
\usepackage{subcaption}
\usepackage[labelfont={bf,color=ThemeColor},font=small,skip=8pt]{caption}

% ==============================================================================
% TABLES & BOOKTABS (NO VERTICAL LINES)
% ==============================================================================
\usepackage{booktabs}          % \toprule, \midrule, \bottomrule
\usepackage{tabularx}          % Flexible column widths
\usepackage{multirow}
\usepackage{makecell}
\usepackage{colortbl}          % Row/cell highlighting

% ==============================================================================
% COLORS & HIGHLIGHTING
% ==============================================================================
\usepackage[dvipsnames,svgnames,x11names]{xcolor}
\definecolor{ThemeColor}{HTML}{0F4D2E}      % Deep Green
\definecolor{SecondaryColor}{HTML}{27AE60}  % Emerald
\definecolor{SlateGrey}{HTML}{4A5568}       % Muted body text / subheadings
\definecolor{CodeBg}{HTML}{F8FAFC}          % Light slate for code snippets
\definecolor{BoxBorder}{HTML}{CBD5E1}       % Subtle border

% ==============================================================================
% MODERN CALLOUT BOXES (tcolorbox)
% ==============================================================================
\usepackage[most]{tcolorbox}
\newtcolorbox{infobox}[1][]{
    enhanced,
    colback=CodeBg,
    colframe=ThemeColor,
    arc=4pt,
    boxrule=1.2pt,
    left=12pt,
    right=12pt,
    top=8pt,
    bottom=8pt,
    title=\textbf{#1},
    coltitle=white,
    attach boxed title to top left={yshift=-2mm, xshift=4mm},
    boxed title style={colback=ThemeColor, arc=3pt}
}

% ==============================================================================
% CODE LISTINGS
% ==============================================================================
\usepackage{listings}
\lstset{
    backgroundcolor=\color{CodeBg},
    basicstyle=\ttfamily\footnotesize,
    keywordstyle=\color{ThemeColor}\bfseries,
    commentstyle=\color{SlateGrey}\itshape,
    stringstyle=\color{DarkOrange3},
    numbers=left,
    numberstyle=\tiny\color{SlateGrey},
    stepnumber=1,
    numbersep=8pt,
    showstringspaces=false,
    breaklines=true,
    frame=lines,
    rulecolor=\color{BoxBorder},
    tabsize=2
}

% ==============================================================================
% HEADERS & FOOTERS (fancyhdr)
% ==============================================================================
\usepackage{fancyhdr}
\pagestyle{fancy}
\fancyhf{}
\fancyhead[L]{\small\itshape\nouppercase{\leftmark}}
\fancyhead[R]{\small\color{ThemeColor}\textbf{Project Report}}
\fancyfoot[C]{\thepage}
\renewcommand{\headrulewidth}{0.5pt}
\renewcommand{\footrulewidth}{0pt}

% ==============================================================================
% HYPERLINKS & METADATA (Always load last)
% ==============================================================================
\usepackage[
    colorlinks=true,
    linkcolor=ThemeColor,
    citecolor=SecondaryColor,
    urlcolor=NavyBlue,
    pdfauthor={Student / Author Name},
    pdftitle={Project Report Title},
    pdfsubject={Technical Report},
    pdfkeywords={LaTeX, Report, Research}
]{hyperref}
```

---

## 4. Standard Report Sections & Templates

### A. Academic Report Structure
An official college/university project report must contain these sections in order:

1. **Title Page**: Project title, student names & roll numbers, guide/advisor name, department, college emblem/logo, and academic year.
2. **Certificate Page**: Official certificate signed by the Guide, Head of Department (HOD), and External Examiner.
3. **Declaration**: Student declaration of original work.
4. **Acknowledgements**: Gratitude to mentors, faculty, institution, and peers.
5. **Abstract**: Concise 250-400 word summary of problem statement, methodology, key findings, and outcomes.
6. **Table of Contents, List of Figures, List of Tables**.
7. **Body Chapters**:
   - Chapter 1: Introduction (Background, motivation, problem definition, objectives, report organization).
   - Chapter 2: Literature Review (Survey of related work, comparative matrix, research gap).
   - Chapter 3: System Design & Architecture (System block diagram, data flow, sequence diagram, database schema).
   - Chapter 4: Implementation Details (Algorithms, tech stack, key modules, API contracts).
   - Chapter 5: Results & Performance Evaluation (Empirical tables, test cases, graphs, comparative analysis).
   - Chapter 6: Conclusion & Future Scope.
8. **References / Bibliography** (`references.bib`).
9. **Appendices** (Code listings, survey questions, datasheets).

---

## 5. High-Craft LaTeX Components

### A. Beautiful Tables with `booktabs` (Golden Rule: NEVER USE VERTICAL LINES)
❌ **Bad (High school style)**: `\begin{tabular}{|l|c|r|}` with vertical pipes and `\hline` everywhere.
✅ **Good (Journal quality)**:
```latex
\begin{table}[htbp]
\centering
\caption{Performance Comparison Across Model Checkpoints}
\label{tab:model_comparison}
\begin{tabularx}{\textwidth}{l X c c r}
\toprule
\textbf{Model Variant} & \textbf{Architecture} & \textbf{Latency (ms)} & \textbf{Accuracy (\%)} & \textbf{Parameters} \\
\midrule
Baseline V1 & MobileNetV2-Lite & 14.2 & 88.4 & 3.4M \\
Optimized V2 & EfficientNet-B0  & 18.5 & 92.1 & 5.3M \\
FoodBridge Core & Custom Pruned VGG & 9.8 & 94.6 & 4.1M \\
\midrule
\multicolumn{5}{l}{\footnotesize \textit{Note:} Latency measured on Snapdragon 8 Gen 2 at batch size 1.} \\
\bottomrule
\end{tabularx}
\end{table}
```

### B. Figures with Dynamic Sizing & Subfigures
```latex
\begin{figure}[htbp]
    \centering
    \begin{subfigure}[b]{0.48\textwidth}
        \centering
        \includegraphics[width=\textwidth]{figures/screen_before.png}
        \caption{Before Fix (Legacy View)}
        \label{fig:screen_before}
    \end{subfigure}
    \hfill
    \begin{subfigure}[b]{0.48\textwidth}
        \centering
        \includegraphics[width=\textwidth]{figures/screen_after.png}
        \caption{After Fix (Live Sync Active)}
        \label{fig:screen_after}
    \end{subfigure}
    \caption{Multi-Device Live Sync Verification Across Device Nodes}
    \label{fig:sync_comparison}
\end{figure}
```

### C. Pseudocode & Algorithms with `algorithm2e`
```latex
\usepackage[ruled,vlined,linesnumbered]{algorithm2e}

\begin{algorithm}[H]
\DontPrintSemicolon
\SetAlgoLined
\KwIn{Donation item $D$, Volunteer profile $V$, NGO request list $R$}
\KwOut{Matched dispatch assignment $A$}
\BlankLine
\For{each request $r \in R$}{
    \If{$r.\text{type} == D.\text{type} \land \text{Distance}(r, D) \le 5\,\text{km}$}{
        \tcp{Optimistic claim verification}
        ReserveItem($D$, $r$)\;
        $A \leftarrow \text{AssignNearestVolunteer}(V, D, r)$\;
        \Return $A$\;
    }
}
\Return \textbf{null}\;
\caption{Dynamic Realtime Food Surplus Dispatch}
\label{algo:dispatch}
\end{algorithm}
```

---

## 6. Common LaTeX Traps & How to Avoid Them

| Trap | Symptom | Solution |
|------|---------|----------|
| **Unescaped Characters** | `!` `Missing $ inserted` or syntax error | Escape reserved chars: `\_`, `\%`, `\&`, `\#`, `\$`, `\{`, `\}` |
| **Overfull `\hbox`** | Text overflows right page margin | Wrap long URLs in `\url{...}`, add hyphenation hints `re\-dis\-tri\-bu\-tion`, or use `\sloppy` |
| **Missing References (`??`)** | `??` appears in text instead of citation or figure number | Re-run compiler (LaTeX requires 2 to 3 passes to build `.aux` cross-references) |
| **Floating Figures Disappearing** | Figures float to the very end of document | Use `\begin{figure}[htbp]` or `\usepackage{float}` with `[H]` to anchor strictly |
| **Equation in Prose** | Dollar signs messing formatting | Use single `$...$` for inline math, `\[...\]` or `\begin{equation}` for block math |

---

## 7. Compilation & Export Workflows

### Option 1: Automated Local Compilation Script
Use the built-in python compilation script provided with this skill:
```bash
python "C:\Users\DELL\.gemini\config\skills\latex-report-specialist\scripts\compile_latex.py" --file main.tex
```
The script automatically:
1. Detects available compilers (`latexmk`, `pdflatex`, `xelatex`, `tectonic`).
2. Executes the required passes (Pass 1 -> BibTeX -> Pass 2 -> Pass 3) to link all references and table of contents.
3. Parses `.log` files to surface human-readable line numbers for any syntax errors.
4. Cleans intermediate junk files (`.aux`, `.bbl`, `.blg`, `.out`, `.toc`, `.lof`, `.lot`).

### Option 2: Overleaf One-Click Ready
When preparing a report for Overleaf:
- Ensure `main.tex` is in the root directory.
- All image assets are placed in `figures/`.
- Use relative paths like `\includegraphics{figures/photo.png}`.
- Create a `.zip` archive containing the directory contents and upload directly to Overleaf.

### Option 3: Installing Local Compilers on Windows
If local PDF generation is required:
```powershell
# Lightweight MiKTeX
winget install MiKTeX.MiKTeX

# Or TinyTeX (ultra lightweight, downloads packages on demand)
# via R or standalone binary
```

---

## 8. Verification Checklist Before Final Submission

- [ ] Title page formatting adheres to institutional / corporate guidelines.
- [ ] No `??` anywhere in the generated PDF (all `\ref` and `\cite` are resolved).
- [ ] Table of contents, List of Figures, and List of Tables page numbers match actual pages.
- [ ] All tables use `booktabs` (`\toprule`, `\midrule`, `\bottomrule`) with zero vertical bars.
- [ ] All equations are properly numbered or grouped using `align`.
- [ ] All code snippets have readable font sizes and appropriate line wrapping.
- [ ] PDF metadata (author, title) is cleanly populated in `hyperref`.
- [ ] Margins leave adequate room (1.25 inch minimum on inner edge) for binding.
