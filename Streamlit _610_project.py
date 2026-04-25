import streamlit as st
import psycopg2
import pandas as pd
 
# ─────────────────────────────────────────────
# DATABASE
# ─────────────────────────────────────────────
def get_data(query):
    conn = psycopg2.connect(
        dbname="project_610_npo_sales",
        user="abiramikasiviswanathan",
        password="",
        host="localhost"
    )
    df = pd.read_sql(query, conn)
    conn.close()
    return df
 
# ─────────────────────────────────────────────
# SUPPLIER FIT SCORE
# ─────────────────────────────────────────────
def compute_fit_score(row, avg_price):
    sustainability_pts = row['sustainability_score'] * 0.5
    local_pts = 30 * 0.3 if row['location_type'] == 'Local' else 0
    if avg_price and avg_price > 0 and row['current_price'] > avg_price:
        penalty_raw = min((row['current_price'] - avg_price) / avg_price * 20, 20)
    else:
        penalty_raw = 0
    price_pts = penalty_raw * 0.2
    return round(sustainability_pts + local_pts - price_pts, 1)
 
# ─────────────────────────────────────────────
# PAGE CONFIG
# ─────────────────────────────────────────────
st.set_page_config(page_title="EthiTrack", layout="wide", page_icon="🌿")
 
# ─────────────────────────────────────────────
# SIDEBAR NAVIGATION
# ─────────────────────────────────────────────
with st.sidebar:
    st.image("https://img.icons8.com/color/96/leaf.png", width=60)
    st.title("EthiTrack")
    st.caption("Ethical Procurement Dashboard")
    st.divider()
 
    page = st.selectbox(
        "📂 Navigate to:",
        [
            "🏠 Overview & KPIs",
            "🔍 Product Intelligence",
            "📊 Vendor Comparison Matrix",
            "📈 Annual Impact Report",
            "🏢 Individual Vendor Details",
        ]
    )
 
    st.divider()
    st.caption("Built for Whole Foods & Trader Joe's analysts")
 
# ─────────────────────────────────────────────
# SHARED DATA (loaded once, used across pages)
# ─────────────────────────────────────────────
try:
    pref_df   = get_data("SELECT * FROM user_preference_summary LIMIT 1;")
    gap_df    = get_data("SELECT * FROM npo_impact_gap;")
    vendor_df = get_data("SELECT * FROM Vendor;")
 
    npo_row   = gap_df[gap_df['is_npo_partner'] == True]
    reg_row   = gap_df[gap_df['is_npo_partner'] == False]
    npo_price = float(npo_row['avg_price'].values[0]) if not npo_row.empty else 0
    reg_price = float(reg_row['avg_price'].values[0]) if not reg_row.empty else 0
    diff      = round(npo_price - reg_price, 2)
 
    certified_count = int(vendor_df['certification_status'].notna().sum()) if 'certification_status' in vendor_df.columns else 0
    npo_count       = int(vendor_df['is_npo_partner'].sum())
 
    # ── Product selector lives in sidebar so it persists across pages ──
    with st.sidebar:
        st.divider()
        products_df      = get_data("SELECT DISTINCT product_name FROM dashboard_main_metrics ORDER BY product_name;")
        selected_product = st.selectbox("🛒 Select Product:", products_df['product_name'])
        location_pref    = st.radio("📦 Supply Chain:", ["All Options", "Local (Nearby)", "Online/Global"])
 
    # Load results for selected product
    all_results = get_data(f"SELECT * FROM dashboard_main_metrics WHERE product_name = '{selected_product}'")
 
    if location_pref == "Local (Nearby)":
        results = all_results[all_results['location_type'] == 'Local'].copy()
    elif location_pref == "Online/Global":
        results = all_results[all_results['location_type'] == 'Online'].copy()
    else:
        results = all_results.copy()
 
    if not results.empty:
        avg_price = float(results['current_price'].mean())
        results['supplier_fit_score'] = results.apply(lambda r: compute_fit_score(r, avg_price), axis=1)
        results = results.sort_values('supplier_fit_score', ascending=False)
 
    # ════════════════════════════════════════
    # PAGE: Overview & KPIs
    # ════════════════════════════════════════
    if page == "🏠 Overview & KPIs":
        st.title("🌿 EthiTrack: Ethical Procurement Dashboard")
        st.caption("Supporting mission-driven purchasing decisions for procurement analysts")
        st.divider()
 
        col1, col2, col3, col4 = st.columns(4)
        with col1:
            st.metric("Top User Preference",
                      pref_df['impact_preference'].iloc[0],
                      delta=f"{pref_df['percentage'].iloc[0]}% of users")
        with col2:
            st.metric("NPO Avg Price", f"${npo_price}",
                      delta=f"${diff} vs commercial", delta_color="inverse")
        with col3:
            st.metric("Certified Vendors", certified_count, delta="Verified")
        with col4:
            st.metric("NPO Partners", npo_count, delta="Active")
 
        st.divider()
        st.info(f"💡 Choosing an NPO partner costs approximately **${diff} more per item** — but generates measurable community impact.")
 
        st.subheader("📊 User Preference Breakdown")
        pref_all = get_data("SELECT * FROM user_preference_summary;")
        st.bar_chart(pref_all.set_index('impact_preference')['total_users'])
 
        st.subheader("🌱 All Vendor Sustainability Scores")
        sus_chart = vendor_df.set_index('vendor_name')['sustainability_score'].sort_values(ascending=False)
        st.bar_chart(sus_chart)
 
    # ════════════════════════════════════════
    # PAGE: Product Intelligence
    # ════════════════════════════════════════
    elif page == "🔍 Product Intelligence":
        st.title(f"🔍 Product Intelligence — {selected_product}")
        st.caption("Vendor overview ranked by Supplier Fit Score")
        st.divider()
 
        if results.empty:
            st.warning("No vendors found for this filter. Try 'All Options' in the sidebar.")
        else:
            overview_cols = ['vendor_name', 'current_price', 'sustainability_score',
                             'supplier_fit_score', 'is_npo_partner', 'location_type']
            available = [c for c in overview_cols if c in results.columns]
            display_df = results[available].reset_index(drop=True)
            display_df.index += 1
            st.dataframe(display_df, use_container_width=True)
 
            st.divider()
            st.subheader("💰 Price vs Sustainability")
            chart_df = results.set_index('vendor_name')[['current_price', 'sustainability_score']]
            st.bar_chart(chart_df)
 
    # ════════════════════════════════════════
    # PAGE: Vendor Comparison Matrix
    # ════════════════════════════════════════
    elif page == "📊 Vendor Comparison Matrix":
        st.title("📊 Vendor Comparison Matrix")
        st.caption("Select vendors to compare side-by-side")
        st.divider()
 
        if results.empty:
            st.warning("No vendors found. Adjust the product or supply chain filter in the sidebar.")
        else:
            vendor_options   = results['vendor_name'].unique().tolist()
            selected_vendors = st.multiselect(
                "Choose vendors to compare:",
                options=vendor_options,
                default=vendor_options[:min(3, len(vendor_options))]
            )
 
            if selected_vendors:
                comparison_df = results[results['vendor_name'].isin(selected_vendors)].copy()
 
                compare_cols = ['vendor_name', 'current_price', 'sustainability_score',
                                'supplier_fit_score', 'is_npo_partner', 'location_type',
                                'certification_status', 'lead_time_days', 'social_impact_category']
                available_compare = [c for c in compare_cols if c in comparison_df.columns]
                st.table(comparison_df[available_compare].set_index('vendor_name'))
 
                st.divider()
                st.subheader("🌱 Score Comparison Chart")
                chart_cols = [c for c in ['sustainability_score', 'supplier_fit_score'] if c in comparison_df.columns]
                st.bar_chart(comparison_df.set_index('vendor_name')[chart_cols])
            else:
                st.info("Select at least one vendor above to see the comparison.")
 
    # ════════════════════════════════════════
    # PAGE: Annual Impact Report
    # ════════════════════════════════════════
    elif page == "📈 Annual Impact Report":
        st.title("📈 Projected Annual Impact Report")
        st.caption("Estimate the societal and environmental ROI of your procurement decision")
        st.divider()
 
        if results.empty:
            st.warning("No vendors found. Adjust filters in the sidebar.")
        else:
            vendor_options   = results['vendor_name'].unique().tolist()
            selected_vendors = st.multiselect(
                "Choose vendors to include in report:",
                options=vendor_options,
                default=vendor_options[:min(3, len(vendor_options))]
            )
 
            order_volume = st.slider("Annual order volume (units):",
                                     min_value=100, max_value=50000, value=1000, step=100)
 
            if selected_vendors:
                comparison_df = results[results['vendor_name'].isin(selected_vendors)].copy()
                impact_rows = []
                for _, row in comparison_df.iterrows():
                    annual_spend  = round(float(row['current_price']) * order_volume, 2)
                    co2_saved     = 120 * (order_volume / 1000) if row['location_type'] == 'Local' else 0
                    community_usd = 5000 * (order_volume / 1000) if row['is_npo_partner'] else 1000 * (order_volume / 1000)
                    impact_rows.append({
                        "Vendor"              : row['vendor_name'],
                        "Annual Spend ($)"    : f"${annual_spend:,.2f}",
                        "CO₂ Saved (kg)"      : f"{co2_saved:,.0f}" if co2_saved else "—",
                        "Community $ Impact"  : f"${community_usd:,.0f}",
                        "Local Jobs"          : "✅ Yes" if row['location_type'] == 'Local' else "—",
                        "NPO Benefit"         : "🤝 Yes" if row['is_npo_partner'] else "—",
                    })
 
                st.table(pd.DataFrame(impact_rows).set_index("Vendor"))
 
                best = comparison_df.sort_values('supplier_fit_score', ascending=False).iloc[0]
                st.success(
                    f"🏆 **Top Recommendation:** {best['vendor_name']} "
                    f"(Fit Score: {best['supplier_fit_score']}/100) — "
                    f"{'NPO partner · ' if best['is_npo_partner'] else ''}"
                    f"{'Local · ' if best['location_type'] == 'Local' else ''}"
                    f"Sustainability: {best['sustainability_score']}/100"
                )
            else:
                st.info("Select at least one vendor above.")
 
    # ════════════════════════════════════════
    # PAGE: Individual Vendor Details
    # ════════════════════════════════════════
    elif page == "🏢 Individual Vendor Details":
        st.title("🏢 Individual Vendor Details")
        st.caption("Expandable cards for each vendor — click to open")
        st.divider()
 
        if results.empty:
            st.warning("No vendors found. Adjust filters in the sidebar.")
        else:
            for _, row in results.iterrows():
                label = f"{'🤝' if row['is_npo_partner'] else '💼'}  {row['vendor_name']}  —  ${row['current_price']}  ·  Fit Score: {row['supplier_fit_score']}/100"
                with st.expander(label):
                    col_a, col_b, col_c = st.columns(3)
 
                    with col_a:
                        st.write(f"**Sustainability Score:** {row['sustainability_score']}/100")
                        st.write(f"**Supplier Fit Score:** {row['supplier_fit_score']}/100")
                        if row['is_npo_partner']:
                            st.success("🤝 NPO Partner")
                        else:
                            st.info("💼 Commercial Vendor")
 
                    with col_b:
                        if 'certification_status' in row and pd.notna(row['certification_status']):
                            st.write(f"**Certifications:** {row['certification_status']}")
                        if 'lead_time_days' in row and pd.notna(row['lead_time_days']):
                            st.write(f"**Lead Time:** {int(row['lead_time_days'])} days")
                        if 'social_impact_category' in row and pd.notna(row['social_impact_category']):
                            st.write(f"**Social Impact:** {row['social_impact_category']}")
 
                    with col_c:
                        price_diff = float(row['current_price']) - avg_price
                        if price_diff <= 0:
                            st.write(f"🌟 **${abs(round(price_diff, 2))} cheaper** than avg")
                        else:
                            st.write(f"💰 **${round(price_diff, 2)} more** than avg")
                        if row['location_type'] == 'Local':
                            st.write("📍 **Local** — zero shipping emissions")
                        else:
                            st.write("🚚 **Online** — competitive global pricing")
 
except Exception as e:
    st.error(f"Database Error: {e}")
    st.info("Make sure PostgreSQL is running and all SQL migrations have been applied in pgAdmin.")