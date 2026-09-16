# UPI Smart Split & Orchestrator (Android & iOS)

A cross-platform UPI payment orchestrator designed to solve high-value transactions (> ₹2,000) under NPCI and RBI regulatory constraints with **two user-selectable architectural options**.

---

## 1. Regulatory Context (Why > ₹2,000 Matters)
- **Interchange Fee on PPI Wallets:** NPCI levies an interchange fee of up to **1.1%** for merchant transactions exceeding ₹2,000 made through prepaid instruments (wallets/PPIs). Standard bank-to-bank UPI has 0% MDR.
- **Cooling Periods & Limits:** Banks and UPI apps apply velocity tripwires and cooling limits for transfers to new payees above ₹2,000.
- **Anti-Structuring (PMLA):** Rapid identical split transfers can trip bank Anti-Money Laundering (AML) algorithms. The app introduces **Anti-Velocity Jitter** to vary tranche amounts and stagger execution.

---

## 2. Supported Modes in the App

### Mode A: Direct Intent Orchestrator (Zero Fees, Client-Side)
- **How it works:** Splits the amount into sub-₹2,000 tranches (e.g. ₹1,985 + ₹1,515 for ₹3,500 total).
- **Execution:** Dispatches native `upi://pay` deep links directly to installed apps (**Google Pay, PhonePe, Paytm, BHIM, CRED**) on Android and iOS.
- **Security:** In compliance with NPCI Common Library (CL) requirements, the user approves each slice with their UPI MPIN sequentially.

### Mode B: Automated Escrow / Gateway AutoPay (1-Click Mandate)
- **How it works:** Uses an RBI-regulated Payment Aggregator / UPI AutoPay e-Mandate architecture.
- **Execution:** User grants **a single authorization** for the total amount. The escrow backend automatically staggers and settles the individual tranches directly to the beneficiary VPA without requiring repeated MPIN entries.

---

## 3. Tech Stack
- **Framework:** React + TypeScript (Vite) / React Native & Expo compatible architecture.
- **Styling:** Custom dark-mode glassmorphic design system tailored for mobile viewports.
- **Protocols:** NPCI standard `upi://pay` URI specifications + vendor-specific deep link schemes (`tez://`, `phonepe://`, `paytmmp://`, `bhim://`, `cred://`).

---

## 4. How to Run Locally

```bash
# 1. Navigate to directory
cd "D:\Antigravity\upi-split-app"

# 2. Install dependencies (already completed)
npm install

# 3. Start development server
npm run dev

# 4. Open in browser / mobile emulator
http://localhost:5173
```

---

## 5. Converting to Native APK / iOS IPA
This core can be wrapped directly via:
- **Capacitor**: `npx cap init` -> `npx cap add android` / `npx cap add ios`
- **Expo / React Native**: Reuses the exact same `upiService.ts` and component logic.