# Supabase Auth + Resend SMTP 6-Digit Email OTP Setup Guide

This guide details how to configure Supabase Auth with **Resend SMTP** to deliver fast 6-digit verification codes for FoodBridge.

---

## 1. Get Resend SMTP Credentials

1. Go to [Resend](https://resend.com) and log in or create an account.
2. In the Resend Dashboard:
   - Go to **Domains** -> **Add Domain** -> Add your domain (e.g. `foodbridge.org` or `mail.foodbridge.org`) and configure the DNS records (DKIM, SPF).
   - Alternatively, for testing, you can use Resend's provided onboarding test email sender.
3. Go to **API Keys** -> Click **Create API Key**:
   - Name: `FoodBridge Supabase Auth`
   - Permission: `Sending access`
   - Copy the generated API key (format: `re_xxxxxxxxxxxxxxxxxxxxxx`).

---

## 2. Configure Custom SMTP in Supabase Dashboard

1. Open your Supabase Dashboard: [https://supabase.com/dashboard/project/jmrjslzsztkckopzaatl](https://supabase.com/dashboard/project/jmrjslzsztkckopzaatl)
2. In the left navigation, click **Project Settings** (gear icon) -> **Authentication** (under Configuration).
3. Scroll down to **SMTP Settings**:
   - Toggle **Enable Custom SMTP** to **ON**.
   - **Sender email**: `noreply@yourdomain.com` (Must be verified in Resend)
   - **Sender name**: `FoodBridge`
   - **Host**: `smtp.resend.com`
   - **Port number**: `587` (or `465` with SSL)
   - **Minimum TLS version**: `TLS 1.2`
   - **User**: `resend`
   - **Password**: `<YOUR_RESEND_API_KEY>` (Paste the `re_...` key copied in step 1)
4. Click **Save Changes**.

---

## 3. Configure Supabase Email OTP Template

1. In Supabase Dashboard, go to **Authentication** -> **Email Templates**.
2. Select **Confirm signup**:
   - **Subject**: `Verify Your FoodBridge Account`
   - In the **Body (HTML)** editor:
     - Clear the existing template.
     - Paste the contents of `supabase/email_templates/confirm_signup_otp.html`.
     - Confirm that it uses `{{ .Token }}` instead of `{{ .ConfirmationURL }}`.
3. Click **Save Changes**.

---

## 4. Confirm Supabase Auth Settings

In **Authentication** -> **Providers** -> **Email**:
- **Enable Email provider**: `ON`
- **Confirm email**: `ON` (Keep email confirmations enabled)
- **OTP expiration time**: `600` seconds (10 minutes)
- Click **Save**.

---

## 5. Security Checklist
- ✅ Resend API Key is stored securely in Supabase backend (never in Flutter code or git repository).
- ✅ Flutter client communicates strictly using `Supabase.instance.client.auth.signUp()`, `verifyOTP()`, and `resend()`.
- ✅ OTP codes are 6-digit numeric tokens generated and verified securely by Supabase GoTrue Auth.
- ✅ Unverified users cannot obtain an active authenticated session until their 6-digit OTP is verified.
