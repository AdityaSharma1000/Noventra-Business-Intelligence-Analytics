# Noventra Business Intelligence & Analytics Platform

An end-to-end data analytics project demonstrating how raw business data can be transformed into meaningful business insights using Excel, SQL Server, and Power BI.

This project simulates a real-world analytics workflow for a fictional global e-commerce company, **Noventra**, covering everything from data preparation and database design to interactive dashboards and executive-level reporting.

---

# Project Overview

The objective of this project is to analyze business performance across sales, customers, products, logistics, and regional markets while demonstrating the complete data analyst workflow.

The project answers real business questions such as:

- Is revenue growth healthy?
- Which customers generate the highest lifetime value?
- Which products drive revenue?
- Where are discounts hurting profitability?
- Which shipping methods create delivery delays?
- Which markets should receive future investment?

---

# Business Problem

Management wants a centralized analytics solution that can:

- Monitor company performance
- Improve operational efficiency
- Identify customer segments
- Optimize pricing strategy
- Track logistics performance
- Support data-driven decision making

---

# Tech Stack

| Tool | Purpose |
|-------|----------|
| Microsoft Excel | Data Cleaning & Preparation |
| SQL Server | Database Design & Business Analysis |
| SQL Server Management Studio | Query Development |
| Power BI Desktop | Dashboard Development |
| DAX | Business Metrics |
| Power Query | Data Transformation |

---

# Project Workflow

```
Raw Dataset
      │
      ▼
Excel Data Cleaning
      │
      ▼
SQL Server Normalization (3NF)
      │
      ▼
Analytical SQL Queries
      │
      ▼
Views
Stored Procedures
Triggers
      │
      ▼
Power BI Data Model
      │
      ▼
DAX Measures
      │
      ▼
Interactive Dashboards
      │
      ▼
Business Insights
```

---

# Database Design

The dataset was normalized into a star schema to improve data quality and query performance.

### Fact Table

- Orders

### Dimension Tables

- Customers
- Products
- Locations
- Dates

The Orders table uses a surrogate key (`order_line_id`) because multiple products can belong to a single order.

---

# SQL Features

The project demonstrates:

- Database normalization (3NF)
- Star schema modelling
- Common Table Expressions (CTEs)
- Window Functions
- Aggregate Functions
- CASE Statements
- Ranking Functions
- Analytical Views
- Stored Procedures
- Triggers
- Audit Logging

---

# Analytical Views

The project includes multiple reusable SQL views including:

- Product Performance
- Customer Segment Insights
- Customer Lifetime Value
- RFM Segmentation
- Monthly Revenue
- Yearly Revenue
- Repeat Purchase Analysis
- Shipping Logistics

---

# Stored Procedures

- Customer Purchase History
- Sales Between Dates
- Customer Churn Analysis

---

# Data Governance

To demonstrate enterprise database concepts, the project includes audit triggers that automatically log every INSERT, UPDATE, and DELETE performed on the Orders table.

---

# Power BI Dashboards

## Executive Dashboard

Focuses on overall business health.

Highlights:

- Revenue
- Orders
- Average Order Value
- Average Selling Price
- YoY Growth
- Revenue Breakdown
- Pricing Simulator

---

## Customer Intelligence Dashboard

Analyzes customer behaviour using:

- Customer Lifetime Value
- RFM Segmentation
- Customer Segments
- Repeat Customers
- Revenue by Age Group
- Customer Growth

---

## Product Intelligence Dashboard

Analyzes product profitability.

Includes:

- Discount Analysis
- Top Products
- Category Performance
- Margin Risk
- Revenue Trends
- Discount Revenue Loss

---

# Business Insights

Some of the key findings include:

- Revenue increased by 25.3% while AOV declined, indicating volume-driven growth.
- Consumer customers contributed over half of total revenue.
- Corporate customers generated the highest customer lifetime value.
- Technology products generated the highest revenue.
- Furniture experienced the highest concentration of heavy discounts.
- Standard Class shipping accounted for all delivery delays.
- APAC generated the highest revenue while Europe showed the fastest growth.

---

# Skills Demonstrated

- Data Cleaning
- Data Modelling
- SQL Development
- Database Design
- Data Warehousing
- ETL Concepts
- Business Intelligence
- Power BI
- DAX
- Data Visualization
- Business Analysis
- KPI Development
- Dashboard Design
- Executive Reporting

---

# Repository Structure

```
├── Dataset/
│   ├── Raw Data
│   └── Cleaned Data
│
├── SQL/
│   ├── Database Creation
│   ├── Normalization
│   ├── Views
│   ├── Stored Procedures
│   ├── Triggers
│   └── Analytical Queries
│
├── Power BI/
│   └── Noventra.pbix
│
├── Report/
│   └── Business Insights Report.pdf
│
├── Dashboard Screenshots/
│
└── README.md
```

---

# Key Skills

- Microsoft Excel
- SQL Server
- SSMS
- Power BI
- DAX
- Power Query
- Data Modeling
- Star Schema
- SQL Views
- Stored Procedures
- Triggers
- Business Intelligence
- Data Visualization
- KPI Reporting

---

# About

This project was created to demonstrate a complete end-to-end data analytics workflow similar to what a Data Analyst performs in a real business environment. Rather than focusing only on dashboard creation, the project covers data preparation, database design, SQL analytics, business intelligence, and executive reporting to transform raw transactional data into actionable business insights.
