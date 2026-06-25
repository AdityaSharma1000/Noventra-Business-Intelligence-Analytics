# Business Questions & Insights

This document explains the business value behind each SQL query, view, stored procedure, and trigger used in the Noventra End-to-End Business Intelligence Solution project. The objective is to demonstrate that the project answers real business questions rather than only showcasing SQL syntax.

## Dataset Overview
- **Source:** Noventra end to end sales performance analytics
- **Records processed:** 100,000+ orders (bulk imported)
- **Database design:** 3NF normalized schema
- **Core tables:** Orders, Customers, Products, Locations, Dates

---

## 1. Month-over-Month (MoM) Revenue Analysis

**Business Question**
- How did revenue change compared with the previous month?

**Key Metrics**
- Monthly Revenue
- Previous Month Revenue
- MoM Growth (%)

**Business Insight**
Shows whether sales are accelerating or slowing. Negative growth can indicate seasonality, inventory shortages, pricing issues, or ineffective campaigns.

**Decision Supported**
- Adjust monthly sales targets
- Improve promotional planning
- Forecast future revenue

---

## 2. Year-over-Year (YoY) Revenue Analysis

**Business Question**
- Is the business growing compared to the previous year?

**Key Metrics**
- Annual Revenue
- Previous Year Revenue
- YoY Growth (%)

**Business Insight**
Measures long-term business growth while reducing seasonal effects.

**Decision Supported**
- Annual planning
- Budget allocation
- Business performance evaluation

---

## 3. Customer Lifetime Value (CLV)

**Business Question**
- Which customers generate the most revenue?

**Key Metrics**
- Total Revenue per Customer
- Customer Rank (DENSE_RANK)

**Business Insight**
Identifies the customers contributing the highest lifetime revenue.

**Decision Supported**
- Loyalty programs
- VIP customer identification
- Personalized marketing

---

## 4. Top 5 Products

**Business Question**
- Which five products generate the highest revenue?

**Key Metrics**
- Total Revenue
- Total Quantity Sold
- Product Rank

**Business Insight**
Highlights products that drive the majority of sales.

**Decision Supported**
- Inventory optimization
- Marketing focus
- Demand forecasting

---

## 5. Bottom 5 Products

**Business Question**
- Which five products perform the worst?

**Key Metrics**
- Lowest Revenue
- Lowest Quantity Sold

**Business Insight**
Identifies products with weak demand.

**Decision Supported**
- Product discontinuation
- Discount strategies
- Inventory reduction

---

## 6. Product Performance View

**Business Question**
- How are products performing across categories?

**Key Metrics**
- Revenue
- Quantity Sold
- Discount
- Product Category

**Business Insight**
Provides a single analytical view of product performance.

---

## 7. Customer Demographics & Segment Insights

**Business Question**
- Which customer segments contribute the most revenue?

**Key Metrics**
- Customer Segment
- Age Group
- Revenue
- Orders

**Business Insight**
Helps understand purchasing behaviour across customer groups.

---

## 8. Shipping & Logistics Efficiency

**Business Question**
- Which shipping methods are used most frequently?

**Key Metrics**
- Ship Mode
- Order Count
- Delivery Dates

**Business Insight**
Supports logistics performance analysis.

---

## 9. Customer Purchase History (Stored Procedure)

**Input**
- Customer ID

**Output**
- Complete purchase history of the selected customer.

**Business Value**
Supports customer service and personalized recommendations.

---

## 10. Sales Between Two Dates (Stored Procedure)

**Inputs**
- Start Date
- End Date

**Output**
- Sales transactions within the selected period.

**Business Value**
Supports custom reporting and campaign analysis.

---

## 11. Customer Churn Analysis (Stored Procedure)

**Input**
- Number of inactivity days

**Key Metrics**
- Last Purchase Date
- Days Since Last Purchase
- Lifetime Revenue

**Business Insight**
Identifies inactive customers who may be at risk of churn.

**Business Value**
Supports retention campaigns.

---

## 12. Audit Triggers

**Events Captured**
- INSERT
- UPDATE
- DELETE

**Captured Information**
- Order ID
- Action Type
- Action Timestamp

**Business Insight**
Maintains a complete audit trail of changes made to the Orders table, improving accountability and traceability.
