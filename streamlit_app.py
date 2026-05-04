import getpass
import os

import pandas as pd
import psycopg2
import streamlit as st


st.set_page_config(
    page_title="EthiTrack Procurement Dashboard",
    layout="wide",
    page_icon="🌿",
)


def get_db_config():
    try:
        secret_db = st.secrets.get("database", {})
    except Exception:
        secret_db = {}

    return {
        "dbname": secret_db.get(
            "dbname",
            os.getenv("DB_NAME") or os.getenv("PGDATABASE") or "project_610_npo_sales",
        ),
        "user": secret_db.get(
            "user",
            os.getenv("DB_USER") or os.getenv("PGUSER") or getpass.getuser(),
        ),
        "password": secret_db.get(
            "password",
            os.getenv("DB_PASSWORD") or os.getenv("PGPASSWORD") or "",
        ),
        "host": secret_db.get(
            "host",
            os.getenv("DB_HOST") or os.getenv("PGHOST") or "localhost",
        ),
        "port": secret_db.get(
            "port",
            os.getenv("DB_PORT") or os.getenv("PGPORT") or "5432",
        ),
    }


@st.cache_data(ttl=60)
def get_data(query, params=None):
    conn = psycopg2.connect(**get_db_config())
    try:
        return pd.read_sql_query(query, conn, params=params)
    finally:
        conn.close()


def format_supplier_type(value):
    return "NPO Partner" if value else "Commercial"


def high_value_score(series):
    series = pd.to_numeric(series, errors="coerce").fillna(0)
    spread = series.max() - series.min()
    if spread == 0:
        return pd.Series(100, index=series.index)
    return ((series - series.min()) / spread) * 100


def low_value_score(series):
    series = pd.to_numeric(series, errors="coerce").fillna(0)
    spread = series.max() - series.min()
    if spread == 0:
        return pd.Series(100, index=series.index)
    return ((series.max() - series) / spread) * 100


def infer_decision_goal(question, selected_goal):
    text = question.lower()
    if any(word in text for word in ["cheap", "cost", "price", "budget", "affordable"]):
        return "Lowest Cost"
    if any(word in text for word in ["fast", "lead", "delivery", "reliable", "risk"]):
        return "Reliability"
    if any(word in text for word in ["npo", "community", "impact", "local", "co2", "emission"]):
        return "Social Impact"
    if any(word in text for word in ["sustain", "certification", "certified", "green"]):
        return "Sustainability"
    return selected_goal


def assistant_rankings(supplier_df, decision_goal):
    ranked = supplier_df.copy()
    ranked["price_score"] = low_value_score(ranked["current_price"])
    ranked["speed_score"] = low_value_score(ranked["lead_time_days"])
    ranked["certification_score"] = ranked["certification_status"].notna().astype(int) * 100
    ranked["impact_score"] = (
        ranked["is_npo_partner"].astype(int) * 55
        + (ranked["location_type"] == "Local").astype(int) * 30
        + ranked["certification_status"].notna().astype(int) * 15
    )
    ranked["volatility_score"] = low_value_score(
        ranked.get("price_volatility_index", pd.Series(0, index=ranked.index))
    )

    weights = {
        "Balanced": {
            "supplier_fit_score": 0.45,
            "price_score": 0.20,
            "impact_score": 0.15,
            "speed_score": 0.10,
            "sustainability_score": 0.10,
        },
        "Lowest Cost": {
            "price_score": 0.55,
            "supplier_fit_score": 0.20,
            "speed_score": 0.15,
            "sustainability_score": 0.10,
        },
        "Social Impact": {
            "impact_score": 0.40,
            "sustainability_score": 0.25,
            "supplier_fit_score": 0.20,
            "price_score": 0.15,
        },
        "Sustainability": {
            "sustainability_score": 0.45,
            "certification_score": 0.20,
            "supplier_fit_score": 0.20,
            "impact_score": 0.15,
        },
        "Reliability": {
            "speed_score": 0.35,
            "volatility_score": 0.25,
            "supplier_fit_score": 0.25,
            "price_score": 0.15,
        },
    }

    ranked["assistant_score"] = 0.0
    for column, weight in weights[decision_goal].items():
        ranked["assistant_score"] += pd.to_numeric(ranked[column], errors="coerce").fillna(0) * weight

    return ranked.sort_values("assistant_score", ascending=False)


def build_assistant_explanation(best, selected_product, decision_goal, order_volume=None):
    supplier_type = "an NPO partner" if best["is_npo_partner"] else "a commercial supplier"
    location_note = "local" if best["location_type"] == "Local" else "online/global"
    cert_note = (
        f" It has {best['certification_status']} certification."
        if pd.notna(best["certification_status"])
        else " It does not list a formal certification."
    )
    price_gap = float(best["current_price"]) - float(best["avg_market_price"])
    if price_gap <= 0:
        price_note = f"${abs(price_gap):.2f} below the product market average"
    else:
        price_note = f"${price_gap:.2f} above the product market average"

    explanation = (
        f"For {selected_product}, I recommend {best['vendor_name']} for a {decision_goal.lower()} decision. "
        f"It is {supplier_type}, uses a {location_note} supply chain, has a sustainability score of "
        f"{best['sustainability_score']}/100, and has a {best['lead_time_days']}-day lead time. "
        f"Its current price is ${best['current_price']:.2f}, which is {price_note}. "
        f"The SQL supplier fit score is {best['supplier_fit_score']}/100, and the AI assistance score is "
        f"{best['assistant_score']:.1f}/100.{cert_note}"
    )

    if order_volume:
        annual_spend = float(best["current_price"]) * order_volume
        community_impact = float(best["community_impact_per_1000_units"]) * order_volume / 1000
        co2_saved = float(best["annual_co2_saved_kg_per_1000_units"]) * order_volume / 1000
        explanation += (
            f" At {order_volume:,} units per year, projected spend is ${annual_spend:,.2f}, "
            f"estimated community impact is ${community_impact:,.0f}, and estimated CO2 savings are "
            f"{co2_saved:,.0f} kg."
        )

    return explanation


def build_watchout(best):
    watchouts = []
    if float(best["current_price"]) > float(best["avg_market_price"]):
        watchouts.append("price is above the product average")
    if int(best["lead_time_days"]) > 5:
        watchouts.append("lead time is longer than five days")
    if not bool(best["is_npo_partner"]):
        watchouts.append("supplier is not an NPO partner")
    if pd.isna(best["certification_status"]):
        watchouts.append("certification is missing")
    if "price_volatility_index" in best and pd.notna(best["price_volatility_index"]):
        if float(best["price_volatility_index"]) > 1:
            watchouts.append("historical price volatility is higher than other suppliers")

    if not watchouts:
        return "No major concern stands out for this selection."
    return "Watch-out: " + "; ".join(watchouts) + "."


def find_named_match(question, values):
    lowered = question.lower()
    clean_values = [str(value) for value in values if pd.notna(value)]
    for value in sorted(clean_values, key=len, reverse=True):
        if value.lower() in lowered:
            return value
    return None


def format_vendor_products(vendor_rows):
    pieces = []
    for _, row in vendor_rows.sort_values(["product_name", "current_price"]).iterrows():
        pieces.append(
            f"{row['product_name']} (${row['current_price']:.2f}, fit score {row['supplier_fit_score']}/100)"
        )
    return "; ".join(pieces)


def answer_chatbot_question(
    question,
    page_context,
    selected_product,
    scoped_df,
    analytics_df,
    gap_df,
    order_volume=None,
):
    text = question.lower().strip()
    if not text:
        return "Ask me about suppliers, products, prices, sustainability, lead time, NPO partners, or recommendations."

    vendor_match = find_named_match(question, analytics_df["vendor_name"].unique())
    product_match = find_named_match(question, analytics_df["product_name"].unique())

    if vendor_match and any(word in text for word in ["product", "sell", "sells", "offer", "offers", "carry", "carries"]):
        vendor_rows = analytics_df[analytics_df["vendor_name"] == vendor_match]
        if vendor_rows.empty:
            return f"I could not find products for {vendor_match}."
        return f"{vendor_match} supplies: {format_vendor_products(vendor_rows)}."

    if product_match and any(word in text for word in ["vendor", "supplier", "sell", "sells", "who", "source"]):
        product_rows = analytics_df[analytics_df["product_name"] == product_match].sort_values(
            "supplier_fit_score",
            ascending=False,
        )
        vendors = [
            f"{row['vendor_name']} (${row['current_price']:.2f}, score {row['supplier_fit_score']}/100)"
            for _, row in product_rows.iterrows()
        ]
        return f"Vendors that supply {product_match}: " + "; ".join(vendors) + "."

    if (
        "what products" in text
        or "which products" in text
        or ("vendor" in text and "products" in text)
        or ("supplier" in text and "products" in text)
    ):
        grouped = (
            analytics_df.groupby("vendor_name")["product_name"]
            .apply(lambda values: ", ".join(sorted(values.unique())))
            .sort_index()
        )
        lines = [f"{vendor}: {products}" for vendor, products in grouped.items()]
        return "Here is the vendor-product map: " + " | ".join(lines)

    if any(word in text for word in ["best", "recommend", "choose", "top", "which supplier", "which vendor"]):
        decision_goal = infer_decision_goal(question, "Balanced")
        candidate_df = scoped_df.copy()
        if product_match:
            candidate_df = analytics_df[analytics_df["product_name"] == product_match].copy()
        if candidate_df.empty:
            candidate_df = analytics_df[analytics_df["product_name"] == selected_product].copy()

        ranked = assistant_rankings(candidate_df, decision_goal)
        best = ranked.iloc[0]
        response = build_assistant_explanation(
            best,
            best["product_name"],
            decision_goal,
            order_volume=order_volume,
        )
        return response + " " + build_watchout(best)

    if any(word in text for word in ["cheapest", "lowest", "least expensive", "lowest cost"]):
        candidate_df = scoped_df.copy()
        if product_match:
            candidate_df = analytics_df[analytics_df["product_name"] == product_match].copy()
        if candidate_df.empty:
            candidate_df = analytics_df[analytics_df["product_name"] == selected_product].copy()

        cheapest = candidate_df.sort_values("current_price").iloc[0]
        return (
            f"The lowest-price option for {cheapest['product_name']} is {cheapest['vendor_name']} "
            f"at ${cheapest['current_price']:.2f}. Its sustainability score is "
            f"{cheapest['sustainability_score']}/100 and supplier fit score is "
            f"{cheapest['supplier_fit_score']}/100."
        )

    if any(word in text for word in ["fastest", "lead time", "delivery", "quickest"]):
        candidate_df = scoped_df.copy()
        if product_match:
            candidate_df = analytics_df[analytics_df["product_name"] == product_match].copy()
        if candidate_df.empty:
            candidate_df = analytics_df[analytics_df["product_name"] == selected_product].copy()

        fastest = candidate_df.sort_values(["lead_time_days", "supplier_fit_score"], ascending=[True, False]).iloc[0]
        return (
            f"The fastest supplier in this context is {fastest['vendor_name']} for "
            f"{fastest['product_name']} with a {fastest['lead_time_days']}-day lead time."
        )

    if any(word in text for word in ["npo", "nonprofit", "commercial"]):
        npo_rows = gap_df.copy()
        npo_rows["supplier_type"] = npo_rows["is_npo_partner"].apply(format_supplier_type)
        parts = []
        for _, row in npo_rows.iterrows():
            parts.append(
                f"{row['supplier_type']}: {row['supplier_options']} listings, "
                f"avg price ${row['avg_current_price']:.2f}, avg sustainability "
                f"{row['avg_sustainability_score']}/100, avg lead time {row['avg_lead_time_days']} days"
            )
        return "NPO vs commercial summary: " + " | ".join(parts)

    if any(word in text for word in ["sustainable", "sustainability", "green"]):
        candidate_df = scoped_df.copy()
        if candidate_df.empty:
            candidate_df = analytics_df[analytics_df["product_name"] == selected_product].copy()
        best = candidate_df.sort_values("sustainability_score", ascending=False).iloc[0]
        return (
            f"The strongest sustainability option here is {best['vendor_name']} for "
            f"{best['product_name']} with a sustainability score of {best['sustainability_score']}/100."
        )

    if any(word in text for word in ["certified", "certification", "certifications"]):
        candidate_df = scoped_df[scoped_df["certification_status"].notna()].copy()
        if candidate_df.empty:
            return "No certified suppliers match the current page filters."
        vendors = [
            f"{row['vendor_name']} ({row['certification_status']})"
            for _, row in candidate_df.sort_values("supplier_fit_score", ascending=False).iterrows()
        ]
        return "Certified suppliers in this context: " + "; ".join(vendors) + "."

    return (
        f"I can answer procurement questions for the {page_context} page. Try asking: "
        f"'Which vendor sells {selected_product}?', 'What products does Thrift & Thrive NPO sell?', "
        "'Which supplier is cheapest?', or 'Which supplier is best for social impact?'"
    )


def page_examples(page_context, selected_product):
    examples = {
        "Executive Overview": [
            "Which vendor has what products?",
            "Compare NPO and commercial suppliers.",
            "Which supplier is best overall?",
        ],
        "Supplier Ranking": [
            f"Which vendor sells {selected_product}?",
            "Which supplier is cheapest?",
            "Which supplier is best for sustainability?",
        ],
        "Vendor Comparison": [
            "Which selected vendor should I choose?",
            "Which vendor has the fastest delivery?",
            "Which selected vendor has certification?",
        ],
        "Annual Impact Report": [
            "Which supplier gives the best annual impact?",
            "Which supplier is best for local community impact?",
            "Which option is most budget friendly?",
        ],
    }
    return examples.get(page_context, [])


def render_chatbot(page_context, selected_product, scoped_df, analytics_df, gap_df, order_volume=None):
    st.subheader("AI Procurement Chatbot")
    st.caption("Ask topic-related questions about products, suppliers, recommendations, price, lead time, sustainability, or NPO impact.")

    examples = page_examples(page_context, selected_product)
    if examples:
        st.write("Examples: " + " | ".join(examples))

    chat_key = f"chat_{page_context}_{selected_product}".replace(" ", "_").lower()
    messages_key = f"{chat_key}_messages"

    if messages_key not in st.session_state:
        st.session_state[messages_key] = [
            {
                "role": "assistant",
                "content": (
                    f"Hi, I am the EthiTrack procurement chatbot for {page_context}. "
                    "Ask me about suppliers, products, recommendations, prices, lead time, or impact."
                ),
            }
        ]

    for message in st.session_state[messages_key]:
        with st.chat_message(message["role"]):
            st.markdown(message["content"])

    prompt = st.chat_input("Ask a procurement question", key=f"{chat_key}_input")

    if prompt:
        st.session_state[messages_key].append({"role": "user", "content": prompt})
        answer = answer_chatbot_question(
            prompt,
            page_context,
            selected_product,
            scoped_df,
            analytics_df,
            gap_df,
            order_volume=order_volume,
        )
        st.session_state[messages_key].append({"role": "assistant", "content": answer})
        st.rerun()


try:
    analytics_df = get_data(
        """
        SELECT *
        FROM view_procurement_analytics
        ORDER BY product_name, supplier_fit_score DESC;
        """
    )

    dashboard_df = get_data(
        """
        SELECT *
        FROM dashboard_main_metrics
        ORDER BY product_name, vendor_name;
        """
    )

    gap_df = get_data(
        """
        SELECT *
        FROM npo_impact_gap
        ORDER BY is_npo_partner DESC;
        """
    )

    volatility_df = get_data(
        """
        SELECT *
        FROM view_price_volatility;
        """
    )
except Exception as e:
    st.error(f"Database connection error: {e}")
    st.info("Start PostgreSQL, create the database, and run project_btob_610.sql before opening the app.")
    st.stop()


if not volatility_df.empty:
    analytics_df = analytics_df.merge(
        volatility_df[["product_name", "vendor_name", "price_volatility_index"]],
        on=["product_name", "vendor_name"],
        how="left",
    )


required_columns = {
    "product_name",
    "vendor_name",
    "current_price",
    "avg_market_price",
    "sustainability_score",
    "supplier_fit_score",
    "location_type",
    "is_npo_partner",
    "lead_time_days",
    "certification_status",
    "social_impact_category",
    "annual_co2_saved_kg_per_1000_units",
    "community_impact_per_1000_units",
}

missing_columns = sorted(required_columns - set(analytics_df.columns))
if missing_columns:
    st.error("The database views do not match the app.")
    st.write("Missing columns:", ", ".join(missing_columns))
    st.info("Run the latest project_btob_610.sql file again.")
    st.stop()


with st.sidebar:
    st.title("EthiTrack")
    st.caption("Procurement Analyst Dashboard")

    page = st.selectbox(
        "Dashboard Page",
        [
            "Executive Overview",
            "Supplier Ranking",
            "Vendor Comparison",
            "Annual Impact Report",
        ],
    )

    st.divider()

    selected_product = st.selectbox(
        "Select Product",
        sorted(analytics_df["product_name"].unique()),
    )

    location_filter = st.selectbox(
        "Supply Chain Type",
        ["All", "Local", "Online"],
    )

    supplier_filter = st.selectbox(
        "Supplier Type",
        ["All", "NPO Partner", "Commercial"],
    )


filtered_df = analytics_df[analytics_df["product_name"] == selected_product].copy()

if location_filter != "All":
    filtered_df = filtered_df[filtered_df["location_type"] == location_filter]

if supplier_filter == "NPO Partner":
    filtered_df = filtered_df[filtered_df["is_npo_partner"] == True]
elif supplier_filter == "Commercial":
    filtered_df = filtered_df[filtered_df["is_npo_partner"] == False]


if page == "Executive Overview":
    st.title("EthiTrack Procurement Dashboard")
    st.caption("Supplier intelligence for ethical, cost-aware organizational purchasing.")

    col1, col2, col3, col4 = st.columns(4)

    col1.metric("Avg Supplier Fit Score", round(float(analytics_df["supplier_fit_score"].mean()), 1))
    col2.metric("Certified Listings", int(analytics_df["certification_status"].notna().sum()))
    col3.metric(
        "NPO Partner Vendors",
        int(analytics_df[analytics_df["is_npo_partner"] == True]["vendor_name"].nunique()),
    )
    col4.metric("Avg Lead Time", f"{round(float(analytics_df['lead_time_days'].mean()), 1)} days")

    st.divider()

    best_overall = assistant_rankings(analytics_df, "Balanced").iloc[0]
    st.subheader("AI Insight Summary")
    st.info(build_assistant_explanation(best_overall, best_overall["product_name"], "Balanced"))

    st.subheader("NPO vs Commercial Supplier Summary")
    gap_display = gap_df.copy()
    gap_display["supplier_type"] = gap_display["is_npo_partner"].apply(format_supplier_type)
    st.dataframe(
        gap_display[
            [
                "supplier_type",
                "supplier_options",
                "avg_current_price",
                "avg_sustainability_score",
                "avg_lead_time_days",
            ]
        ],
        use_container_width=True,
        hide_index=True,
    )

    st.subheader("Supplier Fit Score by Vendor")
    score_chart = analytics_df.sort_values("supplier_fit_score", ascending=False)
    st.bar_chart(score_chart, x="vendor_name", y="supplier_fit_score")

    st.subheader("All Current Supplier Listings")
    st.dataframe(dashboard_df, use_container_width=True, hide_index=True)

    st.divider()
    render_chatbot("Executive Overview", selected_product, analytics_df, analytics_df, gap_df)


elif page == "Supplier Ranking":
    st.title(f"Supplier Ranking: {selected_product}")
    st.caption("Ranked by supplier fit score from the SQL analytics view.")

    if filtered_df.empty:
        st.warning("No suppliers match the selected filters.")
    else:
        display_df = filtered_df[
            [
                "vendor_name",
                "current_price",
                "avg_market_price",
                "sustainability_score",
                "supplier_fit_score",
                "location_type",
                "is_npo_partner",
                "lead_time_days",
                "certification_status",
                "social_impact_category",
            ]
        ].sort_values("supplier_fit_score", ascending=False)
        display_df = display_df.rename(columns={"is_npo_partner": "npo_partner"})

        st.dataframe(display_df, use_container_width=True, hide_index=True)

        st.subheader("Price vs Sustainability")
        st.scatter_chart(
            filtered_df,
            x="current_price",
            y="sustainability_score",
            size="supplier_fit_score",
        )

        best_supplier = filtered_df.sort_values("supplier_fit_score", ascending=False).iloc[0]
        st.success(
            f"Best SQL-ranked supplier for {selected_product}: {best_supplier['vendor_name']} "
            f"with a fit score of {best_supplier['supplier_fit_score']}."
        )

        st.divider()
        render_chatbot("Supplier Ranking", selected_product, filtered_df, analytics_df, gap_df)


elif page == "Vendor Comparison":
    st.title("Vendor Comparison Matrix")
    st.caption("Compare shortlisted vendors side by side.")

    if filtered_df.empty:
        st.warning("No vendors are available for this product and filter combination.")
    else:
        vendor_options = filtered_df["vendor_name"].unique().tolist()
        selected_vendors = st.multiselect(
            "Choose vendors to compare",
            vendor_options,
            default=vendor_options[: min(3, len(vendor_options))],
        )

        if selected_vendors:
            comparison_df = filtered_df[filtered_df["vendor_name"].isin(selected_vendors)].copy()

            st.dataframe(
                comparison_df[
                    [
                        "vendor_name",
                        "current_price",
                        "avg_market_price",
                        "supplier_fit_score",
                        "sustainability_score",
                        "lead_time_days",
                        "location_type",
                        "is_npo_partner",
                        "certification_status",
                        "social_impact_category",
                    ]
                ].set_index("vendor_name"),
                use_container_width=True,
            )

            st.subheader("Score Comparison")
            st.bar_chart(
                comparison_df.set_index("vendor_name")[
                    ["supplier_fit_score", "sustainability_score"]
                ]
            )

            st.divider()
            render_chatbot("Vendor Comparison", selected_product, comparison_df, analytics_df, gap_df)
        else:
            st.info("Select at least one vendor to compare.")


elif page == "Annual Impact Report":
    st.title("Annual Procurement Impact Report")
    st.caption("Estimate yearly cost, CO2 savings, and community impact.")

    if filtered_df.empty:
        st.warning("No suppliers match the selected filters.")
    else:
        order_volume = st.slider(
            "Annual order volume",
            min_value=100,
            max_value=50000,
            value=1000,
            step=100,
        )

        report_df = filtered_df.copy()
        report_df["projected_annual_spend"] = report_df["current_price"] * order_volume
        report_df["estimated_co2_saved_kg"] = (
            report_df["annual_co2_saved_kg_per_1000_units"] * order_volume / 1000
        )
        report_df["estimated_community_impact"] = (
            report_df["community_impact_per_1000_units"] * order_volume / 1000
        )

        st.dataframe(
            report_df[
                [
                    "vendor_name",
                    "current_price",
                    "projected_annual_spend",
                    "estimated_co2_saved_kg",
                    "estimated_community_impact",
                    "supplier_fit_score",
                    "social_impact_category",
                ]
            ].sort_values("supplier_fit_score", ascending=False),
            use_container_width=True,
            hide_index=True,
        )

        best_supplier = report_df.sort_values("supplier_fit_score", ascending=False).iloc[0]
        st.success(
            f"Recommended supplier by SQL fit score: {best_supplier['vendor_name']} "
            f"with projected annual spend of ${best_supplier['projected_annual_spend']:,.2f}."
        )

        st.divider()
        render_chatbot(
            "Annual Impact Report",
            selected_product,
            report_df,
            analytics_df,
            gap_df,
            order_volume=order_volume,
        )
