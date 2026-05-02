# ─────────────────────────────────────────────
# IMPORTS
# ─────────────────────────────────────────────
import streamlit as st
import pandas as pd
from sqlalchemy import create_engine, text
import anthropic

# ─────────────────────────────────────────────
# PAGE CONFIG
# This sets the browser tab title and layout
# ─────────────────────────────────────────────
st.set_page_config(
    page_title="Skill-Gap HRIS Auditor",
    page_icon="📊",
    layout="wide"
)



def add_custom_styling():
    st.markdown("""
    <style>
    /* ── Google Fonts ── */
    @import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500&family=Raleway:wght@600;700&display=swap');

    /* ── Soft warm gradient background ── */
    .stApp {
        background: linear-gradient(135deg, #fdf6f0 0%, #f3e8ff 50%, #fce7f3 100%);
        background-attachment: fixed;
    }

    /* ── Main title ── */
    h1 {
        font-family: 'Raleway', sans-serif !important;
        font-weight: 700 !important;
        color: #5b21b6 !important;
    }

    /* ── Subheadings ── */
    h2, h3 {
        font-family: 'Raleway', sans-serif !important;
        color: #7c3aed !important;
    }

    /* ── Body text ── */
    body, p, div, span, label {
        font-family: 'DM Sans', sans-serif !important;
        color: #3d3d3a !important;
    }

    /* ── Metric cards ── */
    [data-testid="metric-container"] {
        background: white !important;
        border: 1px solid #e9d5ff !important;
        border-radius: 16px !important;
        padding: 1rem !important;
        box-shadow: 0 2px 12px rgba(139, 92, 246, 0.08) !important;
    }

    /* ── Metric value ── */
    [data-testid="metric-container"] [data-testid="stMetricValue"] {
        color: #7c3aed !important;
        font-family: 'Raleway', sans-serif !important;
        font-weight: 700 !important;
    }

    /* ── Metric label ── */
    [data-testid="metric-container"] [data-testid="stMetricLabel"] {
        color: #6b7280 !important;
        font-size: 13px !important;
    }

    /* ── Sidebar ── */
    [data-testid="stSidebar"] {
        background: white !important;
        border-right: 1px solid #e9d5ff !important;
    }

    /* ── Sidebar text ── */
    [data-testid="stSidebar"] label,
    [data-testid="stSidebar"] p,
    [data-testid="stSidebar"] span {
        color: #4b5563 !important;
    }

    /* ── Sidebar header ── */
    [data-testid="stSidebar"] h1,
    [data-testid="stSidebar"] h2,
    [data-testid="stSidebar"] h3 {
        color: #5b21b6 !important;
    }

    /* ── Main content area ── */
    .block-container {
        background: transparent !important;
        padding-top: 2rem !important;
    }

    /* ── Dataframe ── */
    [data-testid="stDataFrame"] {
        background: white !important;
        border-radius: 12px !important;
        border: 1px solid #e9d5ff !important;
        box-shadow: 0 2px 8px rgba(139, 92, 246, 0.06) !important;
    }

    /* ── Tabs ── */
    .stTabs [data-baseweb="tab-list"] {
        background: white !important;
        border-radius: 12px !important;
        padding: 4px !important;
        border: 1px solid #e9d5ff !important;
    }

    .stTabs [data-baseweb="tab"] {
        font-family: 'DM Sans', sans-serif !important;
        color: #6b7280 !important;
        border-radius: 8px !important;
    }

    .stTabs [aria-selected="true"] {
        background: linear-gradient(135deg, #ede9fe, #fce7f3) !important;
        color: #5b21b6 !important;
        font-weight: 500 !important;
    }

    /* ── Button ── */
    .stButton button {
        background: linear-gradient(135deg, #7c3aed, #a855f7) !important;
        color: white !important;
        border: none !important;
        border-radius: 10px !important;
        font-family: 'DM Sans', sans-serif !important;
        font-weight: 500 !important;
        padding: 0.5rem 1.5rem !important;
    }

    .stButton button:hover {
        background: linear-gradient(135deg, #5b21b6, #7c3aed) !important;
        transform: translateY(-1px);
    }

    /* ── Text input ── */
    .stTextInput input {
        background: white !important;
        border: 1px solid #e9d5ff !important;
        border-radius: 10px !important;
        color: #3d3d3a !important;
        font-family: 'DM Sans', sans-serif !important;
    }

    .stTextInput input:focus {
        border-color: #a855f7 !important;
        box-shadow: 0 0 0 3px rgba(168, 85, 247, 0.1) !important;
    }

    /* ── Selectbox ── */
    .stSelectbox > div > div {
        background: white !important;
        border: 1px solid #e9d5ff !important;
        border-radius: 10px !important;
        color: #3d3d3a !important;
    }

    /* ── Divider ── */
    hr {
        border-color: #e9d5ff !important;
    }

    /* ── Caption ── */
    .stCaption, small {
        color: #9ca3af !important;
        font-family: 'DM Sans', sans-serif !important;
    }

    /* ── Success box (AI answer) ── */
    .stSuccess {
        background: linear-gradient(135deg, #fdf4ff, #fce7f3) !important;
        border: 1px solid #e9d5ff !important;
        border-radius: 12px !important;
        color: #5b21b6 !important;
    }

    /* ── Checkbox ── */
    .stCheckbox label {
        color: #4b5563 !important;
        font-family: 'DM Sans', sans-serif !important;
    }
    </style>
    """, unsafe_allow_html=True)

add_custom_styling()
# ─────────────────────────────────────────────
# DATABASE CONNECTION
# Change to your actual credentials
# ─────────────────────────────────────────────
@st.cache_resource
def get_engine():
    return create_engine(
        "postgresql://abiramikasiviswanathan@localhost:5432/skill_gap"
    )

engine = get_engine()

# ─────────────────────────────────────────────
# ANTHROPIC CLIENT
# This powers your AI question box
# Get your API key from console.anthropic.com
# ─────────────────────────────────────────────
client = anthropic.Anthropic(api_key="YOUR_ANTHROPIC_API_KEY")

# ─────────────────────────────────────────────
# HEADER
# ─────────────────────────────────────────────
st.title("Skill-Gap HRIS Auditor")
st.caption("AI-powered internal mobility & equity engine — 500 employee profiles")
st.divider()

# ─────────────────────────────────────────────
# SIDEBAR FILTERS
# These filters change what the queries return
# ─────────────────────────────────────────────
with st.sidebar:
    st.header("Filters")

    department = st.selectbox(
        "Department",
        ["All", "Finance", "HR", "IT", "Operations", "Legal"]
    )

    role = st.selectbox(
        "Role",
        ["All", "Analyst", "Senior Analyst", "Manager", "Coordinator"]
    )

    gap_filter = st.selectbox(
        "Gap Severity",
        ["All", "Critical Gap", "Moderate Gap", "Minor Gap"]
    )

    bias_free = st.checkbox("Bias-Free Mode (hide names)", value=True)
    adjacent_only = st.checkbox("Show Adjacent Candidates Only", value=False)

    st.divider()
    st.caption("Built for Codex Challenge 2026")

# ─────────────────────────────────────────────
# HELPER — build WHERE clause from filters
# This dynamically adds filters to SQL
# ─────────────────────────────────────────────
def build_filters():
    conditions = []
    if department != "All":
        conditions.append(f"e.department = '{department}'")
    if role != "All":
        conditions.append(f"e.role = '{role}'")
    if gap_filter != "All":
        conditions.append(f"""
            CASE
                WHEN (j.required_level - e.proficiency) = 1 THEN 'Minor Gap'
                WHEN (j.required_level - e.proficiency) = 2 THEN 'Moderate Gap'
                ELSE 'Critical Gap'
            END = '{gap_filter}'
        """)
    if adjacent_only:
        conditions.append("(j.required_level - e.proficiency) = 1")
    return "AND " + " AND ".join(conditions) if conditions else ""

# ─────────────────────────────────────────────
# METRIC CARDS — top summary numbers
# These always show full dataset counts
# ─────────────────────────────────────────────
@st.cache_data
def get_metrics():
    q = """
    WITH gap_analysis AS (
        SELECT e.employee_id, e.role, e.skill_name,
               e.proficiency, j.required_level,
               (j.required_level - e.proficiency) AS gap_score
        FROM employee_skills e
        JOIN job_competencies j
          ON e.skill_name = j.skill_name
         AND e.role = j.role_name
    )
    SELECT
        COUNT(DISTINCT employee_id)                                    AS total_employees,
        COUNT(DISTINCT CASE WHEN gap_score > 0 THEN employee_id END)  AS employees_with_gaps,
        COUNT(DISTINCT CASE WHEN gap_score >= 3 THEN employee_id END) AS critical_gaps,
        COUNT(DISTINCT CASE WHEN gap_score = 1 THEN employee_id END)  AS adjacent_candidates
    FROM gap_analysis
    """
    return pd.read_sql(q, engine).iloc[0]

metrics = get_metrics()

col1, col2, col3, col4 = st.columns(4)
col1.metric("Total Employees",        int(metrics["total_employees"]))
col2.metric("Employees With Gaps",    int(metrics["employees_with_gaps"]))
col3.metric("Critical Gaps",          int(metrics["critical_gaps"]))
col4.metric("Adjacent Candidates",    int(metrics["adjacent_candidates"]))

st.divider()

# ─────────────────────────────────────────────
# AI QUESTION BOX
# This is your Codex platform feature
# Uses Anthropic API to answer HR questions
# based on actual data pulled from PostgreSQL
# ─────────────────────────────────────────────
st.subheader("Ask the AI")
st.caption("Ask any question about your workforce data")

user_question = st.text_input(
    label="Question",
    placeholder="e.g. Which department has the biggest skill gap?",
    label_visibility="collapsed"
)

if st.button("Ask AI ↗") and user_question:
    with st.spinner("Analysing your workforce data..."):

        # Pull summary data to give AI context
        summary_q = """
        SELECT e.department, e.role,
               ROUND(AVG(j.required_level - e.proficiency), 2) AS avg_gap,
               COUNT(DISTINCT e.employee_id) AS employees_affected
        FROM employee_skills e
        JOIN job_competencies j
          ON e.skill_name = j.skill_name
         AND e.role = j.role_name
        WHERE j.required_level > e.proficiency
        GROUP BY e.department, e.role
        ORDER BY avg_gap DESC
        LIMIT 10
        """
        summary_df = pd.read_sql(summary_q, engine)
        summary_text = summary_df.to_string(index=False)

        # Send to Claude with data context
        response = client.messages.create(
            model="claude-opus-4-5",
            max_tokens=500,
            messages=[
                {
                    "role": "user",
                    "content": f"""You are an HR data analyst assistant.
                    
Here is a summary of skill gap data from our HRIS system:

{summary_text}

Total employees: {int(metrics['total_employees'])}
Employees with gaps: {int(metrics['employees_with_gaps'])}
Critical gaps: {int(metrics['critical_gaps'])}
Adjacent candidates: {int(metrics['adjacent_candidates'])}

Answer this question clearly and concisely in 2-3 sentences:
{user_question}"""
                }
            ]
        )

        st.success(response.content[0].text)

st.divider()

# ─────────────────────────────────────────────
# THREE TABS — one per SQL query
# ─────────────────────────────────────────────
tab1, tab2, tab3 = st.tabs([
    "Gap Finder",
    "Department Readiness",
    "Training ROI"
])

# ── TAB 1: Gap Finder ──
with tab1:
    st.caption("Which employees have the biggest skill gap for their role?")

    filters = build_filters()

    q1 = f"""
    WITH gap_analysis AS (
        SELECT e.employee_id,
               {'e.employee_name,' if not bias_free else ''}
               e.department, e.role, e.skill_name,
               e.proficiency AS current_level,
               j.required_level,
               (j.required_level - e.proficiency) AS gap_score
        FROM employee_skills e
        JOIN job_competencies j
          ON e.skill_name = j.skill_name
         AND e.role = j.role_name
        WHERE j.required_level > e.proficiency
        {filters}
    )
    SELECT *,
        CASE
            WHEN gap_score = 1 THEN 'Minor Gap'
            WHEN gap_score = 2 THEN 'Moderate Gap'
            ELSE 'Critical Gap'
        END AS gap_category
    FROM gap_analysis
    ORDER BY gap_score DESC
    LIMIT 100
    """

    df1 = pd.read_sql(q1, engine)
    st.dataframe(df1, use_container_width=True, hide_index=True)
    st.caption(f"{len(df1)} records shown")

# ── TAB 2: Department Readiness ──
with tab2:
    st.caption("Which department is furthest from meeting role requirements?")

    q2 = f"""
    SELECT e.department, e.role,
           ROUND(AVG(j.required_level - e.proficiency), 2) AS avg_gap,
           COUNT(DISTINCT e.employee_id) AS employees_affected
    FROM employee_skills e
    JOIN job_competencies j
      ON e.skill_name = j.skill_name
     AND e.role = j.role_name
    WHERE j.required_level > e.proficiency
    {'AND e.department = ' + chr(39) + department + chr(39) if department != 'All' else ''}
    {'AND e.role = ' + chr(39) + role + chr(39) if role != 'All' else ''}
    GROUP BY e.department, e.role
    ORDER BY avg_gap DESC
    """

    df2 = pd.read_sql(q2, engine)
    st.dataframe(df2, use_container_width=True, hide_index=True)

    # Bar chart of avg gap by department
    st.bar_chart(df2.set_index("department")["avg_gap"])

# ── TAB 3: Training ROI ──
with tab3:
    st.caption("What is the highest ROI course to close each employee's gap?")

    q3 = f"""
    WITH gap_analysis AS (
        SELECT e.employee_id, e.role, e.skill_name,
               e.proficiency AS current_level,
               j.required_level,
               (j.required_level - e.proficiency) AS gap_score
        FROM employee_skills e
        JOIN job_competencies j
          ON e.skill_name = j.skill_name
         AND e.role = j.role_name
        WHERE j.required_level > e.proficiency
    )
    SELECT g.employee_id, g.skill_name, g.gap_score,
           l.course_name, l.provider,
           l.duration_hours, l.cost_usd,
           ROUND(g.gap_score * 1.0 / NULLIF(l.cost_usd, 0), 4) AS roi_score
    FROM gap_analysis g
    JOIN learning_paths l ON g.skill_name = l.skill_name
    ORDER BY roi_score DESC
    LIMIT 100
    """

    df3 = pd.read_sql(q3, engine)
    st.dataframe(df3, use_container_width=True, hide_index=True)

# ─────────────────────────────────────────────
# FOOTER
# ─────────────────────────────────────────────
st.divider()
st.caption("Skill-Gap HRIS Auditor | Built with PostgreSQL + Python + Claude AI | Codex Challenge 2026")

