import streamlit as st
import psycopg2
import pandas as pd

# 1. Database Connection Logic (The "Engine")
def get_data(query):
    # Using 'with' statements ensures the connection closes automatically
    conn = psycopg2.connect(
        dbname="project_610_npo_sales", 
        user="abiramikasiviswanathan", 
        password="", 
        host="localhost"
    )
    df = pd.read_sql(query, conn)
    conn.close()
    return df

# Main App UI
st.set_page_config(page_title="EthiTrack", layout="wide")
st.title("EthiTrack: Price of Principles")

try:
    # --- SECTION A: METRIC CARDS ---
    pref_df = get_data("SELECT * FROM user_preference_summary LIMIT 1;")
    gap_df = get_data("SELECT * FROM npo_impact_gap;")

    npo_price = gap_df[gap_df['is_npo_partner'] == True]['avg_price'].values[0]
    reg_price = gap_df[gap_df['is_npo_partner'] == False]['avg_price'].values[0]
    diff = round(npo_price - reg_price, 2)

    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric(label="Top User Preference", value=pref_df['impact_preference'].iloc[0], delta=f"{pref_df['percentage'].iloc[0]}% of users")
    with col2:
        st.metric(label="NPO Avg Price", value=f"${npo_price}", delta=f"${diff} vs Reg", delta_color="inverse")
    with col3:
        # Note: You can also query this count from your Vendor table if you prefer
        st.metric(label="Partner Vendors", value="10", delta="Live")

    st.info(f"💡 Analysis: Supporting an NPO partner costs about **${diff}** more per item on average.")

    # --- SECTION B: SEARCH & ADVANTAGES (The Interaction) ---
    st.divider()
    st.header("🔍 Find Your Impact")

    products_df = get_data("SELECT DISTINCT product_name FROM dashboard_main_metrics")
    selected_product = st.selectbox("What are you looking to buy?", products_df['product_name'])

    location_pref = st.radio("Preferred Shopping Method:", ["Local (Nearby)", "Online/Global"])

    # Fetch results for the selected product
    search_results = get_data(f"SELECT * FROM dashboard_main_metrics WHERE product_name = '{selected_product}'")

    # FIX: This block is now correctly indented within the 'try' block
    if not search_results.empty:
        # 1. Filter results based on user choice
        if location_pref == "Local (Nearby)":
            filtered_data = search_results[search_results['location_type'] == 'Local'].sort_values('sustainability_score', ascending=False)
            st.subheader(f"📍 Local Vendors near San Jose & East Bay")
        else:
            filtered_data = search_results.sort_values('current_price', ascending=True)
            st.subheader(f"🌍 All Global & Local Options")

        if not filtered_data.empty:
            # 2. Display an overview table
            display_df = filtered_data[['vendor_name', 'current_price', 'sustainability_score', 'is_npo_partner']].copy()
            st.dataframe(display_df, use_container_width=True)

            # 3. Detailed breakdown
            st.write("---")
            st.write("### Detailed Seller Advantages")
            
            for index, row in filtered_data.iterrows():
                with st.expander(f"🏢 {row['vendor_name']} — ${row['current_price']}"):
                    col_a, col_b = st.columns(2)
                    
                    with col_a:
                        st.write(f"**Sustainability:** {row['sustainability_score']}/100")
                        if row['is_npo_partner']:
                            st.success("🤝 NPO Partner: Direct community impact.")
                        else:
                            st.info("💼 Commercial Vendor")

                    with col_b:
                        if row['location_type'] == 'Local':
                            st.write("**Proximity:** 📍 Nearby (East Bay/San Jose)")
                            st.write("**Advantage:** Zero shipping emissions + Supporting local jobs.")
                        else:
                            st.write("**Proximity:** 🚚 Online/Global Shipping")
                            st.write("**Advantage:** Competitive pricing from global markets.")

                    avg_market = search_results['current_price'].mean()
                    price_diff = row['current_price'] - avg_market
                    if price_diff <= 0:
                        st.write(f"🌟 **Savings:** This option is **${abs(round(price_diff, 2))} cheaper** than the average!")
                    else:
                        st.write(f"💰 **Investment:** This option costs **${round(price_diff, 2)} more** than the average.")
        else:
            st.warning("No vendors found for this selection. Try switching between Local/Global.")

except Exception as e:
    st.error(f"Error: {e}")