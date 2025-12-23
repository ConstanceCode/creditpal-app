cl import from react {useState, useEffect}

cl {
    def app() -> any {
        # State
        let [articles, setArticles] = useState([]);
        let [loading, setLoading] = useState(True);
        let [showPrefs, setShowPrefs] = useState(False);
        let [minCredibility, setMinCredibility] = useState(0);
        
        availableTopics = [
            "Technology", "Politics", "Health", 
            "Business", "Science", "Sports"
        ];
        
        # Fetch articles from backend
        async def fetchArticles() -> None {
            setLoading(True);
            console.log("Fetching articles from backend...");
            
            try {
                # Call the walker we defined in app.jac
                result = get_all_articles();
                if result and "articles" in result {
                    setArticles(result["articles"]);
                }

                console.log("Result:", result);
                
                if result and result.reports {
                    data = result.reports[0];
                    if "articles" in data {
                        console.log("Found articles:", len(data["articles"]));
                        setArticles(data["articles"]);
                    }
                }
            } except Exception as e {
                console.error("Error:", str(e));
            }
            
            setLoading(False);
        }
        
        # Load on mount
        useEffect(lambda -> None {
            fetchArticles();
        }, []);
        
        # Filter articles
        filtered = [];
        for art in articles {
            score = art.get("credibility_score", 0);
            if score >= minCredibility {
                filtered.append(art);
            }
        }
        
        # Components
        def Header() -> any {
            return <div style={{
                "background": "linear-gradient(to right, #2563eb, #9333ea)",
                "color": "white",
                "padding": "20px",
                "marginBottom": "20px"
            }}>
                <div style={{"maxWidth": "1200px", "margin": "0 auto", "display": "flex", "justifyContent": "space-between", "alignItems": "center"}}>
                    <h1 style={{"margin": "0"}}>📰 News Curator</h1>
                    <button onClick={lambda -> None { setShowPrefs(not showPrefs); }} style={{
                        "background": "white",
                        "color": "#2563eb",
                        "padding": "10px 20px",
                        "border": "none",
                        "borderRadius": "6px",
                        "cursor": "pointer",
                        "fontWeight": "bold"
                    }}>⚙️ Preferences</button>
                </div>
            </div>;
        }
        
        def ArticleCard(article: dict) -> any {
            score = article.get("credibility_score", 0);
            title = article.get("title", "No title");
            url = article.get("url", "");
            author = article.get("author", "Unknown");
            content = article.get("content", "");
            
            bgColor = "#dcfce7" if score >= 60 else ("#fef3c7" if score >= 40 else "#fee2e2");
            
            return <div style={{
                "background": "white",
                "padding": "16px",
                "marginBottom": "12px",
                "borderRadius": "8px",
                "border": "1px solid #e5e7eb",
                "boxShadow": "0 1px 3px rgba(0,0,0,0.1)"
            }}>
                <h3 style={{"margin": "0 0 8px 0", "fontSize": "18px"}}>{title}</h3>
                <div style={{"fontSize": "12px", "color": "#6b7280", "marginBottom": "8px"}}>
                    By {author}
                </div>
                {len(content) > 0 and <p style={{"fontSize": "14px", "color": "#4b5563", "marginBottom": "12px"}}>
                    {content[:200]}...
                </p>}
                <div style={{
                    "display": "inline-block",
                    "padding": "4px 12px",
                    "borderRadius": "12px",
                    "fontSize": "12px",
                    "fontWeight": "bold",
                    "background": bgColor,
                    "marginBottom": "8px"
                }}>
                    Credibility: {int(score)}/100
                </div>
                <br/>
                <button onClick={lambda -> None { window.open(url, "_blank"); }} style={{
                    "background": "#2563eb",
                    "color": "white",
                    "padding": "8px 16px",
                    "border": "none",
                    "borderRadius": "6px",
                    "cursor": "pointer",
                    "fontSize": "14px"
                }}>Read Article →</button>
            </div>;
        }
        
        def PreferencesPanel() -> any {
            return <div style={{
                "position": "fixed",
                "top": "0",
                "left": "0",
                "right": "0",
                "bottom": "0",
                "background": "rgba(0,0,0,0.5)",
                "display": "flex",
                "alignItems": "center",
                "justifyContent": "center",
                "zIndex": "1000"
            }} onClick={lambda -> None { setShowPrefs(False); }}>
                <div style={{
                    "background": "white",
                    "padding": "24px",
                    "borderRadius": "12px",
                    "maxWidth": "500px",
                    "width": "90%"
                }} onClick={lambda e: any -> None { e.stopPropagation(); }}>
                    <h2 style={{"marginTop": "0"}}>Preferences</h2>
                    
                    <h3>Minimum Credibility</h3>
                    <input type="range" min="0" max="100" value={minCredibility}
                        onChange={lambda e: any -> None { setMinCredibility(int(e.target.value)); }}
                        style={{"width": "100%", "marginBottom": "8px"}} />
                    <div style={{"textAlign": "center", "marginBottom": "20px", "fontSize": "18px", "fontWeight": "bold"}}>
                        {int(minCredibility)}/100
                    </div>
                    
                    <button onClick={lambda -> None { setShowPrefs(False); }} style={{
                        "width": "100%",
                        "background": "#2563eb",
                        "color": "white",
                        "padding": "12px",
                        "border": "none",
                        "borderRadius": "6px",
                        "cursor": "pointer",
                        "fontWeight": "bold",
                        "fontSize": "16px"
                    }}>Done</button>
                </div>
            </div>;
        }
        
        # Main render
        return <div style={{"minHeight": "100vh", "background": "#f3f4f6"}}>
            <Header />
            
            {showPrefs and <PreferencesPanel />}
            
            <div style={{"maxWidth": "1200px", "margin": "0 auto", "padding": "0 16px"}}>
                <h2 style={{"marginBottom": "16px"}}>Your News Feed ({len(filtered)} articles)</h2>
                
                {loading and <div style={{"textAlign": "center", "padding": "40px", "fontSize": "18px"}}>
                    Loading articles...
                </div>}
                
                {not loading and len(filtered) == 0 and <div style={{
                    "background": "white",
                    "padding": "40px",
                    "textAlign": "center",
                    "borderRadius": "8px"
                }}>
                    <p style={{"fontSize": "18px"}}>No articles found. Try adjusting your credibility filter.</p>
                </div>}
                
                {not loading and len(filtered) > 0 and <div>
                    {filtered.map(lambda article: any -> any {
                        return <ArticleCard article={article} />;
                    })}
                </div>}
            </div>
        </div>;
    }
}