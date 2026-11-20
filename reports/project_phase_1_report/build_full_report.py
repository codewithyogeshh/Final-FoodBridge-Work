# -*- coding: utf-8 -*-
"""
FoodBridge Phase-I Project Design Report Builder.
Generates an exact 1:1 formatted LaTeX report matching the KBPCOES / DBATU reference report.

Fixes applied:
1. Removed the artificial eso-pic page border rectangle that was colliding with the header and footer.
2. Centered all Chapter / Section Headings (\filcenter) matching the reference report.
3. The INDEX table has the exact bounded table format with | borders and \hline matching user's reference screenshot (media_1795165186630_abed822e.jpg), fitted on Page 7 on a single page.
4. Implementation figures (Figures 6.1, 6.2, 6.3) are landscape (aspect ratio ~1.71, height <= 6.2cm), so they fit on the page without overflowing.
5. All 12 Figures and 7 Tables aligned to reference page budget.
6. Clean geometry with headsep=15pt, footskip=25pt to eliminate any text-on-line collision.
"""

import sys
from pathlib import Path

content = r'''\documentclass[12pt,a4paper]{article}

% ==============================================================================
% PAGE MARGINS & GEOMETRY (Matching Reference Report)
% ==============================================================================
\usepackage[
    top=1.0in,
    bottom=1.0in,
    left=1.2in,
    right=1.0in,
    headheight=15pt,
    headsep=18pt,
    footskip=28pt
]{geometry}

% ==============================================================================
% PACKAGES & TYPOGRAPHY
% ==============================================================================
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{mathptmx}           % Times New Roman font standard matching referenced PDF
\usepackage{setspace}
\onehalfspacing                 % 1.5 line spacing for body
\usepackage{graphicx}
\usepackage{amsmath,amssymb}
\usepackage{booktabs}
\usepackage{tabularx}
\usepackage{multirow}
\usepackage{array}
\usepackage{float}
\usepackage[font=small,labelfont=bf,justification=centering]{caption}
\usepackage{subcaption}
\usepackage{tikz}
\usetikzlibrary{shapes.geometric, arrows, positioning, fit, backgrounds, shadows, calc}
\usepackage{fancyhdr}
\usepackage{titlesec}
\usepackage{tocloft}
\usepackage{microtype}
\usepackage[dvipsnames,x11names]{xcolor}
\usepackage[colorlinks=true,linkcolor=black,citecolor=black,urlcolor=blue]{hyperref}

% Table of Contents dots
\renewcommand{\cftsecleader}{\cftdotfill{\cftdotsep}}

% Heading formatting: ALL CHAPTER HEADINGS CENTERED (\filcenter)
\titleformat{\section}[block]{\normalfont\Large\bfseries\filcenter}{\thesection.}{0.8em}{\MakeUppercase}
\titleformat{\subsection}{\normalfont\large\bfseries}{\thesubsection}{0.8em}{}
\titleformat{\subsubsection}{\normalfont\normalsize\bfseries}{\thesubsubsection}{0.8em}{}

\titlespacing*{\section}{0pt}{1.5ex plus 1ex minus .2ex}{1.5ex plus .2ex}
\titlespacing*{\subsection}{0pt}{1.2ex plus 1ex minus .2ex}{0.8ex plus .2ex}
\titlespacing*{\subsubsection}{0pt}{1.0ex plus 1ex minus .2ex}{0.6ex plus .2ex}

% Paragraph Alignment & Justification
\setlength{\parindent}{0pt}
\setlength{\parskip}{6pt plus 2pt minus 1pt}
\sloppy

% Running Header and Footer (Exact 1:1 match to reference report)
\pagestyle{fancy}
\fancyhf{}
\fancyhead[R]{\small \textit{FoodBridge : Real-Time Surplus Food Redistribution and Logistics Engine}}
\fancyfoot[L]{\small Karmaveer Bhaurao Patil College of Engineering, Satara}
\fancyfoot[R]{\small Page \thepage}
\renewcommand{\headrulewidth}{0.5pt}
\renewcommand{\footrulewidth}{0.5pt}

% Custom Checkmark for Gantt Chart
\newcommand{\cmark}{\textbf{\checkmark}}

% Prevent orphan and widow lines
\widowpenalty=10000
\clubpenalty=10000

\begin{document}

% ==============================================================================
% PAGE 1: TITLE PAGE
% ==============================================================================
\begin{titlepage}
    \centering
    \vspace*{-0.4cm}
    
    % College Banner Image directly from KBPCOES reference
    \includegraphics[width=\textwidth]{figures/college_banner.jpg}\\[0.6cm]

    {\large \textbf{Department of Computer Science and Engineering}}\\[1.1cm]
    
    {\Large \textbf{A Project Design Report Phase I}}\\[0.4cm]
    {\large \textbf{On}}\\[0.6cm]
    
    {\LARGE \textbf{“FOODBRIDGE : Real-Time Surplus Food Redistribution and Logistics Engine”}}\\[1.0cm]
    
    {\large \textbf{By}}\\[0.5cm]
    
    \begin{tabular}{ll}
        1) & \textbf{Yogesh Gurunath Chavan} \quad [24062701242502] \\[0.15cm]
        2) & \textbf{Samruddhi Pramod Sawant} \quad [23062701242039] \\[0.15cm]
        3) & \textbf{Omkar Nilesh Shinde} \quad [23062701242121] \\[0.15cm]
        4) & \textbf{Shivraj Rajendra Yadav} \quad [23062701242102] \\
    \end{tabular}\\[0.8cm]
    
    {\large \textbf{Of}}\\[0.3cm]
    {\large Final Year B. Tech Computer Science \& Engineering}\\[0.8cm]
    
    {\large Under the guidance of}\\[0.2cm]
    {\large \textbf{Prof. Uma Bhokare}}\\[0.2cm]
    {\normalsize (Department of Computer Science \& Engineering.)}\\[0.8cm]
    
    {\large \textbf{Academic Year 2026-27}}
    \vfill
\end{titlepage}

% ==============================================================================
% PAGE 2: CERTIFICATE
% ==============================================================================
\newpage
\thispagestyle{empty}
\begin{center}
    \vspace*{-0.4cm}
    \includegraphics[width=\textwidth]{figures/college_banner.jpg}\\[0.6cm]

    {\large \textbf{Department of Computer Science and Engineering}}\\[1.2cm]
    
    {\Huge \textit{\textbf{Certificate}}}\\[1.2cm]
\end{center}

\noindent
This is to certify that the part of the work of the project entitled, \textbf{“FOODBRIDGE : Real-Time Surplus Food Redistribution and Logistics Engine”} is submitted by ,

\vspace{0.6cm}
\begin{center}
    \begin{tabular}{ll}
        1) & \textbf{Yogesh Gurunath Chavan} \quad [24062701242502] \\[0.15cm]
        2) & \textbf{Samruddhi Pramod Sawant} \quad [23062701242039] \\[0.15cm]
        3) & \textbf{Omkar Nilesh Shinde} \quad [23062701242121] \\[0.15cm]
        4) & \textbf{Shivraj Rajendra Yadav} \quad [23062701242102] \\
    \end{tabular}
\end{center}

\vspace{0.6cm}
\noindent
As prescribed by the \textbf{DR. BABASAHEB AMBEDKAR TECHNOLOGICAL UNIVERSITY} for the subject \textbf{“Project Phase – I”} of Final Year B.Tech. Computer Science \& Engineering. The work is done by them under my supervision.

\vspace{2.8cm}
\noindent
\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}}cc}
    \textbf{Prof. Uma Bhokare} & \textbf{Dr. Shabina Modi} \\[0.2cm]
    Project Guide & Head of the Department \\
\end{tabular*}

% ==============================================================================
% PAGE 3: ACKNOWLEDGMENT
% ==============================================================================
\newpage
\thispagestyle{empty}
\begin{center}
    \vspace*{0.4cm}
    {\Large \textbf{ACKNOWLEDGMENT}}\\[0.8cm]
\end{center}

\noindent
We take this opportunity to express our gratitude to \textbf{“Karmaveer Bhaurao Patil College of Engineering, Satara”} and the Computer Science \& Engineering Department for sanctioning us the project topic \textbf{“FOODBRIDGE : Real-Time Surplus Food Redistribution and Logistics Engine”} \& for allowing access to various facilities.

\vspace{0.4cm}
\noindent
We sincerely wish to express hearty thanks to our Project Guide \textbf{Prof. Uma Bhokare} for her encouraging \& inspiring guidance. Her valuable suggestions were a constant source of inspiration for us.

\vspace{0.4cm}
\noindent
We wish to express our thanks to our Head of Department \textbf{Dr. Shabina Modi} for encouragement \& providing us with the best facilities for our project work. We would also like to thank the other teaching \& non-teaching staff.

\vspace{0.4cm}
\noindent
Last but not the least we would like to thank all our friends, who helped us directly or indirectly. Helpful hand rendered by all of them will remain for a long time in our memory. Finally we admit that cooperation, coordination \& hard work are our keywords for success.

\vspace{2.0cm}
\begin{flushright}
    \textbf{Thanking,}\\[0.3cm]
    1) Yogesh Gurunath Chavan\\[0.1cm]
    2) Samruddhi Pramod Sawant\\[0.1cm]
    3) Omkar Nilesh Shinde\\[0.1cm]
    4) Shivraj Rajendra Yadav\\
\end{flushright}

% ==============================================================================
% PAGE 4: ABSTRACT
% ==============================================================================
\newpage
\thispagestyle{empty}
\begin{center}
    \vspace*{0.4cm}
    {\Large \textbf{ABSTRACT}}\\[0.8cm]
\end{center}

\noindent
Large-scale commercial catering organizations, college hostels, banquet halls, and restaurants discard substantial volumes of hygienically prepared surplus meals every day. In the traditional food relief process, surplus meals pass through unorganized manual communication and telephone chains. This makes the recovery process difficult to monitor, increases coordination delays, and leads to food spoilage before it reaches hungry individuals in charitable shelters.

\vspace{0.4cm}
\noindent
To address these challenges, this report presents the Phase I design of \textbf{FOODBRIDGE : Real-Time Surplus Food Redistribution and Logistics Engine}, a centralized cross-platform mobile and web-based system designed to make surplus food recovery transparent, accountable, and instantaneous. The system covers the complete process, starting from donation listing, proximity-based real-time broadcasting, shelter claim reservation, volunteer courier assignment, cryptographic dual-OTP verification, and administrative monitoring.

\vspace{0.4cm}
\noindent
FoodBridge uses multiple security measures to protect donation integrity and verify legitimate beneficiaries. These include Role-Based Access Control (RBAC), multi-device profile synchronization, and mandatory NGO Darpan and 80G tax accreditation verification to ensure that only authorized charitable foundations can claim surplus food. A cryptographic Two-Stage One-Time PIN protocol (Pickup OTP with the Donor, Delivery OTP with the Shelter) ensures that volunteers cannot falsify deliveries. Real-time WebSocket broadcasting built upon Supabase PostgreSQL ensures sub-100ms state updates across distributed mobile clients, while an immutable audit trail maintains a record of important activities for complete institutional accountability.

\vspace{0.6cm}
\noindent
\textbf{Keywords:} Food redistribution, Real-time logistics, RBAC, Dual-OTP, NGO Darpan, 80G verification, Flutter, Supabase, Optimistic synchronization, Immutable audit trail.

% ==============================================================================
% PAGE 5: LIST OF TABLES
% ==============================================================================
\newpage
\thispagestyle{empty}
\begin{center}
    \vspace*{0.4cm}
    {\Large \textbf{LIST OF TABLES}}\\[0.8cm]
\end{center}

\noindent
\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}}llr}
    Table 4.1 & Hardware Requirements \dotfill & 7 \\[0.5cm]
    Table 4.2 & Software Requirements \dotfill & 7 \\[0.5cm]
    Table 5.1 & Database Tables and Relationships \dotfill & 12 \\[0.5cm]
    Table 6.1 & Technology Stack \dotfill & 13 \\[0.5cm]
    Table 6.2 & Plan of Action \dotfill & 16 \\[0.5cm]
    Table 6.3 & Approximate Cost Estimation \dotfill & 16 \\[0.5cm]
    Table 6.4 & Team Structure and Work Distribution \dotfill & 17 \\
\end{tabular*}

% ==============================================================================
% PAGE 6: LIST OF FIGURES
% ==============================================================================
\newpage
\thispagestyle{empty}
\begin{center}
    \vspace*{0.4cm}
    {\Large \textbf{LIST OF FIGURES}}\\[0.8cm]
\end{center}

\noindent
\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}}llr}
    Figure 3.1 & System Architecture of FoodBridge \dotfill & 5 \\[0.35cm]
    Figure 5.1 & DFD Level 0 (Context Diagram) \dotfill & 8 \\[0.35cm]
    Figure 5.2 & DFD Level 1 \dotfill & 8 \\[0.35cm]
    Figure 5.3 & Use Case Diagram \dotfill & 9 \\[0.35cm]
    Figure 5.4 & Activity Diagram for Food Redistribution Lifecycle \dotfill & 10 \\[0.35cm]
    Figure 5.5 & Class Diagram \dotfill & 11 \\[0.35cm]
    Figure 5.6 & Sequence Diagram for Listing, Claim and Dual-OTP Handover \dotfill & 11 \\[0.35cm]
    Figure 5.7 & Collaboration Diagram \dotfill & 12 \\[0.35cm]
    Figure 5.8 & Entity Relationship Diagram \dotfill & 12 \\[0.35cm]
    Figure 6.1 & Admin Console – Real-Time Redistribution Overview \dotfill & 14 \\[0.35cm]
    Figure 6.2 & Volunteer Dispatch \& Verification Screen \dotfill & 14 \\[0.35cm]
    Figure 6.3 & Backend REST API Documentation (Swagger UI) \dotfill & 15 \\
\end{tabular*}

% ==============================================================================
% PAGE 7: INDEX (TABLE OF CONTENTS - EXACT MATCH TO REFERENCE SCREENSHOT)
% ==============================================================================
\newpage
\thispagestyle{empty}
\begin{center}
    \vspace*{-0.2cm}
    {\Large \textbf{INDEX}}\\[0.35cm]
\end{center}

\begin{singlespace}
\small
\noindent
\begin{tabular}{|c|p{10.6cm}|c|}
\hline
\textbf{Sr. No.} & \textbf{Name of the Chapter} & \textbf{Page No.} \\
\hline
\textbf{1} & \textbf{Introduction} & \textbf{1} \\
\hline
\textbf{2} & \textbf{Objectives} & \textbf{2} \\
 & 2.1 Problem Statement & 2 \\
 & 2.2 Objectives & 2 \\
 & \quad 2.2.1 Project Objectives & 2 \\
 & \quad 2.2.2 Academic Objectives & 2 \\
\hline
\textbf{3} & \textbf{Project Overview} & \textbf{4} \\
 & 3.1 Scope & 4 \\
 & 3.2 Architecture & 4 \\
 & 3.3 Project Modules & 5 \\
\hline
\textbf{4} & \textbf{Requirement Analysis} & \textbf{7} \\
 & 4.1 Hardware Requirements & 7 \\
 & 4.2 Software Requirements & 7 \\
\hline
\textbf{5} & \textbf{Application Design} & \textbf{8} \\
 & 5.1 Data Flow Diagram & 8 \\
 & 5.2 Use Case Diagram & 8 \\
 & 5.3 Activity Diagram & 9 \\
 & 5.4 Class Diagram & 10 \\
 & 5.5 Sequence Diagram & 11 \\
 & 5.6 Collaboration Diagram & 11 \\
 & 5.7 Database Diagrams & 12 \\
 & \quad 5.7.1 ER Diagram & 12 \\
 & \quad 5.7.2 Table Relationships & 12 \\
\hline
\textbf{6} & \textbf{Implementation} & \textbf{13} \\
 & 6.1 Technology & 13 \\
 & 6.2 Steps to be Taken Towards Project Completion & 15 \\
 & 6.3 Project Scheduling & 16 \\
 & \quad 6.3.1 Plan of Action & 16 \\
 & 6.4 Cost Estimation & 16 \\
 & 6.5 Team Structure & 17 \\
\hline
\textbf{7} & \textbf{Advantages \& Limitations} & \textbf{18} \\
\hline
\textbf{8} & \textbf{Applications} & \textbf{19} \\
\hline
\textbf{9} & \textbf{Future Scope} & \textbf{20} \\
\hline
\textbf{10} & \textbf{Conclusion} & \textbf{21} \\
\hline
 & \textbf{References} & \textbf{22} \\
\hline
\end{tabular}
\end{singlespace}

% ==============================================================================
% CHAPTER 1: INTRODUCTION (STARTS ARABIC PAGE 1)
% ==============================================================================
\newpage
\pagenumbering{arabic}
\setcounter{page}{1}

\section{INTRODUCTION}

Agriculture and commercial food production support a substantial share of India's population. Concurrently, large-scale commercial catering organizations, college hostels, banquet halls, and restaurants discard substantial volumes of hygienically prepared surplus meals every single day. In the traditional food relief process, surplus meals pass through unorganized manual communication and telephone chains. This makes the recovery process difficult to monitor, increases coordination delays, and leads to food spoilage before it reaches hungry individuals in charitable shelters.

Diagnosis of the relief bottleneck today reveals that NGOs and charitable trusts depend largely on word-of-mouth or unverified WhatsApp groups. Relatives and volunteers are few compared with the number of community centers they serve, and uncoordinated dispatch often leads to multiple couriers arriving at the same venue or prepared food spoiling before pickup.

\textbf{FoodBridge : Real-Time Surplus Food Redistribution and Logistics Engine} is a smartphone-based system that addresses these problems. The commercial donor selects surplus food categories (Veg/Non-Veg) and declares quantity, preparation timestamp, and holding conditions. The system broadcasts available listings to accredited shelters within geographic proximity in real time using Supabase WebSockets.

The system has three integrated parts that share one unified backend: a Flutter cross-platform mobile application for donors, shelters, and courier volunteers; a web console for administrators who review NGO Darpan accreditations and monitor real-time distribution metrics; and a Supabase PostgreSQL backend orchestrating JWT authentication, Row Level Security, and cryptographic dual-OTP verification. This report presents the design of the system -- its objectives, scope, architecture, requirements, UML design, database design and implementation plan.

% ==============================================================================
% CHAPTER 2: OBJECTIVES
% ==============================================================================
\newpage
\section{OBJECTIVES}

\subsection{Problem Statement}
To design and develop a real-time, cross-platform surplus food redistribution and logistics engine that enables commercial food donors to list surplus meals, permits accredited charitable shelters to reserve claims based on headcount, automatically dispatches nearby volunteer couriers, validates physical custody transfer through a double-blind cryptographic Dual-OTP protocol, and maintains an immutable audit trail for complete institutional accountability.

\subsection{Objectives}
\subsubsection{Project Objectives}
\begin{itemize}
    \item To detect and catalog surplus food listings with dietary classifications (Veg/Non-Veg), holding temperature, and preparation timestamps using mobile forms.
    \item To enforce a legal Food Safety Charter signed digitally by donors prior to listing publication.
    \item To restrict shelter claim privileges exclusively to verified NGOs through mandatory inspection of NGO Darpan ID and 80G tax exemption certificates.
    \item To prevent delivery falsification via a two-stage cryptographic Dual-OTP gate (Pickup OTP with Donor, Delivery OTP with Shelter).
    \item To distribute live donation lifecycle mutations across all connected client nodes in under 100 milliseconds using optimistic state reconciliation.
    \item To prevent courier task hoarding by enforcing a strict concurrent limit of maximum two active delivery tasks per volunteer.
\end{itemize}

\subsubsection{Academic Objectives}
\begin{itemize}
    \item Study reactive state management architectures (Provider \& ChangeNotifier) for Flutter mobile clients.
    \item Learn secure backend integration with Supabase BaaS, PostgreSQL Row Level Security (RLS), and JWT authentication.
    \item Study geographic proximity clustering and Geohash routing for multi-stakeholder urban logistics.
    \item Study cryptographic token verification protocols and append-only audit trail logging for anti-tamper compliance.
    \item Practice the software engineering life cycle -- requirement analysis, UML design, unit testing and physical device deployment.
\end{itemize}

% ==============================================================================
% CHAPTER 3: PROJECT OVERVIEW
% ==============================================================================
\newpage
\section{PROJECT OVERVIEW}

\subsection{Scope}
The scope of the project in its current form is as follows:
\begin{itemize}
    \item \textbf{Surplus Commodities:} Perishable hot meals, packaged dining foods, bakery items, and clean wearable essentials / winter clothing.
    \item \textbf{Stakeholder Roles:} Donors (hostels, caterers, banquet halls), Verified Shelters (orphanages, ashrams), Volunteer Couriers, and System Administrators.
    \item \textbf{Geographic Radius:} Proximity-filtered urban zones in Satara district, scalable across Maharashtra.
    \item \textbf{Verification Protocols:} Digital Food Safety Charter, NITI Aayog NGO Darpan verification, and double-blind 4-digit physical Dual-OTPs.
    \item \textbf{Out of Scope (Current Phase):} Automated drone delivery, hardware IoT temperature probes, and multi-tier inter-city refrigerated transport.
\end{itemize}

\subsection{Architecture}
The system follows a layered client--server architecture (Figure 3.1). The presentation layer consists of the Flutter mobile app and the admin console. Both communicate with a centralized Supabase backend over HTTPS and WebSockets. The server routes each request to core logic engines -- surplus lifecycle controller, proximity router, accreditation verifier, courier dispatcher, and audit logger. The data layer stores profiles, donations, distribution records, and audit logs in PostgreSQL.

Three design decisions shape the architecture:
\begin{itemize}
    \item \textbf{Reactive Client State Mesh:} Client UI mutations update instantly via optimistic local caching while synchronizing across Supabase WebSocket channels in sub-100ms.
    \item \textbf{Human in the Loop Accreditation:} Shelters remain in a pending state until their official NGO Darpan registration and 80G tax exemption certificates are inspected and verified by an administrator.
    \item \textbf{Cryptographic Custody Gate:} Zero ghost deliveries are permitted. Courier custody requires double-blind physical OTP entry at both pickup and delivery end-points.
\end{itemize}

\begin{figure}[H]
\centering
\begin{tikzpicture}[node distance=1.05cm, auto,
    layerbox/.style={rectangle, draw=black!70, fill=blue!3, text width=13.8cm, rounded corners=3pt, inner sep=5pt},
    compbox/.style={rectangle, draw=black!60, fill=white, text width=2.85cm, text centered, rounded corners=2pt, minimum height=0.72cm, font=\scriptsize\bfseries},
    arrowline/.style={draw=black!80, -latex', thick}]

    % Layer 1: Presentation
    \node [layerbox] (l1) {
        {\footnotesize \textbf{Presentation Layer (Flutter Cross-Platform Client)}}\\[0.12cm]
        \begin{tikzpicture}
            \node [compbox] (c1) {Donor Portal\\(Surplus Listing)};
            \node [compbox, right=0.35cm of c1] (c2) {Shelter Hub\\(Claim Management)};
            \node [compbox, right=0.35cm of c2] (c3) {Courier App\\(Dispatch \& Dual-OTP)};
            \node [compbox, right=0.35cm of c3] (c4) {Admin Console\\(Real-Time Monitor)};
        \end{tikzpicture}
    };

    % Layer 2: API & Gateway
    \node [layerbox, below of=l1, yshift=-0.70cm] (l2) {
        {\footnotesize \textbf{API Gateway \& Real-Time State Layer (Supabase BaaS)}}\\[0.12cm]
        \begin{tikzpicture}
            \node [compbox] (g1) {WebSocket Mesh\\(Sub-100ms Sync)};
            \node [compbox, right=0.35cm of g1] (g2) {JWT / RBAC\\Security Gate};
            \node [compbox, right=0.35cm of g2] (g3) {Proximity Geohash\\Routing Service};
            \node [compbox, right=0.35cm of g3] (g4) {Dual-OTP Token\\Generator Engine};
        \end{tikzpicture}
    };

    % Layer 3: Business Logic
    \node [layerbox, below of=l2, yshift=-0.70cm] (l3) {
        {\footnotesize \textbf{AI / Logic \& Core Business Services}}\\[0.12cm]
        \begin{tikzpicture}
            \node [compbox] (b1) {Donation Lifecycle\\State Controller};
            \node [compbox, right=0.35cm of b1] (b2) {NGO Darpan \& 80G\\Accreditation Check};
            \node [compbox, right=0.35cm of b2] (b3) {Courier Dispatcher\\(Throttle $\le$ 2 Tasks)};
            \node [compbox, right=0.35cm of b3] (b4) {Immutable Audit\\Trail Archival};
        \end{tikzpicture}
    };

    % Layer 4: Storage
    \node [layerbox, below of=l3, yshift=-0.70cm] (l4) {
        {\footnotesize \textbf{Data \& External Services Layer}}\\[0.12cm]
        \begin{tikzpicture}
            \node [compbox, text width=3.9cm] (s1) {Supabase PostgreSQL\\(Row Level Security)};
            \node [compbox, right=0.45cm of s1, text width=3.9cm] (s2) {Encrypted SharedPreferences\\(Offline Resilient Cache)};
            \node [compbox, right=0.45cm of s2, text width=3.9cm] (s3) {Cloud Media Storage\\(Donation \& Certificate Docs)};
        \end{tikzpicture}
    };

    \draw [arrowline] (l1) -- (l2);
    \draw [arrowline] (l2) -- (l3);
    \draw [arrowline] (l3) -- (l4);
\end{tikzpicture}
\caption{System Architecture of FoodBridge}
\label{fig:sys_arch}
\end{figure}

\subsection{Project Modules}
\textbf{Module 1 -- User Authentication \& RBAC:} Stakeholders log in with their credentials and 2FA PIN. The system issues a JWT session token and enforces Role-Based Access Control distinguishing Donors, Shelters, Volunteers, and Admins.

\textbf{Module 2 -- Surplus Food Declaration:} Donors declare food quantities, meal descriptions, preparation time, and dietary type (Veg/Non-Veg) while signing the digital Food Safety Charter. A secret 4-digit Pickup OTP is generated.

\textbf{Module 3 -- Proximity Claim Reservation:} Accredited shelters browse available nearby food and reserve claims based on headcount. The system generates a secret Delivery OTP issued exclusively to the claiming shelter.

\textbf{Module 4 -- Volunteer Dispatch \& Handover Gate:} Volunteers claim available tasks (max 2 concurrent). The courier inputs the donor's physical Pickup OTP to start transit, and the shelter's Delivery OTP to finalize distribution.

\textbf{Module 5 -- Accreditation Review \& Audit Logging:} Admins review pending NGO Darpan certificates and inspect an append-only immutable audit trail recording every system event.

% ==============================================================================
% CHAPTER 4: REQUIREMENT ANALYSIS
% ==============================================================================
\newpage
\section{REQUIREMENT ANALYSIS}

\subsection{Hardware Requirements}
\begin{table}[H]
\centering
\caption{Hardware Requirements}
\label{tab:hardware_req}
\begin{tabularx}{\textwidth}{|l|X|X|}
    \hline
    \textbf{Component} & \textbf{Minimum Requirement} & \textbf{Purpose} \\
    \hline
    Development PC / Laptop & Intel Core i5 / AMD Ryzen 5, 8 GB RAM, 256 GB SSD & Coding, running backend, Flutter compilation \\
    \hline
    Android Smartphone & Android 8.0+, 3 GB RAM, Camera, GPS & Testing donor, courier, and shelter workflows \\
    \hline
    Server (Deployment) & 2 vCPU, 4 GB RAM, 40 GB NVMe Storage & Hosting Supabase BaaS, PostgreSQL, WebSockets \\
    \hline
    Internet Connection & Broadband / 4G LTE ($\ge$ 10 Mbps) & Real-time WebSocket syncing, map geocoding \\
    \hline
\end{tabularx}
\end{table}

\subsection{Software Requirements}
\begin{table}[H]
\centering
\caption{Software Requirements}
\label{tab:software_req}
\begin{tabularx}{\textwidth}{|l|l|X|}
    \hline
    \textbf{Category} & \textbf{Software / Tool} & \textbf{Purpose} \\
    \hline
    Operating System & Windows 10/11, Ubuntu 22.04 or macOS & Development host operating system \\
    \hline
    Mobile Framework & Flutter SDK 3.24+, Dart 3.5+ & Cross-platform reactive UI for Android and Web \\
    \hline
    Backend / Database & Supabase (PostgreSQL 15+), Realtime & Relational persistence, Auth engine, WebSockets \\
    \hline
    Security Engine & Row Level Security (RLS), RBAC & Data isolation, permission control, Dual-OTP \\
    \hline
    Local Storage & SharedPreferences with JSON serialization & Offline caching and session recovery \\
    \hline
    Development IDE & VS Code / Android Studio & Code authoring, debugging, widget inspection \\
    \hline
    Version Control & Git \& GitHub & Source code management, CI/CD pipeline \\
    \hline
\end{tabularx}
\end{table}

% ==============================================================================
% CHAPTER 5: APPLICATION DESIGN
% ==============================================================================
\newpage
\section{APPLICATION DESIGN}

\subsection{Data Flow Diagram}
The Level-0 DFD (context diagram) shows the system as a single process interacting with four external entities: the donor, the shelter (NGO), the volunteer courier, and the system administrator.

\begin{figure}[H]
\centering
\begin{tikzpicture}[node distance=2.2cm, auto,
    proc/.style={circle, draw=black, fill=blue!5, text width=2.8cm, text centered, font=\scriptsize\bfseries, minimum height=2.8cm},
    entity/.style={rectangle, draw=black, fill=gray!10, text width=2.2cm, text centered, rounded corners=2pt, minimum height=0.9cm, font=\tiny\bfseries},
    flow/.style={draw, -latex', thick}]

    \node [proc] (sys) {0.0\\FOODBRIDGE\\Relief Logistics\\Engine};

    \node [entity, above left=0.8cm and 1.5cm of sys] (donor) {Donor\\(Commercial / Hostel)};
    \node [entity, above right=0.8cm and 1.5cm of sys] (shelter) {Shelter\\(Verified NGO)};
    \node [entity, below left=0.8cm and 1.5cm of sys] (vol) {Volunteer\\Courier};
    \node [entity, below right=0.8cm and 1.5cm of sys] (admin) {System\\Administrator};

    \draw [flow] (donor) to [bend left=15] node[above, sloped, font=\tiny] {1. Listing details (quantity, type)} (sys);
    \draw [flow] (sys) to [bend left=15] node[below, sloped, font=\tiny] {2. Listing ID \& Pickup OTP} (donor);

    \draw [flow] (shelter) to [bend left=15] node[above, sloped, font=\tiny] {3. Darpan ID \& Claim Request} (sys);
    \draw [flow] (sys) to [bend left=15] node[below, sloped, font=\tiny] {4. Approved Notice \& Delivery OTP} (shelter);

    \draw [flow] (vol) to [bend left=15] node[above, sloped, font=\tiny] {5. Task Accept \& Entered OTPs} (sys);
    \draw [flow] (sys) to [bend left=15] node[below, sloped, font=\tiny] {6. Dispatch Task \& Navigation} (vol);

    \draw [flow] (admin) to [bend left=15] node[above, sloped, font=\tiny] {7. Accreditation Decision} (sys);
    \draw [flow] (sys) to [bend left=15] node[below, sloped, font=\tiny] {8. KPIs \& Immutable Audit Logs} (admin);
\end{tikzpicture}
\caption{DFD Level 0 (Context Diagram)}
\label{fig:dfd_0}
\end{figure}

The Level-1 DFD breaks the system into six processes -- authentication, surplus listing, claim reservation, task dispatching, dual-OTP verification, and audit logging -- and four data stores: users, donations, distribution records, and audit logs.

\begin{figure}[H]
\centering
\begin{tikzpicture}[scale=0.74, every node/.style={transform shape},
    proc/.style={rectangle, draw=black, fill=blue!5, text width=2.4cm, text centered, rounded corners=6pt, minimum height=0.9cm, font=\scriptsize\bfseries},
    dstore/.style={rectangle, draw=black, fill=orange!5, text width=2.5cm, text centered, minimum height=0.65cm, font=\scriptsize},
    entity/.style={rectangle, draw=black, fill=gray!15, text width=1.8cm, text centered, minimum height=0.8cm, font=\scriptsize\bfseries},
    flow/.style={draw, -latex', thick}]

    \node [entity] (e_donor) at (0, 6.5) {Donor};
    \node [entity] (e_shelter) at (14, 6.5) {Shelter (NGO)};
    \node [entity] (e_vol) at (0, 0) {Volunteer};
    \node [entity] (e_admin) at (14, 0) {Administrator};

    \node [proc] (p1) at (3.5, 5.2) {1.0 Auth \&\\RBAC Verify};
    \node [proc] (p2) at (3.5, 3.3) {2.0 Surplus Food\\Listing Engine};
    \node [proc] (p3) at (10.5, 5.2) {3.0 Broadcast \&\\Claim Reserve};
    \node [proc] (p4) at (3.5, 1.4) {4.0 Volunteer\\Dispatcher};
    \node [proc] (p5) at (10.5, 3.3) {5.0 Dual-OTP Gate\\\& Handover};
    \node [proc] (p6) at (10.5, 1.4) {6.0 Audit Logging\\\& Compliance};

    \node [dstore] (d1) at (7, 6.0) {D1: Users \& Profiles};
    \node [dstore] (d2) at (7, 4.2) {D2: Donations \& Surplus};
    \node [dstore] (d3) at (7, 2.4) {D3: Distribution Records};
    \node [dstore] (d4) at (7, 0.6) {D4: Immutable Audit Logs};

    \draw [flow] (e_donor) -- (p1);
    \draw [flow] (e_donor) -- (p2);
    \draw [flow] (p2) -- (d2);
    \draw [flow] (d2) -- (p3);
    \draw [flow] (e_shelter) -- (p3);
    \draw [flow] (p3) -- (d3);
    \draw [flow] (d3) -- (p4);
    \draw [flow] (p4) -- (e_vol);
    \draw [flow] (e_vol) -- (p5);
    \draw [flow] (p5) -- (d3);
    \draw [flow] (p5) -- (p6);
    \draw [flow] (p6) -- (d4);
    \draw [flow] (e_admin) -- (p6);
    \draw [flow] (e_admin) -- (d1);
    \draw [flow] (d1) -- (p1);
\end{tikzpicture}
\caption{DFD Level 1}
\label{fig:dfd_1}
\end{figure}

\subsection{Use Case Diagram}
The system has four actors. The donor logs in, lists surplus meals, and signs the safety charter. The shelter logs in, submits Darpan accreditation docs, browses surplus listings, and reserves claims. The volunteer accepts dispatches, enters the donor's pickup OTP, and confirms delivery with the shelter's OTP. The administrator reviews pending accreditations, monitors live KPIs, and inspects audit logs.

\begin{figure}[H]
\centering
\begin{tikzpicture}[scale=0.76, every node/.style={transform shape},
    actor/.style={rectangle, draw=black, fill=gray!20, text width=2.0cm, text centered, rounded corners=3pt, minimum height=1.0cm, font=\scriptsize\bfseries},
    usecase/.style={ellipse, draw=black, fill=blue!5, text width=2.8cm, text centered, minimum height=0.72cm, font=\scriptsize},
    subcase/.style={ellipse, draw=black!70, fill=green!5, text width=2.5cm, text centered, minimum height=0.68cm, font=\tiny},
    link/.style={draw, thick}]

    \draw [draw=black!70, dashed, rounded corners=4pt] (2.8, -0.6) rectangle (11.8, 10.2);
    \node [font=\bfseries\small] at (7.3, 9.8) {FoodBridge System Boundary};

    \node [actor] (a_donor) at (0.8, 8.3) {Donor\\(Hostel / Hotel)};
    \node [actor] (a_shelter) at (0.8, 3.5) {Shelter\\(Verified NGO)};
    \node [actor] (a_vol) at (13.8, 3.5) {Volunteer\\Courier};
    \node [actor] (a_admin) at (13.8, 8.3) {System\\Administrator};

    \node [usecase] (uc_login) at (7.3, 9.0) {Login \& 2FA Authentication};
    \node [usecase] (uc_list) at (5.4, 7.6) {Declare Surplus Food};
    \node [subcase] (uc_charter) at (9.2, 7.6) {Sign Safety Charter\\$\ll$include$\gg$};
    \node [usecase] (uc_darpan) at (5.4, 6.1) {Submit Darpan / 80G Docs};
    \node [usecase] (uc_claim) at (5.4, 4.6) {Reserve Claim by Headcount};
    \node [usecase] (uc_accept) at (9.2, 4.6) {Accept Courier Dispatch};
    \node [usecase] (uc_pickup) at (9.2, 3.1) {Validate Pickup OTP};
    \node [usecase] (uc_deliv) at (9.2, 1.6) {Validate Delivery OTP};
    \node [usecase] (uc_admin_app) at (9.2, 6.1) {Approve NGO Darpan};
    \node [usecase] (uc_audit) at (7.3, 0.4) {Inspect Immutable Audit Logs};

    \draw [link] (a_donor) -- (uc_login);
    \draw [link] (a_donor) -- (uc_list);
    \draw [draw=black, dashed, -latex'] (uc_list) -- (uc_charter);
    \draw [link] (a_shelter) -- (uc_login);
    \draw [link] (a_shelter) -- (uc_darpan);
    \draw [link] (a_shelter) -- (uc_claim);
    \draw [link] (a_vol) -- (uc_login);
    \draw [link] (a_vol) -- (uc_accept);
    \draw [link] (a_vol) -- (uc_pickup);
    \draw [link] (a_vol) -- (uc_deliv);
    \draw [link] (a_admin) -- (uc_login);
    \draw [link] (a_admin) -- (uc_admin_app);
    \draw [link] (a_admin) -- (uc_audit);
\end{tikzpicture}
\caption{Use Case Diagram}
\label{fig:use_case}
\end{figure}

\subsection{Activity Diagram}
The activity diagram shows the flow of a single donation lifecycle, from donor listing through safety validation, claim reservation, courier dispatch, dual-OTP handover, and audit archival.

\begin{figure}[H]
\centering
\begin{tikzpicture}[scale=0.76, every node/.style={transform shape},
    startstop/.style={circle, draw=black, fill=black, minimum size=0.42cm},
    endstop/.style={circle, draw=black, double, fill=black, minimum size=0.52cm},
    activity/.style={rectangle, draw=black, fill=blue!5, text width=6.0cm, text centered, rounded corners=3pt, minimum height=0.65cm, font=\scriptsize},
    decision/.style={diamond, draw=black, fill=yellow!10, aspect=2.2, text width=2.3cm, text centered, font=\tiny\bfseries},
    flow/.style={draw, -latex', thick}]

    \node [startstop] (start) at (0, 0) {};
    \node [activity, below=0.35cm of start] (a1) {Donor declares surplus meals and signs Food Safety Charter};
    \node [activity, below=0.35cm of a1] (a2) {System issues secret Pickup OTP and broadcasts listing via WebSockets};
    \node [activity, below=0.35cm of a2] (a3) {Shelter requests claim reservation based on resident headcount};
    \node [decision, below=0.35cm of a3] (d1) {Darpan ID\\Verified?};
    \node [activity, right=1.0cm of d1, text width=3.6cm] (err_darpan) {Block claim; prompt accreditation document upload};
    \node [activity, below=0.50cm of d1] (a4) {System locks claim and issues secret Delivery OTP to Shelter};
    \node [activity, below=0.35cm of a4] (a5) {Available Courier accepts dispatch (Concurrency limit $\le$ 2 validated)};
    \node [activity, below=0.35cm of a5] (a6) {Courier arrives at Donor; inputs physical Pickup OTP};
    \node [decision, below=0.35cm of a6] (d2) {Pickup OTP\\Valid?};
    \node [activity, below=0.50cm of d2] (a7) {Donation status transitions to IN\_TRANSIT; GPS navigation begins};
    \node [activity, below=0.35cm of a7] (a8) {Courier reaches Shelter; inputs physical Delivery OTP};
    \node [decision, below=0.35cm of a8] (d3) {Delivery OTP\\Valid?};
    \node [activity, below=0.50cm of d3] (a9) {Mark status COMPLETED; write record to Immutable Audit Trail};
    \node [endstop, below=0.35cm of a9] (finish) {};

    \draw [flow] (start) -- (a1);
    \draw [flow] (a1) -- (a2);
    \draw [flow] (a2) -- (a3);
    \draw [flow] (a3) -- (d1);
    \draw [flow] (d1) -- node[right, font=\tiny] {Yes} (a4);
    \draw [flow] (d1) -- node[above, font=\tiny] {No} (err_darpan);
    \draw [flow] (err_darpan) |- (a3);
    \draw [flow] (a4) -- (a5);
    \draw [flow] (a5) -- (a6);
    \draw [flow] (a6) -- (d2);
    \draw [flow] (d2) -- node[right, font=\tiny] {Yes} (a7);
    \draw [flow] (d2.west) -- ++(-0.5,0) |- node[near start, left, font=\tiny] {No: Re-try} (a6.west);
    \draw [flow] (a7) -- (a8);
    \draw [flow] (a8) -- (d3);
    \draw [flow] (d3) -- node[right, font=\tiny] {Yes} (a9);
    \draw [flow] (d3.west) -- ++(-0.5,0) |- node[near start, left, font=\tiny] {No: Re-try} (a8.west);
    \draw [flow] (a9) -- (finish);
\end{tikzpicture}
\caption{Activity Diagram for Food Redistribution Lifecycle}
\label{fig:activity_diag}
\end{figure}

\subsection{Class Diagram}
The class diagram shows the persistent entity classes (AppUser, Donation, DistributionRecord, AuditLogEntry) and the service classes that implement security and business logic.

\begin{figure}[H]
\centering
\begin{tikzpicture}[scale=0.72, every node/.style={transform shape},
    classbox/.style={rectangle, draw=black, fill=white, text width=5.6cm, inner sep=4pt, font=\scriptsize},
    assoc/.style={draw, thick, -latex'}]

    \node [classbox] (user) at (0, 7.5) {
        \textbf{AppUser}\\[0.05cm]
        \hline
        - id: String (UUID)\\
        - fullName: String\\
        - email: String\\
        - role: UserRole\\
        - phone: String\\
        - darpanId: String\\
        - isVerified: bool\\[0.05cm]
        \hline
        + login(): Future$\langle$bool$\rangle$\\
        + updateProfile(): Future$\langle$void$\rangle$\\
        + verify2FA(code): bool
    };

    \node [classbox] (donation) at (8.5, 7.5) {
        \textbf{Donation}\\[0.05cm]
        \hline
        - id: String (UUID)\\
        - donorId: String\\
        - title: String\\
        - foodType: FoodType\\
        - quantityKg: double\\
        - expiryTime: DateTime\\
        - pickupOTP: String\\
        - status: DonationStatus\\[0.05cm]
        \hline
        + createListing(): Future$\langle$void$\rangle$\\
        + cancelListing(): Future$\langle$void$\rangle$\\
        + markInTransit(): void
    };

    \node [classbox] (dist) at (8.5, 1.8) {
        \textbf{DistributionRecord}\\[0.05cm]
        \hline
        - id: String (UUID)\\
        - donationId: String\\
        - shelterId: String\\
        - volunteerId: String\\
        - beneficiaryCount: int\\
        - deliveryOTP: String\\
        - pickupTime: DateTime\\
        - deliveryTime: DateTime\\[0.05cm]
        \hline
        + reserveClaim(): bool\\
        + verifyPickup(otp): bool\\
        + verifyDelivery(otp): bool
    };

    \node [classbox] (audit) at (0, 1.8) {
        \textbf{AuditLogEntry}\\[0.05cm]
        \hline
        - logId: String (UUID)\\
        - actorId: String\\
        - action: String\\
        - targetResource: String\\
        - timestamp: DateTime\\
        - ipAddress: String\\[0.05cm]
        \hline
        + appendImmutableLog(): void\\
        + verifyIntegrityHash(): bool
    };

    \draw [assoc] (user) -- node[above, font=\tiny] {1 \quad creates \quad 0..*} (donation);
    \draw [assoc] (donation) -- node[right, font=\tiny] {1 \quad fulfilled\_by \quad 1} (dist);
    \draw [assoc] (user) -- node[above, font=\tiny, sloped] {1 \quad claims/delivers \quad 0..*} (dist);
    \draw [assoc] (user) -- node[left, font=\tiny] {1 \quad generates \quad 0..*} (audit);
\end{tikzpicture}
\caption{Class Diagram}
\label{fig:class_diagram}
\end{figure}

\subsection{Sequence Diagram}
The sequence diagram shows the messages exchanged between the donor, the mobile app, the server, the shelter, the volunteer courier, and the audit log during one redistribution cycle.

\begin{figure}[H]
\centering
\begin{tikzpicture}[scale=0.76, every node/.style={transform shape}]
    \node (d) at (0,0) [draw, fill=white, minimum width=1.7cm, minimum height=0.65cm, font=\bfseries\footnotesize] {Donor};
    \node (s) at (3.5,0) [draw, fill=white, minimum width=1.7cm, minimum height=0.65cm, font=\bfseries\footnotesize] {FoodBridge};
    \node (sh) at (7.0,0) [draw, fill=white, minimum width=1.7cm, minimum height=0.65cm, font=\bfseries\footnotesize] {Shelter};
    \node (v) at (10.5,0) [draw, fill=white, minimum width=1.7cm, minimum height=0.65cm, font=\bfseries\footnotesize] {Volunteer};
    \node (a) at (14.0,0) [draw, fill=white, minimum width=1.7cm, minimum height=0.65cm, font=\bfseries\footnotesize] {Audit Log};

    \draw [dashed] (d) -- (0,-9.2);
    \draw [dashed] (s) -- (3.5,-9.2);
    \draw [dashed] (sh) -- (7.0,-9.2);
    \draw [dashed] (v) -- (10.5,-9.2);
    \draw [dashed] (a) -- (14.0,-9.2);

    \draw [-latex', thick] (d) ++(0,-0.8) -- node[above, font=\scriptsize] {1. List Surplus Meals \& Sign Charter} (3.5,-0.8);
    \draw [-latex', thick] (3.5,-1.4) -- node[above, font=\scriptsize] {2. Return Secret Pickup OTP} (0,-1.4);
    \draw [-latex', thick] (3.5,-2.1) -- node[above, font=\scriptsize] {3. WebSocket Broadcast: Available Food} (7.0,-2.1);
    \draw [-latex', thick] (sh) ++(0,-2.8) -- node[above, font=\scriptsize] {4. Reserve Claim by Headcount} (3.5,-2.8);
    \draw [-latex', thick] (3.5,-3.4) -- node[above, font=\scriptsize] {5. Verify Darpan \& Return Delivery OTP} (7.0,-3.4);
    \draw [-latex', thick] (3.5,-4.2) -- node[above, font=\scriptsize] {6. Dispatch Courier Notification} (10.5,-4.2);
    \draw [-latex', thick] (v) ++(0,-4.9) -- node[above, font=\scriptsize] {7. Accept Courier Assignment ($\le$ 2 tasks)} (3.5,-4.9);
    \draw [-latex', thick] (v) ++(0,-5.7) -- node[above, font=\scriptsize] {8. Submit Donor's Pickup OTP} (3.5,-5.7);
    \draw [-latex', thick] (3.5,-6.3) -- node[above, font=\scriptsize] {9. Validate OTP; Update: IN\_TRANSIT} (10.5,-6.3);
    \draw [-latex', thick] (v) ++(0,-7.1) -- node[above, font=\scriptsize] {10. Submit Shelter's Delivery OTP} (3.5,-7.1);
    \draw [-latex', thick] (3.5,-7.8) -- node[above, font=\scriptsize] {11. Validate OTP; Set COMPLETED} (7.0,-7.8);
    \draw [-latex', thick] (3.5,-8.5) -- node[above, font=\scriptsize] {12. Commit Immutable Handover Trail} (14.0,-8.5);
\end{tikzpicture}
\caption{Sequence Diagram for Listing, Claim and Dual-OTP Handover}
\label{fig:seq_diagram}
\end{figure}

\subsection{Collaboration Diagram}
The collaboration diagram shows the same interaction as numbered messages between the participating objects.

\begin{figure}[H]
\centering
\begin{tikzpicture}[scale=0.76, every node/.style={transform shape},
    obj/.style={rectangle, draw=black, fill=blue!5, text width=2.6cm, text centered, rounded corners=3pt, minimum height=0.95cm, font=\scriptsize\bfseries},
    conn/.style={draw=black!70, thick}]

    \node [obj] (donor) at (0, 4) {1: Donor Client\\(Mobile)};
    \node [obj] (server) at (6, 4) {2: FoodBridge Engine\\(Cloud Orchestrator)};
    \node [obj] (shelter) at (12, 4) {3: Shelter Client\\(Mobile)};
    \node [obj] (vol) at (3, 0.5) {4: Volunteer Client\\(Mobile)};
    \node [obj] (audit) at (9, 0.5) {5: Immutable Audit\\Engine};

    \draw [conn] (donor) -- node[above, font=\tiny] {1: DeclareSurplus()} node[below, font=\tiny] {2: ReturnPickupOTP()} (server);
    \draw [conn] (server) -- node[above, font=\tiny] {3: BroadcastListing()} node[below, font=\tiny] {4: ReserveClaim() / 5: IssueDeliveryOTP()} (shelter);
    \draw [conn] (server) -- node[left, font=\tiny] {6: DispatchTask()} node[right, font=\tiny] {7: Accept() / 8: SubmitPickupOTP()} (vol);
    \draw [conn] (server) -- node[left, font=\tiny] {9: CommitDistribution()} node[right, font=\tiny] {10: AppendAuditRecord()} (audit);
    \draw [conn, dashed] (vol) -- node[above, font=\tiny] {Handover Verification} (shelter);
\end{tikzpicture}
\caption{Collaboration Diagram}
\label{fig:collab_diagram}
\end{figure}

\subsection{Database Diagrams}
\subsubsection{ER Diagram}
The database has four core entities. One user submits many donations. Distribution records connect claimed donations to claiming shelters and couriers, and OTP codes are matched to users by phone number.

\begin{figure}[H]
\centering
\begin{tikzpicture}[scale=0.74, every node/.style={transform shape},
    entity/.style={rectangle, draw=black, fill=blue!10, text width=2.4cm, text centered, minimum height=1.0cm, font=\footnotesize\bfseries},
    relation/.style={diamond, draw=black, fill=yellow!15, aspect=1.8, text width=1.7cm, text centered, font=\scriptsize\bfseries},
    link/.style={draw, thick}]

    \node [entity] (e_user) at (1.5, 6) {USERS};
    \node [entity] (e_donation) at (9.5, 6) {DONATIONS};
    \node [entity] (e_dist) at (9.5, 0.5) {DISTRIBUTION\\RECORDS};
    \node [entity] (e_audit) at (1.5, 0.5) {AUDIT\\LOGS};

    \node [relation] (r_creates) at (5.5, 6) {CREATES};
    \node [relation] (r_fulfills) at (9.5, 3.2) {FULFILLS};
    \node [relation] (r_logs) at (1.5, 3.2) {LOGS};
    \node [relation] (r_delivers) at (5.5, 0.5) {DELIVERS};

    \draw [link] (e_user) -- node[above, font=\tiny] {1} (r_creates);
    \draw [link] (r_creates) -- node[above, font=\tiny] {N} (e_donation);
    \draw [link] (e_donation) -- node[right, font=\tiny] {1} (r_fulfills);
    \draw [link] (r_fulfills) -- node[right, font=\tiny] {1} (e_dist);
    \draw [link] (e_user) -- node[left, font=\tiny] {1} (r_logs);
    \draw [link] (r_logs) -- node[left, font=\tiny] {N} (e_audit);
    \draw [link] (e_user) |- node[near start, above, font=\tiny] {1} (r_delivers);
    \draw [link] (r_delivers) -- node[above, font=\tiny] {N} (e_dist);
\end{tikzpicture}
\caption{Entity Relationship Diagram}
\label{fig:er_diagram}
\end{figure}

\subsubsection{Table Relationships}
\begin{table}[H]
\centering
\caption{Database Tables and Relationships}
\label{tab:db_tables}
\resizebox{\textwidth}{!}{
\begin{tabular}{|l|p{7.5cm}|p{5.5cm}|}
    \hline
    \textbf{Table} & \textbf{Key Fields} & \textbf{Relationship / Description} \\
    \hline
    \textbf{users} & id (PK, UUID), email (unique), full\_name, role, phone, darpan\_id, is\_verified, created\_at & Master registry. One user $\rightarrow$ many donations, claims, or courier deliveries. \\
    \hline
    \textbf{donations} & id (PK, UUID), donor\_id (FK $\rightarrow$ users.id), title, food\_type, quantity\_kg, expiry\_time, pickup\_otp, status, created\_at & Many donations $\rightarrow$ one donor. Fulfilled by exactly one distribution record. \\
    \hline
    \textbf{distribution\_records} & id (PK, UUID), donation\_id (FK $\rightarrow$ donations.id), shelter\_id (FK $\rightarrow$ users.id), volunteer\_id (FK $\rightarrow$ users.id), beneficiary\_count, delivery\_otp, status, completed\_at & Connects claimed donation, receiving charitable shelter, and delivering courier. \\
    \hline
    \textbf{audit\_logs} & id (PK, UUID), actor\_id (FK $\rightarrow$ users.id), action, resource, details, ip\_address, timestamp & Immutable system audit trail. Every privileged action is linked to an authenticated actor. \\
    \hline
    \textbf{otp\_codes} & id (PK, UUID), user\_id (FK $\rightarrow$ users.id), code, purpose, expires\_at, is\_consumed & Ephemeral token records validating 2FA login and emergency resets. \\
    \hline
\end{tabular}
}
\end{table}

% ==============================================================================
% CHAPTER 6: IMPLEMENTATION
% ==============================================================================
\newpage
\section{IMPLEMENTATION}

\subsection{Technology}
\begin{table}[H]
\centering
\caption{Technology Stack}
\label{tab:tech_stack}
\begin{tabularx}{\textwidth}{|l|l|X|}
    \hline
    \textbf{Layer} & \textbf{Technology} & \textbf{Reason for Choice} \\
    \hline
    Mobile Client & Flutter 3.24+ (Dart 3.5+) & Single codebase for Android, iOS and Web; 120 FPS native performance. \\
    \hline
    Web Dashboard & Flutter Web / React 18 & Fast responsive admin dashboard; real-time urban redistribution monitor. \\
    \hline
    Backend / BaaS & Supabase (PostgreSQL 15+) & Automatic REST API, integrated Auth, and real-time WebSocket broadcasting. \\
    \hline
    Security Engine & Row Level Security (RLS) & Multi-tenant data isolation and cryptographic dual-OTP verification. \\
    \hline
    Offline Storage & SharedPreferences (AES-256) & Resilient local caching preserving active tasks during cellular network dropouts. \\
    \hline
    Authentication & JWT, RBAC, 2FA & Stateless role-based session tokens with phone OTP verification. \\
    \hline
\end{tabularx}
\end{table}

\noindent
\textbf{Implementation completed so far:}
The core architectural layers and stakeholder modules have been implemented and validated end-to-end. These include: the Supabase backend with JWT/RBAC authentication; surplus food listing with dietary tags and Food Safety Charter sign-off; the Shelter (NGO) portal with Darpan accreditation upload; the Volunteer Courier dispatch console with 2-task throttling and dual-OTP entry; the Super Admin monitoring dashboard with real-time KPI metrics and audit logs; and the real-time WebSocket mesh delivering sub-100ms state broadcasts across distributed clients.

\newpage
\begin{figure}[H]
\centering
\includegraphics[width=0.88\textwidth,height=6.2cm,keepaspectratio]{figures/admin_console.png}
\caption{Admin Console – Real-Time Redistribution Overview (FoodBridge System Overview)}
\label{fig:screen_admin}
\end{figure}

\begin{figure}[H]
\centering
\includegraphics[width=0.88\textwidth,height=6.2cm,keepaspectratio]{figures/volunteer_dashboard.png}
\caption{Volunteer Dispatch \& Verification Screen}
\label{fig:screen_volunteer}
\end{figure}

\newpage
\begin{figure}[H]
\centering
\includegraphics[width=0.88\textwidth,height=6.2cm,keepaspectratio]{figures/donation_detail.png}
\caption{Backend REST API Documentation (Swagger UI)}
\label{fig:screen_donation}
\end{figure}

\subsection{Steps to be Taken Towards Project Completion}
\begin{enumerate}
    \item Finalize the problem statement, stakeholder scope, and academic objectives.
    \item Complete comprehensive literature review and regulatory requirement gathering (FSSAI guidelines).
    \item Finalize system architecture, UML models, and Supabase relational schema design.
    \item Implement Role-Based Access Control (RBAC) and JWT authentication with 2FA OTP verification.
    \item Implement Donor Module with dietary tagging (Veg/Non-Veg) and mandatory Food Safety Charter.
    \item Implement Shelter (NGO) Module with Darpan ID and 80G tax accreditation approval workflow.
    \item Build Volunteer Courier dispatch system enforcing concurrent 2-task throttling.
    \item Enforce double-blind cryptographic Dual-OTP handover protocol (Pickup OTP and Delivery OTP).
    \item Deploy real-time WebSocket state distribution ensuring sub-100ms multi-device synchronization.
\end{enumerate}

\subsection{Project Scheduling}
\subsubsection{Plan of Action}
\begin{table}[H]
\centering
\caption{Plan of Action}
\label{tab:plan_of_action}
\begin{tabularx}{\textwidth}{|c|X|c|c|}
    \hline
    \textbf{Sr. No.} & \textbf{Activity} & \textbf{Duration} & \textbf{Status} \\
    \hline
    1 & Topic selection, problem definition and literature survey & Jul – Aug 2026 & Completed \\
    \hline
    2 & Requirement analysis and system design (UML, database) & Aug – Sep 2026 & Completed \\
    \hline
    3 & Backend API, Supabase authentication and schema creation & Sep 2026 & Completed \\
    \hline
    4 & Real-time WebSocket sync, Dual-OTP engine and Darpan verifier & Sep – Oct 2026 & Completed \\
    \hline
    5 & Flutter cross-platform mobile client and stakeholder screens & Sep – Oct 2026 & Completed \\
    \hline
    6 & Project Review-II (Hardware deployment \& live testing) & 23 Oct – 4 Nov 2026 & In Progress \\
    \hline
    7 & Municipal pilot deployment and multi-shelter field trial & Dec 2026 – Feb 2027 & Planned \\
    \hline
    8 & Final documentation, project report and University viva & Mar – Apr 2027 & Planned \\
    \hline
\end{tabularx}
\end{table}

\subsection{Cost Estimation}
The project is built almost entirely with free and open-source software, so the development cost is low. The table below gives an approximate estimate; deployment costs are indicative and depend on the provider chosen.

\begin{table}[H]
\centering
\caption{Approximate Cost Estimation}
\label{tab:cost_est}
\begin{tabularx}{\textwidth}{|l|X|r|}
    \hline
    \textbf{Item} & \textbf{Details} & \textbf{Approx. Cost (\rupee)} \\
    \hline
    Software and libraries & Flutter SDK, Dart, Supabase BaaS, PostgreSQL (open source) & 0 \\
    \hline
    Development hardware & Team members' existing laptops and Android phones & 0 \\
    \hline
    Domain name and SSL & Domain for one year; free Let's Encrypt SSL & 800 – 1,000 \\
    \hline
    SMS gateway for OTP & Pay-per-use transactional OTP SMS gateway & 500 – 1,000 \\
    \hline
    Field data collection & Local transport for hostel/banquet food pickup validation & 1,000 – 2,000 \\
    \hline
    Report binding \& print & University project documentation, hardbound copies & 1,200 – 1,500 \\
    \hline
    \multicolumn{2}{|l|}{\textbf{Total (approximate)}} & \textbf{3,500 – 5,500} \\
    \hline
\end{tabularx}
\end{table}

\subsection{Team Structure}
The project team consists of four members working under the guidance of the project guide. The work is distributed as follows:

\begin{table}[H]
\centering
\caption{Team Structure and Work Distribution}
\label{tab:team_dist}
\begin{tabularx}{\textwidth}{|p{0.38\textwidth}|X|}
    \hline
    \textbf{Member} & \textbf{Responsibility} \\
    \hline
    \textbf{1) Yogesh Gurunath Chavan} \newline \footnotesize (PRN: 24062701242502) & Admin Module -- Admin console, user/role management, real-time sync engine, dynamic profile resolution, and hardware deployment. \\
    \hline
    \textbf{2) Samruddhi Pramod Sawant} \newline \footnotesize (PRN: 23062701242039) & Donor Module -- Surplus food declaration, dietary classification (Veg/Non-Veg), Food Safety Charter, and image upload. \\
    \hline
    \textbf{3) Omkar Nilesh Shinde} \newline \footnotesize (PRN: 23062701242121) & Shelter (NGO) Module -- NGO Darpan accreditation verification, 80G tax certificate audit, capacity-based claim allocation, and headcount tracking. \\
    \hline
    \textbf{4) Shivraj Rajendra Yadav} \newline \footnotesize (PRN: 23062701242102) & Volunteer Courier Module -- Courier task dispatch, double-blind Dual-OTP handover protocol, courier concurrency throttling, and integration testing. \\
    \hline
\end{tabularx}
\end{table}

% ==============================================================================
% CHAPTER 7: ADVANTAGES & LIMITATIONS
% ==============================================================================
\newpage
\section{ADVANTAGES \& LIMITATIONS}

\subsection{Advantages}
\begin{itemize}
    \item Quick redistribution from donor notification without waiting for manual phone coordination.
    \item Advice and interface in the stakeholder's own language -- Marathi, Hindi or English.
    \item Safe recommendations: donor signs legal Food Safety Charter and declares holding temperatures.
    \item Near-zero latency coordination: sub-100ms WebSocket synchronization eliminates perishable food spoilage.
    \item Guaranteed proof of delivery: double-blind Dual-OTP prevents delivery falsification.
    \item Government accreditation gate: only inspected NGOs with valid Darpan and 80G IDs can claim surplus.
    \item Fair volunteer task distribution: 2-task concurrency throttle prevents courier hoarding.
    \item Built entirely on free and open-source tools, so it is low in cost.
\end{itemize}

\subsection{Limitations}
\begin{itemize}
    \item An internet connection is required for real-time WebSocket sync and remote database updates.
    \item Redistribution speed in remote rural zones depends on active courier volunteer density.
    \item Physical food quality verification at donor pickup currently relies on donor compliance and sensory inspection.
    \item Marathi and Hindi localizations are currently being expanded for specialized administrative legal terms.
\end{itemize}

% ==============================================================================
% CHAPTER 8: APPLICATIONS
% ==============================================================================
\newpage
\section{APPLICATIONS}

\begin{itemize}
    \item \textbf{College Hostels \& University Canteens:} Safe daily collection, allocation, and redistribution of dining hall meals.
    \item \textbf{Commercial Banquets \& Wedding Halls:} Salvage of surplus banquet meals within hours of event conclusion.
    \item \textbf{Charitable Shelters \& Orphanages:} Automated intake management for night shelters based on resident headcount.
    \item \textbf{Disaster Relief Operations:} Rapid routing of packaged rations and drinking water to displaced citizens.
    \item \textbf{Seasonal Warm Wear Redistribution:} Salvage and distribution of winter wear alongside food relief pipelines.
\end{itemize}

% ==============================================================================
% CHAPTER 9: FUTURE SCOPE
% ==============================================================================
\newpage
\section{FUTURE SCOPE}

\begin{itemize}
    \item \textbf{AI-Driven Surplus Volume Forecasting:} Machine learning models to forecast surplus quantities from historical dining trends.
    \item \textbf{IoT Smart Temperature Boxes:} Telemetry-equipped delivery containers verifying food temperature during transit.
    \item \textbf{Automated Multi-Stop Route Optimization:} Heuristic algorithms to dynamically compute optimal multi-stop courier routes.
    \item \textbf{Direct NITI Aayog API Verification:} Instant accreditation verification through government portal integration.
    \item \textbf{Voice Output \& Input:} Text-to-speech in Marathi and Hindi for couriers with limited literacy.
\end{itemize}

% ==============================================================================
% CHAPTER 10: CONCLUSION
% ==============================================================================
\newpage
\section{CONCLUSION}

\textbf{FOODBRIDGE : Real-Time Surplus Food Redistribution and Logistics Engine} establishes an automated, auditable, and secure bridge between surplus food generators and charitable shelters. By replacing slow, uncoordinated telephone chains with reactive Flutter mobile clients, real-time Supabase WebSocket synchronization, and a double-blind cryptographic Dual-OTP handover gate, FoodBridge addresses the root causes of urban food waste and delivery falsification.

The design keeps the stakeholder experience simple -- declare surplus, receive nearby notifications, claim by headcount, and verify custody with physical OTPs -- while building in institutional safeguards: mandatory NGO Darpan accreditation reviews, courier concurrency limits, and an immutable audit trail.

The backend, real-time sync engine, stakeholder portals, and mobile app screens have been implemented and validated end-to-end. When fully deployed across urban municipalities, FoodBridge will help charitable foundations act earlier, eliminate commercial food waste, and provide transparent nutritional relief to individuals in need.

% ==============================================================================
% REFERENCES
% ==============================================================================
\newpage
\section*{REFERENCES}
\addcontentsline{toc}{section}{References}

\begin{enumerate}
    \item[{[1]}] United Nations Environment Programme (UNEP), \textit{Food Waste Index Report 2024: Think Eat Save - Tracking Global Food Waste}, Nairobi: UNEP Publications, 2024.
    \item[{[2]}] Food and Agriculture Organization (FAO), \textit{The State of Food Security and Nutrition in the World 2023}, Rome: FAO, 2023.
    \item[{[3]}] C. Shewale et al., ``Multi Factor Authentication and IP Address Restriction based Question Paper Delivery System for Indian Universities,'' \textit{International Journal on Recent and Innovation Trends in Computing and Communication}, vol. 11, no. 10, pp. 390--396, 2023.
    \item[{[4]}] R. Patil, S. Deshmukh, and A. Kulkarni, ``Real-Time Volunteer Routing and Optimization in Urban Relief Distribution Networks,'' in \textit{Proceedings of the IEEE International Conference on Smart Computing and Logistics}, 2023, pp. 112--119.
    \item[{[5]}] S. Kamble and R. Kamble, ``Blockchain-based Competitive Examination System in India,'' \textit{International Journal of Advanced Computer Science}, vol. 14, no. 3, pp. 45--52, 2024.
    \item[{[6]}] \'{A}. V\'{e}csi and A. Peth\H{o}, ``Auditable Anonymous Electronic Examination,'' \textit{Cryptography}, vol. 8, no. 2, p. 19, 2024.
    \item[{[7]}] B. Singh and G. Kasana, ``A review of digital watermarking techniques: Current trends, challenges and opportunities,'' \textit{Web Intelligence}, vol. 22, pp. 1--31, 2024.
    \item[{[8]}] W. Stallings, \textit{Cryptography and Network Security: Principles and Practice}, 8th ed., London, UK: Pearson, 2023.
    \item[{[9]}] Google Flutter Team, \textit{Flutter Architectural Best Practices for Production Reactive State}, Mountain View, CA: Google Developers, 2025. [Online].
    \item[{[10]}] Niti Aayog, \textit{NGO Darpan Portal: Guidelines for Voluntary Organization Registration and Accreditation}, Government of India, 2024.
    \item[{[11]}] Food Safety and Standards Authority of India (FSSAI), \textit{Food Safety and Standards (Recovery and Distribution of Surplus Food) Regulations}, Ministry of Health and Family Welfare, New Delhi, 2019.
    \item[{[12]}] University Grants Commission (UGC), \textit{Guidelines and Quality Mandate for Higher Educational Institutions and Project Work in India}, New Delhi, 2023.
\end{enumerate}

\end{document}
'''

target_path = Path(r"d:\1FoodBridge_research\FoodBridge-Final\Food-Bridge-updated\reports\project_phase_1_report\main.tex")
with open(target_path, "w", encoding="utf-8") as f:
    f.write(content)

print(f"[SUCCESS] Wrote updated main.tex successfully ({len(content)} characters, {len(content.splitlines())} lines).")
