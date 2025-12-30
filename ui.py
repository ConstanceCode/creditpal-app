import streamlit as st
import requests
import time

# PAGE CONFIG
st.set_page_config(
    page_title="📰 News Credibility Analyzer",
    layout="wide"
)

BASE_URL = "http://localhost:8000"
GET_ARTICLES_ENDPOINT = f"{BASE_URL}/walker/GetAllArticlesWalker"
ANALYZE_ENDPOINT = f"{BASE_URL}/walker/AnalyzeCredibilityWalker"

# SESSION STATE
if "articles" not in st.session_state:
    st.session_state.articles = []

# SIDEBAR
with st.sidebar:
    st.title("🧭 Preferences")
    st.subheader("📰 News Topics")
    
    available_topics = [
        # Tech (Neutral)
        "Technology", "AI", "Machine Learning", "Cybersecurity", "Blockchain",
        
        # Political (Left-leaning sources)
        "Trump indictment", "Biden accomplishments", "Climate action", 
        "Progressive policies", "Democratic party",
        
        # Political (Right-leaning sources)
        "Trump 2024 campaign", "Border security", "Republican agenda",
        "Conservative values", "Second amendment",
        
        # Political (Balanced)
        "US Election 2024", "Congress legislation", "Supreme Court",
        
        # International
        "Israel Gaza conflict", "Ukraine war", "China US relations",
        
        # Business/Finance
        "Stock market", "Federal Reserve", "Cryptocurrency", "Economy"
    ]
    
    selected_topics = st.multiselect(
        "Select topics to fetch (choose varied topics to test bias detection)",
        available_topics,
        default=["AI", "Trump 2024 campaign", "Biden accomplishments"]
    )
    
    max_articles_per_topic = st.slider(
        "Articles per topic",
        min_value=3,
        max_value=15,
        value=8
    )
    
    st.markdown("---")
    
    # Credibility Filter
    min_credibility = st.slider(
        "Minimum Credibility Score",
        min_value=0,
        max_value=100,
        value=0
    )
    
    st.markdown("---")
    st.subheader("⚙️ Actions")
    
    # CLEAR DATABASE (with confirmation)
    with st.expander("🗑️ Clear Database", expanded=False):
        st.warning("⚠️ This will delete ALL articles, topics, and sources!")
        
        if st.checkbox("I understand this will delete everything"):
            if st.button("🗑️ Clear Database", use_container_width=True, type="primary"):
                with st.spinner("Clearing database..."):
                    try:
                        res = requests.post(f"{BASE_URL}/walker/ClearAllArticlesWalker", json={})
                        
                        if res.status_code == 200:
                            data = res.json()
                            reports = data.get("reports", [])
                            if reports:
                                result = reports[0]
                                st.success(f"✅ Deleted: {result.get('deleted_articles', 0)} articles, "
                                         f"{result.get('deleted_topics', 0)} topics, "
                                         f"{result.get('deleted_sources', 0)} sources")
                                st.session_state.articles = []
                                st.rerun()
                        else:
                            st.error(f"Failed: {res.status_code}")
                    except Exception as e:
                        st.error(f"Error: {str(e)}")
    
    st.markdown("---")
    
    # FETCH NEWS
    if st.button("📥 Fetch News", use_container_width=True):
        if not selected_topics:
            st.warning("Please select at least one topic!")
        else:
            with st.spinner(f"Fetching news for {len(selected_topics)} topics..."):
                try:
                    total_fetched = 0
                    progress = st.progress(0)
                    
                    for idx, topic in enumerate(selected_topics):
                        st.write(f"Fetching: {topic}...")
                        res = requests.post(
                            f"{BASE_URL}/walker/FetchNewsWalker",
                            json={"topic": topic, "max_articles": max_articles_per_topic}
                        )
                        
                        if res.status_code == 200:
                            data = res.json()
                            reports = data.get("reports", [])
                            if reports:
                                fetched = reports[0].get("articles_fetched", 0)
                                total_fetched += fetched
                                if fetched > 0:
                                    st.success(f"✅ {topic}: {fetched} articles")
                                else:
                                    st.info(f"ℹ️ {topic}: 0 new (already in database)")
                        
                        progress.progress((idx + 1) / len(selected_topics))
                    
                    if total_fetched > 0:
                        st.success(f" Total: {total_fetched} new articles!")
                        st.info("👉 Click 'Refresh Articles' to load them")
                    else:
                        st.warning("⚠️ No new articles (all already exist). Try clearing database first.")
                        
                except Exception as e:
                    st.error(f"Error: {str(e)}")
    
    # REFRESH ARTICLES
    if st.button("🔄 Refresh Articles", use_container_width=True):
        with st.spinner("Loading articles..."):
            try:
                res = requests.post(GET_ARTICLES_ENDPOINT, json={})
                
                if res.status_code == 200:
                    data = res.json()
                    reports = data.get("reports", [])
                    
                    if reports and len(reports) > 0:
                        result = reports[0]
                        raw_articles = result.get("articles", [])
                        
                        st.session_state.articles = raw_articles
                        st.success(f"✅ Loaded {len(raw_articles)} articles!")
                    else:
                        st.warning("No articles in database")
                else:
                    st.error(f"Failed: {res.status_code}")
            except Exception as e:
                st.error(f"Error: {str(e)}")
    
    # ANALYZE CREDIBILITY
    if st.button("🔍 Analyze Credibility", use_container_width=True):
        if not st.session_state.articles:
            st.warning("Load articles first!")
        else:
            num_articles = len(st.session_state.articles)
            estimated_time = (num_articles * 2) // 60  # 2 seconds per article
            
            with st.spinner(f"🤖 Analyzing {num_articles} articles... (~{estimated_time} minutes)"):
                try:
                    progress_bar = st.progress(0)
                    status_text = st.empty()
                    
                    res = requests.post(
                        f"{BASE_URL}/walker/AnalyzeCredibilityWalker",
                        json={"max_retries": 2}
                    )
                    
                    for i in range(100):
                        time.sleep(0.1)
                        progress_bar.progress(i + 1)
                        if i % 10 == 0:
                            status_text.text(f"Analyzing... {i}%")
                    
                    if res.status_code == 200:
                        st.success("✅ Analysis complete! Click 'Refresh Articles' to see scores")
                    else:
                        st.error(f"Failed: {res.status_code}")
                except Exception as e:
                    st.error(f"Error: {str(e)}")
    
    st.markdown("---")
    st.info("💡 **Recommended Workflow:**\n"
            "1. **Clear Database** (if you want fresh articles)\n"
            "2. **Select Topics** (mix political & neutral)\n"
            "3. **Fetch News**\n"
            "4. **Refresh Articles**\n"
            "5. **Analyze Credibility**\n"
            "6. **Refresh** to see scores")
    
# MAIN PAGE
st.title("📰 News Credibility & Bias Dashboard")

if not st.session_state.articles:
    st.info("👆 Click 'Refresh Articles' in the sidebar to load news")
    st.stop()

# Show stats
total_analyzed = sum(1 for art in st.session_state.articles if art.get("credibility_score", 0) > 0)
st.write(f"**Total Articles:** {len(st.session_state.articles)} | **Analyzed:** {total_analyzed} | **Showing:** (credibility ≥ {min_credibility})")

if total_analyzed == 0:
    st.warning("⚠️ Articles haven't been analyzed yet. Click 'Analyze Credibility' in the sidebar!")

# Filter articles by credibility
filtered_articles = [
    art for art in st.session_state.articles 
    if art.get("credibility_score", 0) >= min_credibility
]

st.write(f"**{len(filtered_articles)} articles match your filter**")

# ARTICLE DISPLAY
for idx, article in enumerate(filtered_articles):
    st.markdown("---")
    
    col1, col2 = st.columns([3, 1])
    
    with col1:
        # Title
        title = article.get("title", "Untitled Article")
        st.subheader(f"{idx + 1}. {title}")
        
        # Source and author
        author = article.get("author", "Unknown")
        st.caption(f"By {author}")
        
        # Content preview
        content = article.get("content", "")
        if content:
            preview = content[:300] + "..." if len(content) > 300 else content
            st.write(preview)
        
        # URL
        url = article.get("url", "")
        if url:
            st.markdown(f"[🔗 Read full article]({url})")
    
    with col2:
        # Credibility Score
        cred_score = article.get("credibility_score", 0)
        
        if cred_score >= 70:
            cred_color = "🟢"
        elif cred_score >= 40:
            cred_color = "🟡"
        elif cred_score > 0:
            cred_color = "🔴"
        else:
            cred_color = "⚪"  # Not analyzed
        
        st.metric("Credibility", f"{cred_color} {int(cred_score)}/100")
        
        # Bias Score
        bias_score = article.get("bias_score", 0)
        if bias_score < -30:
            bias_label = "⬅️ Left"
        elif bias_score > 30:
            bias_label = "➡️ Right"
        else:
            bias_label = "⚖️ Neutral"
        st.metric("Bias", bias_label)
        
        # Polarization
        polar_score = article.get("polarization_score", 0)
        st.metric("Polarization", f"{int(polar_score)}/100")
    
    # Expandable details
    with st.expander("📊 Article Details"):
        st.write("**Published:**", article.get("published_at", "N/A"))
        st.write("**Article ID:**", str(article.get("article_id", "N/A"))[:80] + "...")
        st.write("**Read Count:**", article.get("read_count", 0))
        
        # Raw scores for debugging
        st.write("**Raw Scores:**")
        st.json({
            "credibility_score": article.get("credibility_score", 0),
            "bias_score": article.get("bias_score", 0),
            "polarization_score": article.get("polarization_score", 0)
        })
        
        # Claims
        claims = article.get("claims", [])
        if claims:
            st.write("**Claims Extracted:**")
            for i, claim in enumerate(claims[:5], 1):
                st.write(f"{i}. {claim}")


# FOOTER

st.markdown("---")
st.caption(f"📊 Database: {len(st.session_state.articles)} articles | {total_analyzed} analyzed")