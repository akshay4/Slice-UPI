# SliceUPI System Architecture & Technical Specification

## 1. Executive Summary & Problem Statement

In the Indian Digital Payments ecosystem governed by the **National Payments Corporation of India (NPCI)** and the **Reserve Bank of India (RBI)**, peer-to-merchant (P2M) and peer-to-peer (P2P) transactions exceeding **₹2,000** face specific regulatory rules and financial structures:

1. **Prepaid Payment Instrument (PPI) Interchange Surcharge:**
   - Transactions > ₹2,000 made via PPI Wallets (Paytm Wallet, PhonePe Wallet, Amazon Pay) to merchant VPAs attract an interchange fee of up to **1.1%**.
   - Traditional bank-to-bank UPI transfers (via normal savings/current accounts) operate under a government-mandated **Zero Merchant Discount Rate (0% MDR)** framework.
2. **Bank Velocity & Cooling Thresholds:**
   - Newly added or non-whitelisted payees frequently encounter 24-hour cooling caps (e.g. ₹2,000–₹5,000 max within the first 24 hours of first transfer).
3. **Anti-Structuring & PMLA Algorithms:**
   - Splitting large amounts into exact identical slices (e.g. 5x ₹2,000) trips core banking Anti-Money Laundering (AML) triggers known as "Structuring" under the Prevention of Money Laundering Act (PMLA).

**SliceUPI** provides an intelligent orchestrator offering two distinct, compliant execution architectures to split and settle payments while mitigating fees, avoiding friction, and maintaining regulatory integrity.

---

## 2. Architectural Comparison: Mode A vs. Mode B

```mermaid
graph TD
    A[Total Payment > ₹2,000] --> B{User Selects Mode}
    
    %% Mode A: Direct Intent
    B -->|Mode A: Direct Intent| C[Slice Calculator]
    C --> D[Sub-₹2,000 Tranches with Anti-Velocity Jitter]
    D --> E[Client-Side Intent Dispatcher]
    E -->|upi://pay or vendor scheme| F[Installed UPI App GPay / PhonePe]
    F -->|User enters MPIN per slice| G[Direct Bank-to-Bank Settlement]
    
    %% Mode B: Escrow / Mandate
    B -->|Mode B: Auto Mandate| H[1-Click e-Mandate Authorization]
    H -->|UPI AutoPay Pre-authorization| I[RBI-Regulated Escrow Pipeline]
    I --> J[Automated Staggered Payout Engine]
    J -->|Staggered Dispersal| K[Beneficiary VPA Settlement]
```

### Comparative Breakdown

| Attribute | Mode A: Direct Intent Orchestrator | Mode B: Automated Escrow / AutoPay Mandate |
| :--- | :--- | :--- |
| **Fees & Surcharges** | **Zero (0% MDR)** — Direct bank transfers | Nominal escrow/gateway processing fee |
| **MPIN Approvals** | 1 MPIN entry per slice (sequential) | **1 single MPIN authorization** for entire sum |
| **Intermediary Custody** | **None** — Funds travel directly P2P/P2M | Regulated Escrow / Nodal Account (RBI PA/PG guidelines) |
| **User Friction** | Moderate (confirms each slice in UPI app) | **Minimal** (hands-off automated execution) |
| **Regulatory Framework**| NPCI UPI Common Library (CL) Specs | RBI Master Directions on Payment Aggregators & AutoPay |
| **Anti-Velocity Jitter** | Dynamic randomization (e.g., ₹1,978 + ₹1,522) | Automated time-staggered backend dispersal |

---

## 3. Mathematical Splitting & Anti-Velocity Jitter Algorithm

To avoid tripping bank fraud algorithms and PMLA filters, amounts are not divided equally. Slice amounts use a bounded random jitter:

$$\text{Slice}_i = \text{Threshold} + \Delta, \quad \Delta \in [-15, +15]$$

- Default ceiling limit: **₹1,990** (configurable to ₹1,950 or ₹1,800).
- Remainder smoothing: If the final remaining balance would be less than ₹100, the last two tranches are re-balanced to prevent micro-slice anomalies.

```typescript
// Sample Jitter Calculation Logic
if (randomizeJitter) {
  const jitter = Math.floor(Math.random() * 30) - 15; // -15 to +14 INR
  sliceAmount = Math.max(500, Math.min(threshold, threshold + jitter));
}
```

---

## 4. NPCI Deep Link Specifications & App Intent Schemes

SliceUPI dynamically builds standard NPCI URIs as well as vendor-specific deep link schemes for zero-friction handoff.

### NPCI Standard URI Schema
```text
upi://pay?pa={vpa}&pn={payeeName}&am={amount}&cu=INR&tn={note}&tr={txnRef}
```

### Parameter Mapping

| Parameter | Name | Description | Example |
| :--- | :--- | :--- | :--- |
| `pa` | Payee Address | Beneficiary Virtual Payment Address | `merchantstore@oksbi` |
| `pn` | Payee Name | Legal or registered name of beneficiary | `Suresh Electronics` |
| `am` | Amount | Sliced tranche amount formatted to 2 decimals | `1990.00` |
| `cu` | Currency | ISO currency code | `INR` |
| `tn` | Transaction Note | Purpose note with slice sequence tracker | `Invoice Part 1/2` |
| `tr` | Transaction Reference | Cryptographically random unique reference ID | `SP1565495STB2EN` |

### App-Specific Deep Link Schemes

When running on native Android / iOS or mobile web:
- **Google Pay (Tez):** `tez://upi/pay?...`
- **PhonePe:** `phonepe://upi/pay?...`
- **Paytm:** `paytmmp://upi/pay?...`
- **BHIM (NPCI):** `bhim://pay?...`
- **CRED:** `cred://upi/pay?...`

---

## 5. Security, State Machine & Regulatory Compliance

1. **No Storage of Sensitive Payment Credentials:** SliceUPI never requests, reads, or caches card numbers, bank account numbers, or MPINs. All credential entry is delegated to the NPCI Common Library (CL) within the user's chosen bank application.
2. **Idempotency & Replay Prevention:** Every generated slice is assigned an immutable `txnRef` timestamped with microsecond entropy.
3. **Transaction State Machine:**
   - `pending` -> Initial slice plan generated.
   - `processing` -> Intent dispatched or payment intent triggered.
   - `completed` -> User confirms MPIN submission or webhook callback verified.
   - `failed` -> Interrupted or declined by bank.
