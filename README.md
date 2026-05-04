# 🌿 EthiTrack — B2B Ethical Procurement Dashboard

EthiTrack is a Streamlit-based procurement intelligence dashboard that helps organizations make ethical, cost-aware purchasing decisions. It ranks suppliers using a multi-factor scoring engine, highlights NPO partners and sustainability certifications, and includes an AI-powered chatbot assistant that answers procurement questions in natural language — all backed by a PostgreSQL database.

---

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Database Schema](#database-schema)
- [AI Chatbot](#ai-chatbot)
- [Dashboard Pages](#dashboard-pages)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Project Structure](#project-structure)
- [Sample Data](#sample-data)

---

## ✨ Features

- **Supplier Fit Score** — SQL-calculated composite score weighing sustainability, NPO status, location, certifications, lead time, and price competitiveness
- **AI Procurement Chatbot** — Rule-based assistant that recommends suppliers, compares NPO vs commercial partners, and answers natural-language questions about price, lead time, certifications, and social impact
- **Multi-Goal Rankings** — Suppliers ranked by Balanced, Lowest Cost, Social Impact, Sustainability, or Reliability priorities
- **NPO vs Commercial Gap Analysis** — Side-by-side comparison of ethical and commercial supplier metrics
- **Annual Impact Projections** — Estimate yearly spend, CO2 savings, and community impact at a given order volume
- **Price Volatility Tracking** — Historical price data used to flag suppliers with unstable pricing
- **Interactive Filters** — Filter by product, supply chain type (Local / Online), and supplier type (NPO / Commercial)

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Frontend / App | [Streamlit](https://streamlit.io/) |
| Database | PostgreSQL |
| Python DB Driver | psycopg2 |
| Data Processing | pandas |
| AI Chatbot | Rule-based NLP engine (pure Python) |

---

## 🗄 Database Schema

The SQL setup script (`project_btob_610.sql`) creates the following tables and views:

### Tables

```
Category      → category_id, category_name
Vendor        → vendor_id, vendor_name, is_npo_partner, location_type,
                sustainability_score, certification_status, lead_time_days,
                social_impact_category
Product       → product_id, product_name, brand, category_id
Price_Listing → listing_id, product_id, vendor_id, current_stock_status
Price_History → history_id, listing_id, recorded_price, recorded_at
```

### Views

| View | Purpose |
|---|---|
| `dashboard_main_metrics` | Full supplier + product + latest price rollup for the main table |
| `view_procurement_analytics` | Adds supplier fit score, CO2, and community impact estimates |
| `npo_impact_gap` | Aggregated NPO vs commercial comparison |
| `view_efficiency_leaders` | High-sustainability suppliers priced below product average |
| `view_supply_chain_risk` | Lead time risk analysis by social impact category |
| `view_npo_substitution_opportunities` | Suggests NPO alternatives to commercial suppliers |
| `view_price_volatility` | Price standard deviation per vendor-product pair |

### Supplier Fit Score Formula

The score is computed in SQL inside `view_procurement_analytics`:

```
Supplier Fit Score =
  (sustainability_score × 0.40)
  + 15 if Local
  + 15 if NPO Partner
  + 10 if Certified
  + 10/7/4/1 based on lead time tier
  + 0–10 based on price vs market average
```

---

## 🤖 AI Chatbot

Every dashboard page includes a context-aware **AI Procurement Chatbot** powered by a rule-based NLP engine (`answer_chatbot_question`).

### What It Can Answer

| Question Type | Example |
|---|---|
| Supplier recommendation | "Which supplier is best for social impact?" |
| Lowest cost | "Which vendor is the cheapest for Organic Tomatoes?" |
| Fastest delivery | "Which supplier has the fastest lead time?" |
| NPO vs commercial | "Compare NPO and commercial suppliers." |
| Sustainability | "Which vendor has the highest sustainability score?" |
| Certifications | "Which suppliers are certified?" |
| Vendor products | "What products does Thrift & Thrive NPO sell?" |
| Product vendors | "Who sells Single Origin Espresso?" |
| Annual impact | "Which supplier gives the best annual community impact?" |

### How It Works

1. **Intent Detection** — Keywords in the question trigger specific logic branches (e.g., "cheapest" → price sort, "fastest" → lead time sort, "recommend" → multi-factor ranking).
2. **Goal Inference** — Words like "budget", "community", "certified", or "fast" automatically shift the ranking goal (Lowest Cost, Social Impact, Sustainability, Reliability).
3. **Entity Matching** — Vendor names and product names are extracted directly from the question text and matched against live database values.
4. **Contextual Scoping** — The chatbot uses the currently filtered supplier dataset for the active page, so answers reflect the user's selected product and filters.
5. **Explanation Builder** — Recommendations include the supplier type, location, sustainability score, lead time, price vs market average, fit score, and optional annual volume projections.

### Ranking Goals & Weights

| Goal | Key Weights |
|---|---|
| **Balanced** | Fit score 45%, Price 20%, Impact 15%, Speed 10%, Sustainability 10% |
| **Lowest Cost** | Price 55%, Fit score 20%, Speed 15%, Sustainability 10% |
| **Social Impact** | Impact 40%, Sustainability 25%, Fit score 20%, Price 15% |
| **Sustainability** | Sustainability 45%, Certification 20%, Fit score 20%, Impact 15% |
| **Reliability** | Speed 35%, Volatility 25%, Fit score 25%, Price 15% |

---

## 📊 Dashboard Pages

### 1. Executive Overview
- KPI metrics: average fit score, certified listings, NPO vendors, average lead time
- AI Insight Summary for the top balanced supplier
- NPO vs commercial summary table
- Supplier Fit Score bar chart
- Full supplier listing table

### 2. Supplier Ranking
- Ranked supplier table for a selected product
- Price vs Sustainability scatter chart
- Best SQL-ranked supplier callout

### 3. Vendor Comparison
- Side-by-side comparison matrix for selected vendors
- Score comparison bar chart (fit score + sustainability)

### 4. Annual Impact Report
- Adjustable annual order volume slider (100–50,000 units)
- Projected annual spend, estimated CO2 savings, and community impact per supplier
- Recommended supplier by fit score and projected spend

Each page ends with the **AI Procurement Chatbot** scoped to that page's context.

---

## 🚀 Getting Started

### Prerequisites

- Python 3.9+
- PostgreSQL 14+
- pip

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/ethitrack.git
cd ethitrack
```

### 2. Install Dependencies

```bash
pip install streamlit psycopg2-binary pandas
```

### 3. Set Up the Database

Create the database in PostgreSQL and run the setup script:

```bash
psql -U postgres -c "CREATE DATABASE project_610_npo_sales;"
psql -U postgres -d project_610_npo_sales -f project_btob_610.sql
```

### 4. Configure the Connection

Choose one of the options in the [Configuration](#configuration) section below.

### 5. Run the App

```bash
streamlit run streamlit_app.py
```

Open your browser to `http://localhost:8501`.

---

## ⚙️ Configuration

The app resolves the database connection in this priority order:

1. **Streamlit Secrets** (recommended for deployment) — create `.streamlit/secrets.toml`:

```toml
[database]
dbname   = "project_610_npo_sales"
user     = "your_pg_user"
password = "your_pg_password"
host     = "localhost"
port     = "5432"
```

2. **Environment Variables**:

```bash
export DB_NAME=project_610_npo_sales
export DB_USER=your_pg_user
export DB_PASSWORD=your_pg_password
export DB_HOST=localhost
export DB_PORT=5432
```

3. **Defaults** — falls back to `localhost:5432`, database `project_610_npo_sales`, and the current system user with no password.

---

## 📁 Project Structure

```
ethitrack/
├── streamlit_app.py          # Main Streamlit application
├── project_btob_610.sql      # PostgreSQL schema, seed data, and views
├── .streamlit/
│   └── secrets.toml          # DB credentials (not committed to git)
└── README.md
```

> Add `.streamlit/secrets.toml` to `.gitignore` to keep credentials out of version control.

---

## 🌱 Sample Data

The SQL script seeds the database with realistic Bay Area procurement data:

**5 Product Categories** — Fair Trade Coffee, Ethical Apparel, Organic Produce, Reusable Goods, Eco Cleaning

**12 Vendors** including:
- East Bay Community Garden (NPO, Local, sustainability score 95)
- Kindness Coffee Project (NPO, Online, sustainability score 93)
- Thrift & Thrive NPO (NPO, Local, sustainability score 98)
- Pacific Organic Co-op (Commercial, Local, sustainability score 84)
- Green-Tech Solutions (Commercial, Online, sustainability score 65)

**5 Products** with 4 vendor listings each and 4 months of price history (Jan–Apr 2026).

---

## 📝 License

This project was developed as an academic B2B procurement analytics capstone. Feel free to fork and adapt with attribution.
