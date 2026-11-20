# -*- coding: utf-8 -*-
"""
Generates high-resolution landscape presentation figures (1200x700, aspect ratio ~1.71)
for Chapter 6 of the FoodBridge Project Report.
Matches Figure 6.1, 6.2, and 6.3 from the KBPCOES / DBATU reference report.
"""

from PIL import Image, ImageDraw, ImageFont
import os

fig_dir = r"d:\1FoodBridge_research\FoodBridge-Final\Food-Bridge-updated\reports\project_phase_1_report\figures"
os.makedirs(fig_dir, exist_ok=True)

# Try to load Arial or default font
def get_fonts():
    try:
        font_title = ImageFont.truetype("arial.ttf", 26)
        font_subtitle = ImageFont.truetype("arial.ttf", 16)
        font_bold = ImageFont.truetype("arialbd.ttf", 18)
        font_body = ImageFont.truetype("arial.ttf", 15)
        font_code = ImageFont.truetype("consola.ttf", 14)
        font_small = ImageFont.truetype("arial.ttf", 13)
        font_tiny = ImageFont.truetype("arial.ttf", 11)
    except:
        font_title = font_subtitle = font_bold = font_body = font_code = font_small = font_tiny = ImageFont.load_default()
    return font_title, font_subtitle, font_bold, font_body, font_code, font_small, font_tiny

f_title, f_sub, f_bold, f_body, f_code, f_small, f_tiny = get_fonts()

# ==============================================================================
# FIGURE 6.1: Admin Console – Real-Time Redistribution Overview
# ==============================================================================
def create_fig_6_1():
    W, H = 1200, 700
    im = Image.new("RGB", (W, H), "#0B0F17") # Midnight Slate background
    d = ImageDraw.Draw(im)

    # Top App Bar
    d.rectangle([(0, 0), (W, 64)], fill="#151C2C")
    d.line([(0, 64), (W, 64)], fill="#222F48", width=1)
    d.text((28, 18), "FoodBridge Super Admin Live Console", fill="#FFFFFF", font=f_title)
    d.text((640, 24), "• Live Real-Time Mesh Active (Supabase WebSockets: Sub-100ms)", fill="#10B981", font=f_small)
    d.rectangle([(1060, 16), (1172, 48)], fill="#1E293B", outline="#3B82F6")
    d.text((1078, 24), "Admin: Yogesh", fill="#93C5FD", font=f_small)

    # KPI Summary Cards (4 Cards across top)
    kpis = [
        ("Total Salvaged Meals", "1,420 Meals", "+18% today", "#10B981"),
        ("Active Dispatches", "18 Couriers", "100% On-Track", "#3B82F6"),
        ("Verified Shelters", "42 NGOs", "Darpan Approved", "#8B5CF6"),
        ("Delivery Falsification", "0.0%", "Dual-OTP Protected", "#F59E0B"),
    ]
    card_w = 268
    for i, (title, val, sub, col) in enumerate(kpis):
        x = 28 + i * (card_w + 16)
        y = 80
        d.rounded_rectangle([(x, y), (x + card_w, y + 90)], radius=8, fill="#151C2C", outline="#222F48", width=1)
        d.text((x + 16, y + 12), title, fill="#94A3B8", font=f_small)
        d.text((x + 16, y + 36), val, fill="#FFFFFF", font=f_bold)
        d.text((x + 16, y + 64), sub, fill=col, font=f_tiny)

    # Main Left Panel: Live Redistribution Zone & Outbreak Map
    left_w = 680
    d.rounded_rectangle([(28, 186), (28 + left_w, 670)], radius=8, fill="#111827", outline="#222F48", width=1)
    d.text((44, 202), "Live Redistribution Cluster & Proximity Geohash Map", fill="#F1F5F9", font=f_bold)
    d.text((44, 226), "Satara Urban Belt (Hostels -> Charitable Ashrams)", fill="#64748B", font=f_small)

    # Simulated Map grid & Nodes
    map_box = [(44, 252), (28 + left_w - 16, 650)]
    d.rectangle(map_box, fill="#0F172A", outline="#1E293B")
    for gy in range(270, 640, 40):
        d.line([(44, gy), (28 + left_w - 16, gy)], fill="#1E293B", width=1)
    for gx in range(60, 28 + left_w - 16, 50):
        d.line([(gx, 252), (gx, 650)], fill="#1E293B", width=1)

    # Route lines on map
    d.line([(120, 340), (280, 420), (450, 360), (600, 500)], fill="#3B82F6", width=3)
    d.line([(280, 420), (320, 560), (520, 580)], fill="#10B981", width=3)

    # Nodes
    nodes = [
        (120, 340, "KBP College Hostel", "#EF4444", "Donor (120 Meals)"),
        (280, 420, "Courier: Shivraj [Active]", "#3B82F6", "In-Transit (Dual-OTP)"),
        (450, 360, "Grand Palace Banquet", "#EF4444", "Donor (250 Meals)"),
        (600, 500, "Anandwan Ashram", "#10B981", "Shelter (80G Verified)"),
        (320, 560, "Courier: Omkar", "#3B82F6", "En Route Pickup"),
        (520, 580, "Navjeevan Anathalay", "#10B981", "Shelter (Darpan: MH/2023/01)"),
    ]
    for nx, ny, lbl, col, desc in nodes:
        d.ellipse([(nx - 9, ny - 9), (nx + 9, ny + 9)], fill=col, outline="#FFFFFF", width=2)
        d.rectangle([(nx + 14, ny - 14), (nx + 180, ny + 14)], fill="#1E293B", outline=col)
        d.text((nx + 20, ny - 12), lbl, fill="#FFFFFF", font=f_tiny)
        d.text((nx + 20, ny + 1), desc, fill="#94A3B8", font=f_tiny)

    # Main Right Panel: Real-Time Audit Feed & Darpan Verification Queue
    rx = 28 + left_w + 16
    rw = W - rx - 28
    d.rounded_rectangle([(rx, 186), (rx + rw, 670)], radius=8, fill="#111827", outline="#222F48", width=1)
    d.text((rx + 16, 202), "Real-Time Immutable Audit Stream", fill="#F1F5F9", font=f_bold)
    d.text((rx + 16, 226), "Append-only SHA-256 Verified Ledger", fill="#64748B", font=f_small)

    audits = [
        ("14:26:02", "PICKUP_VERIFIED", "Courier Shivraj entered Pickup PIN 4821", "#3B82F6"),
        ("14:24:45", "DARPAN_APPROVED", "NGO Navjeevan 80G Tax Exemption Verified", "#10B981"),
        ("14:21:18", "CLAIM_RESERVED", "Anandwan Ashram reserved 120 Veg Meals", "#8B5CF6"),
        ("14:18:30", "DONATION_LISTED", "KBP Mess declared 120 Veg Meals", "#F59E0B"),
        ("14:10:04", "DELIVERY_CLOSED", "Shelter OTP 9032 confirmed; Log Committed", "#10B981"),
        ("14:02:11", "AUTH_LOGIN_2FA", "Super Admin Yogesh Chavan session started", "#64748B"),
        ("13:55:40", "SYNC_RECONCILE", "Peer WebSocket mesh re-synced in 42ms", "#3B82F6"),
    ]
    for j, (t, ev, msg, col) in enumerate(audits):
        ay = 256 + j * 56
        d.rounded_rectangle([(rx + 12, ay), (rx + rw - 12, ay + 48)], radius=6, fill="#151C2C", outline="#1E293B")
        d.text((rx + 20, ay + 6), t, fill="#64748B", font=f_code)
        d.rectangle([(rx + 90, ay + 4), (rx + 225, ay + 20)], fill=col)
        d.text((rx + 94, ay + 5), ev, fill="#FFFFFF", font=f_tiny)
        d.text((rx + 20, ay + 26), msg, fill="#E2E8F0", font=f_tiny)

    p = os.path.join(fig_dir, "admin_console.png")
    im.save(p, "PNG")
    print(f"[SUCCESS] Generated {p} ({im.size})")

# ==============================================================================
# FIGURE 6.2: Volunteer Dispatch & Verification Screen
# ==============================================================================
def create_fig_6_2():
    W, H = 1200, 700
    im = Image.new("RGB", (W, H), "#0B0F17")
    d = ImageDraw.Draw(im)

    # Top Bar
    d.rectangle([(0, 0), (W, 64)], fill="#151C2C")
    d.line([(0, 64), (W, 64)], fill="#222F48", width=1)
    d.text((28, 18), "FoodBridge Volunteer Dispatch & Custody Verification Hub", fill="#FFFFFF", font=f_title)
    d.text((760, 24), "Logged in as: Shivraj Yadav (PRN: 23062701242102)", fill="#93C5FD", font=f_small)

    # Filter Tabs
    tabs = [("All Dispatches (18)", True), ("Ready for Pickup (4)", False), ("In-Transit (6)", False), ("Completed (8)", False)]
    for i, (tab, active) in enumerate(tabs):
        tx = 28 + i * 160
        bg = "#2563EB" if active else "#1E293B"
        tc = "#FFFFFF" if active else "#94A3B8"
        d.rounded_rectangle([(tx, 80), (tx + 148, 112)], radius=6, fill=bg)
        d.text((tx + 14, 88), tab, fill=tc, font=f_small)

    # Main Dispatch Table
    d.rounded_rectangle([(28, 128), (760, 670)], radius=8, fill="#111827", outline="#222F48", width=1)
    d.text((44, 144), "Active Courier Task Queue (Throttle Limit: Max 2 Concurrent)", fill="#F1F5F9", font=f_bold)

    tasks = [
        ("TASK-8021", "KBP Hostel Mess -> Anandwan Ashram", "120 Meals (Veg)", "Pickup OTP: Verified", "In-Transit", "#3B82F6", "Verify Delivery PIN"),
        ("TASK-8024", "Grand Palace Banquet -> Navjeevan Shelter", "250 Meals (Hot)", "Waiting Pickup OTP", "Claimed", "#F59E0B", "Enter Pickup PIN"),
        ("TASK-8019", "Suman Bakery -> Mother Teresa Orphanage", "80 Pkg Breads", "Dual-OTP Complete", "Distributed", "#10B981", "Receipt Logged"),
        ("TASK-8015", "Hotel Radhika -> City Night Shelter", "65 Warm Blankets", "Dual-OTP Complete", "Distributed", "#10B981", "Receipt Logged"),
        ("TASK-8012", "Satara Club -> Girijatmak Leprosy Home", "140 Meals (Veg)", "Dual-OTP Complete", "Distributed", "#10B981", "Receipt Logged"),
    ]
    for k, (tid, route, cargo, otp_st, status, scol, btn_txt) in enumerate(tasks):
        ty = 180 + k * 94
        d.rounded_rectangle([(44, ty), (744, ty + 82)], radius=6, fill="#151C2C", outline="#1E293B")
        d.text((56, ty + 10), tid, fill="#38BDF8", font=f_code)
        d.rectangle([(150, ty + 8), (240, ty + 24)], fill=scol)
        d.text((156, ty + 9), status, fill="#FFFFFF", font=f_tiny)
        d.text((56, ty + 32), route, fill="#FFFFFF", font=f_bold)
        d.text((56, ty + 56), f"Payload: {cargo}  |  Status: {otp_st}", fill="#94A3B8", font=f_small)
        # Action Button
        d.rounded_rectangle([(580, ty + 24), (730, ty + 60)], radius=6, fill="#2563EB")
        d.text((592, ty + 34), btn_txt, fill="#FFFFFF", font=f_small)

    # Right Handover Protocol Panel (Dual-OTP Validation Engine)
    rx = 780
    rw = W - rx - 28
    d.rounded_rectangle([(rx, 128), (rx + rw, 670)], radius=8, fill="#111827", outline="#222F48", width=1)
    d.text((rx + 20, 144), "Physical Dual-OTP Handover Gate", fill="#F1F5F9", font=f_bold)
    d.text((rx + 20, 168), "Double-Blind Anti-Falsification Protocol", fill="#64748B", font=f_small)

    # Step 1: Pickup OTP
    d.rounded_rectangle([(rx + 16, 200), (rx + rw - 16, 360)], radius=6, fill="#151C2C", outline="#222F48")
    d.text((rx + 28, 212), "Stage 1: Donor Pickup Verification", fill="#38BDF8", font=f_bold)
    d.text((rx + 28, 236), "Ask Donor for their private 4-digit Pickup PIN:", fill="#CBD5E1", font=f_small)
    # 4 OTP boxes
    for bi, ch in enumerate(["4", "8", "2", "1"]):
        bx = rx + 36 + bi * 56
        d.rectangle([(bx, 260), (bx + 46, 306)], fill="#0F172A", outline="#10B981", width=2)
        d.text((bx + 16, 272), ch, fill="#10B981", font=f_bold)
    d.text((rx + 28, 324), "Status: [ PASSED ] - Custody Legally Transferred", fill="#10B981", font=f_small)

    # Step 2: Delivery OTP
    d.rounded_rectangle([(rx + 16, 380), (rx + rw - 16, 540)], radius=6, fill="#151C2C", outline="#222F48")
    d.text((rx + 28, 392), "Stage 2: Shelter Delivery Handover", fill="#A855F7", font=f_bold)
    d.text((rx + 28, 416), "Ask Receiving Shelter Coordinator for Delivery PIN:", fill="#CBD5E1", font=f_small)
    # 4 OTP boxes
    for bi, ch in enumerate(["9", "0", "3", "2"]):
        bx = rx + 36 + bi * 56
        d.rectangle([(bx, 440), (bx + 46, 486)], fill="#0F172A", outline="#3B82F6", width=2)
        d.text((bx + 16, 452), ch, fill="#60A5FA", font=f_bold)
    d.text((rx + 28, 504), "Status: [ READY ] - Awaiting Final Confirmation", fill="#60A5FA", font=f_small)

    # Security Stamp
    d.rounded_rectangle([(rx + 16, 560), (rx + rw - 16, 650)], radius=6, fill="#0F172A", outline="#10B981")
    d.text((rx + 28, 574), "Zero Ghost Deliveries Enforced:", fill="#10B981", font=f_bold)
    d.text((rx + 28, 598), "Cryptographically impossible to complete task", fill="#94A3B8", font=f_small)
    d.text((rx + 28, 620), "without physical proximity and dual PIN exchange.", fill="#94A3B8", font=f_small)

    p = os.path.join(fig_dir, "volunteer_dashboard.png")
    im.save(p, "PNG")
    print(f"[SUCCESS] Generated {p} ({im.size})")

# ==============================================================================
# FIGURE 6.3: Backend REST API Documentation (Swagger UI)
# ==============================================================================
def create_fig_6_3():
    W, H = 1200, 700
    im = Image.new("RGB", (W, H), "#FFFFFF") # Clean white Swagger UI theme
    d = ImageDraw.Draw(im)

    # Swagger Header Bar
    d.rectangle([(0, 0), (W, 60)], fill="#1B1B1B")
    d.text((32, 16), "Swagger", fill="#89BF04", font=f_title)
    d.text((150, 22), "supported by SmartBear", fill="#7D7D7D", font=f_small)

    # Title & OAS badge
    d.text((32, 80), "FoodBridge Real-Time REST API Engine", fill="#3B4151", font=f_title)
    d.rectangle([(510, 84), (570, 108)], fill="#89BF04")
    d.text((518, 88), "v1.0.0", fill="#FFFFFF", font=f_tiny)
    d.rectangle([(580, 84), (640, 108)], fill="#4990E2")
    d.text((588, 88), "OAS 3.0", fill="#FFFFFF", font=f_tiny)
    d.text((32, 116), "Centralized surplus food redistribution, Darpan accreditation gate, and dual-OTP custody microservices.", fill="#6B7280", font=f_small)
    d.text((32, 136), "Base URL: https://api.foodbridge.kbpcoes.edu.in/api/v1", fill="#2563EB", font=f_code)

    # API Endpoints List
    endpoints = [
        ("POST", "/api/v1/auth/login", "Authenticate stakeholder (Donor / Shelter / Courier / Admin) & issue JWT token", "#49CC90", "#E8F6F0"),
        ("POST", "/api/v1/donations/surplus", "Declare surplus cooked meals with Food Safety Charter & generate secret Pickup OTP", "#49CC90", "#E8F6F0"),
        ("GET",  "/api/v1/donations/nearby", "Proximity Geohash query for accredited shelters within geographic distribution radius", "#61AFFE", "#EBF3FB"),
        ("POST", "/api/v1/claims/reserve", "Shelter claim reservation with beneficiary headcount and NGO Darpan accreditation audit", "#49CC90", "#E8F6F0"),
        ("POST", "/api/v1/handover/verify-pickup-otp", "Cryptographic validation of Donor physical PIN; transitions status to IN_TRANSIT", "#49CC90", "#E8F6F0"),
        ("POST", "/api/v1/handover/verify-delivery-otp", "Cryptographic validation of Shelter PIN; transitions status to DISTRIBUTED", "#49CC90", "#E8F6F0"),
        ("GET",  "/api/v1/admin/audit-logs", "Query append-only immutable audit trail with actor signature and SHA-256 integrity hash", "#61AFFE", "#EBF3FB"),
    ]

    for i, (method, ep, desc, mcol, bgcol) in enumerate(endpoints):
        y = 176 + i * 68
        d.rounded_rectangle([(32, y), (W - 32, y + 58)], radius=4, fill=bgcol, outline=mcol, width=1)
        # Method badge
        d.rounded_rectangle([(44, y + 12), (124, y + 46)], radius=3, fill=mcol)
        d.text((56, y + 18), method, fill="#FFFFFF", font=f_bold)
        # Endpoint path
        d.text((140, y + 18), ep, fill="#3B4151", font=f_bold)
        # Description
        d.text((560, y + 20), desc, fill="#6B7280", font=f_small)

    p = os.path.join(fig_dir, "donation_detail.png")
    im.save(p, "PNG")
    print(f"[SUCCESS] Generated {p} ({im.size})")

if __name__ == "__main__":
    create_fig_6_1()
    create_fig_6_2()
    create_fig_6_3()
    print("\n[ALL FIGURES RE-GENERATED IN LANDSCAPE FORMAT 1200x700 SUCCESSFULLY]")
