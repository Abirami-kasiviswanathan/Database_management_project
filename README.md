# EthiTrack Procurement Dashboard

EthiTrack is a Streamlit dashboard for ethical B2B procurement analysis. It helps an analyst compare suppliers by price, sustainability score, nonprofit partnership status, certifications, lead time, local sourcing, and estimated social impact.

The project is designed for an organizational buyer, not an individual consumer. The old `Users` table and consumer preference dashboard were removed.

## Business Problem

Procurement teams need to choose suppliers that are affordable, reliable, sustainable, and aligned with organizational social-impact goals. EthiTrack supports that decision by combining PostgreSQL analytics, Streamlit dashboards, and a simple AI price-risk model.

## Main Features

- Executive supplier KPI overview
- Product-level supplier ranking
- Vendor comparison matrix
- Annual cost and impact estimate
- AI Supplier Advisor using historical prices
- SQL views for supplier fit score, NPO gap analysis, volatility, risk, and substitution opportunities

The app no longer includes a Streamlit dropdown that displays raw SQL queries. SQL logic stays in the database file.

## Project Files

- `streamlit_app.py`: Main Streamlit app. Use this as the GitHub and Streamlit Cloud entrypoint.
- `Streamlit _610_project_2.py`: Compatibility wrapper that runs `streamlit_app.py`.
- `project_btob_610.sql`: PostgreSQL setup file for tables, sample data, and views.
- `requirements.txt`: Python dependencies.
- `.streamlit/secrets.toml.example`: Example database credentials for deployment.

## Database Setup

Create a PostgreSQL database named:

```text
project_610_npo_sales
```

Then run:

```bash
psql -d project_610_npo_sales -f project_btob_610.sql
```

You can also run the full SQL file in pgAdmin.

## Local Installation

Create and activate a virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Run the app:

```bash
python -m streamlit run streamlit_app.py
```

The app usually opens at:

```text
http://localhost:8501
```

## Database Credentials

For local development, the app reads database settings from environment variables if they exist:

```text
DB_NAME
DB_USER
DB_PASSWORD
DB_HOST
DB_PORT
```

If those are not set, it uses:

```text
database: project_610_npo_sales
user: your computer username
password: blank
host: localhost
port: 5432
```

For Streamlit Community Cloud, add database credentials in app secrets instead of committing passwords to GitHub.

Example secrets:

```toml
[database]
dbname = "project_610_npo_sales"
user = "your_database_user"
password = "your_database_password"
host = "your_database_host"
port = "5432"
```

Do not commit the real `.streamlit/secrets.toml` file.

## GitHub And Web Access

GitHub stores the code, but it does not directly host a running Streamlit Python app like a normal static website. To give others a web link, deploy the GitHub repository on Streamlit Community Cloud.

Recommended deployment steps:

1. Push this folder to a GitHub repository.
2. Make sure `streamlit_app.py`, `requirements.txt`, and `project_btob_610.sql` are included.
3. Go to Streamlit Community Cloud.
4. Create a new app from your GitHub repository.
5. Set the entrypoint file to `streamlit_app.py`.
6. Add database credentials in Streamlit secrets.
7. Deploy and share the generated `streamlit.app` URL.

Important: a deployed app cannot connect to a PostgreSQL database that exists only on your laptop as `localhost`. For public web access, use a hosted PostgreSQL database or run the app locally.

## Dashboard Pages

### Executive Overview

Shows high-level KPIs such as average supplier fit score, certified supplier listings, NPO partner vendors, and average lead time.

### Supplier Ranking

Ranks suppliers for a selected product using the SQL-based supplier fit score.

### Vendor Comparison

Lets analysts compare selected vendors side by side by price, sustainability, lead time, certification, NPO status, and social impact category.

### Annual Impact Report

Uses order volume to estimate projected annual spend, CO2 savings, and community impact.

### AI Supplier Advisor

Uses linear regression on historical prices to predict the next expected supplier price. The app then labels supplier price risk as Low, Medium, or High and adjusts the recommendation score.

## Supplier Fit Score

The SQL view calculates supplier fit score out of 100:

```text
Supplier Fit Score =
  sustainability contribution
+ local supplier bonus
+ NPO partner bonus
+ certification bonus
+ lead time score
+ price competitiveness score
```

This lets the analyst compare suppliers using both business and social-impact criteria.

## Requirements

```txt
streamlit
pandas
psycopg2-binary
scikit-learn
numpy
```

## Notes

- Run `project_btob_610.sql` before launching Streamlit.
- The app depends on `view_procurement_analytics`, `dashboard_main_metrics`, and `npo_impact_gap`.
- The Streamlit app no longer uses `Users` or `user_preference_summary`.
- The SQL file includes optional analysis views for professor review, but the app does not show raw SQL queries in the UI.
