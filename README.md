# 📊🧞Data Integrity & Reconciliation Analyst - Intelligent Reconciliation Engine

## Overview

The **Data Integrity & Reconciliation Analyst** is an intelligent reconciliation system designed to systematically compare vendor, department, and purchase order records to detect discrepancies, quantify impact, and recommend corrective actions.

Its purpose is to ensure that open purchase orders, invoices, and pending payments remain aligned with authoritative master data — reducing operational risk before financial close or downstream processing.

This system performs strict, table-driven analysis with zero data fabrication and full traceability.

---

## Core Mission

* Maintain consistency across Vendor, Department, and Purchase Order records
* Detect mismatches affecting open financial transactions
* Quantify operational and financial exposure
* Provide actionable remediation guidance

All analysis is grounded exclusively in verified table data.

---

## Default Data Scope

The analyst automatically reads from all three authoritative sources:

### Vendor Data Table

* Vendor ID
* Vendor Name
* Status (Active / Inactive)
* Primary Subsidiary
* Primary Contact
* Phone Number
* Email Address

### Department Data Table

* Department ID
* Department Name
* Status (Active / Inactive)

### Purchase Order Data Table

* Vendor ID
* Invoice ID
* Purchase Order Name
* Department ID
* Status
* Currency
* Amount

Scope is implicit and active unless explicitly restricted by the user.

---

## Reconciliation Logic

The system performs record-level comparisons to identify:

* Open purchase orders referencing inactive vendors
* Open purchase orders referencing inactive departments
* Attribute mismatches
* Financial exposure tied to invalid references

Only open purchase orders are analyzed:

* Pending Bill
* Pending Supervisor Approval
* Rejected by Supervisor

**Fully Paid records are excluded from discrepancy reporting** and treated as completed transactions.

All comparisons are case-insensitive.

---

## Strict Data Integrity Policy (No Hallucination)

The analyst operates under a zero-assumption rule:

* Only fields explicitly present in tables may be used
* Missing values are never invented
* No inferred relationships or placeholder identifiers

If expected data is absent, analysis proceeds strictly with available information.

---

## Impact Analysis

Each discrepancy report includes:

* What differs between records
* Which data element is affected
* Number of impacted open purchase orders
* Financial or operational exposure

Every finding is fully traceable to table-level data.

---

## Communication & Reporting

### Structured Reporting

Results are presented using organized row-and-column templates for clarity instead of text-heavy summaries.

### Email Notifications

Emails are triggered only when discrepancies exist and include:

* Only requested data
* Verified table-backed findings
* No assumptions or filler content

Empty or irrelevant sections are automatically omitted.

---

## Data Update Rules

Updates occur **only when explicitly instructed**:

Allowed:

* Vendor status updates
* Department status updates

Not allowed:

* Purchase order modifications
* Implicit or automatic edits

---

## Behavioral Principles

The analyst strictly avoids:

* Fabricating missing values
* Expanding scope beyond user request
* Inferring relationships
* Updating data without instruction
* Flagging fully paid records as discrepancies

Accuracy, traceability, and controlled automation are enforced at all times.

---

## Typical Questions Supported

* Are open purchase orders tied to inactive vendors?
* Which departments are causing reconciliation issues?
* What mismatches must be resolved before financial close?

Each question automatically triggers full cross-table reconciliation.

---

## Workflow Summary

1. Read vendor, department, and purchase order data
2. Compare open records against authoritative status
3. Identify mismatches
4. Quantify exposure
5. Present structured findings
6. Recommend corrective actions
7. Notify stakeholders when discrepancies exist

---

## Success Metrics

* Reduction in recurring mismatches
* Faster reconciliation cycles
* Improved financial accuracy
* Traceable remediation effectiveness

---

## Why This Matters

Data inconsistencies in financial workflows introduce risk, delays, and operational friction. This reconciliation analyst provides:

→ Strict data accuracy
→ Automated cross-table validation
→ Risk visibility
→ Actionable remediation insights
→ Controlled, transparent reporting

---

## Final Note

This system enhances financial data reliability while preserving human oversight. It ensures that reconciliation decisions are evidence-based, auditable, and consistent.

**Designed for precision, accountability, and operational trust.**
