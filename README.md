# Database Management Project - Setup & Running Guide

## 📋 Project Files

- **`index.html`** - Project guidelines (view in browser)
- **`project_610_guidelines.pdf`** - Documentation of project steps
- **`project_1.sql`** - Database schema and SQL queries
- **`Streamlit _610_project.py`** - Interactive dashboard application
- **`610_data_project.py`** - Data processing script
- **`requirements.txt`** - Python dependencies

---

## 🚀 Quick Start Guide

### Step 1: Clone the Repository
```bash
git clone https://github.com/Abirami-kasiviswanathan/Database_management_project.git
cd Database_management_project
```

### Step 2: Install Dependencies
```bash
pip install -r requirements.txt
```

### Step 3: Set Up Database (PostgreSQL)
```bash
# Create a PostgreSQL database
createdb your_database_name

# Load the SQL schema
psql -U your_username -d your_database_name -f project_1.sql
```

### Step 4: Run the Streamlit App
```bash
streamlit run "Streamlit _610_project.py"
```

The app will open at `http://localhost:8501`

---

## 📦 Requirements

- Python 3.8+
- PostgreSQL 12+
- pip (Python package manager)

**Python Packages:**
- streamlit - Interactive web app framework
- psycopg2-binary - PostgreSQL database adapter
- pandas - Data manipulation library

---

## 📚 Project Structure

```
Database_management_project/
├── index.html                      # View in browser
├── project_610_guidelines.pdf      # Project documentation
├── project_1.sql                   # Database schema & queries
├── Streamlit _610_project.py       # Main dashboard app
├── 610_data_project.py             # Data processing
├── requirements.txt                # Python dependencies
└── README.md                       # This file
```

---

## ⚙️ Configuration

Before running the Streamlit app, update the database connection details in `Streamlit _610_project.py`:

```python
connection = psycopg2.connect(
    host="localhost",
    user="your_username",
    password="your_password",
    database="your_database_name"
)
```

---

## 🎯 Usage

1. Open the Streamlit app: `streamlit run "Streamlit _610_project.py"`
2. Interact with the dashboard
3. Run queries and view analytics
4. Explore the data visualizations

---

## 📖 For More Information

- View the **Project Guidelines**: Click on `index.html` in the repo
- Read the **PDF Documentation**: `project_610_guidelines.pdf`
- Check the **SQL Queries**: `project_1.sql`

---

**Last Updated:** April 24, 2026
