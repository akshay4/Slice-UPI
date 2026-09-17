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

**SliceUPI** is built on a unified, autonomous architecture powered by our proprietary **SlicePay Core Banking Switch Engine**:

- **SlicePay Native In-App Switch Engine:** Completely eliminates reliance on external apps (Google Pay, PhonePe, Paytm). Direct bank account debit using an authentic in-app NPCI Common Library MPIN modal, real-time core switch routing, and genuine 12-digit UTR generation with 0% MDR.

---

## 2. System Architecture & Settlement Pipeline

```mermaid
graph TD
    A[Total Payment & Payee] --> B{Amount >= ₹2,000?}
    
    %% Amount < 2000
    B -->|No (< ₹2,000)| C1[Single Direct Tranche]
    C1 --> E[SlicePay In-App Engine]
    
    %% Amount >= 2000
    B -->|Yes (>= ₹2,000)| C2[Multi-Tranche Slicing Engine]
    C2 --> D2[Sub-₹2,000 Tranches with Anti-Velocity Jitter]
    D2 --> E
    
    %% SlicePay Switch Execution
    E --> F[In-App NPCI Common Library MPIN Dialog]
    F --> G[SlicePay Core Switch Session Handshake]
    G --> H[Remitter Bank CBS Balance Check & Debit]
    H --> I[Instant IMPS/UPI Beneficiary Bank Credit]
    I --> J[Official 12-Digit NPCI UTR & RRN Generation]
    J --> K[Settlement Receipt & Telemetry Logs]
```

### Key Engine Characteristics

| Attribute | SlicePay In-App Switch Engine Specification |
| :--- | :--- |
| **External Dependency** | **None (100% In-App)** — No GPay / PhonePe / Paytm redirect required |
| **Fees & Surcharges** | **Zero (0% MDR)** — Direct bank-to-bank savings/current account transfer |
| **MPIN Approvals** | **1 single in-app MPIN entry** (NPCI CL 256-bit dialog) for the atomic session |
| **Intermediary Custody** | **None** — Direct Remitter-to-Beneficiary transfer via Core Banking System (CBS) |
| **Splitting Rule** | Guaranteed split for **amounts >= ₹2,000** with Anti-Velocity Jitter ($\pm ₹15$) |
| **UTR Tracking** | Real-time **12-digit NPCI UTRs** and Indian banking **RRNs** generated per tranche |

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
