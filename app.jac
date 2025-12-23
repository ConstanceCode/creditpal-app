
import from byllm.lib {Model}
import os;
import from tools.news_fetchers {
    NewsAPIFetcher,
    GNewsAPIFetcher,
    RSSFeedFetcher
}


# LLM Setup with fallback
glob llm_primary = Model(model_name="gemini/gemini-2.0-flash-exp");
glob llm_fallback = Model(model_name="groq/llama-3.1-70b-versatile");
glob llm = llm_primary;
glob using_fallback = False;

# Initialize news fetchers
glob newsapi_fetcher = NewsAPIFetcher(api_key=os.getenv("NEWSAPI_KEY", ""));
glob gnews_fetcher = GNewsAPIFetcher(api_key=os.getenv("GNEWS_API_KEY", ""));
glob rss_fetcher = RSSFeedFetcher();

# ============ BYLLM FUNCTIONS ============

def analyze_article(article: obj, source: obj) -> dict by llm();
def detect_bias(content: str) -> dict by llm();
def detect_polarization(content: str) -> float by llm();
def extract_claims(content: str) -> list by llm();
def verify_claims(claims: list[str], all_articles: list) -> dict by llm();
def summarize_article(content: str) -> str by llm();
def extract_entities(content: str) -> dict by llm();
def calculate_relevance(article: obj, user_interests: list[str]) -> float by llm();
def recommend_articles(articles: list, user_profile: obj) -> list by llm();

# ============ NODES ============

node UserProfile {
    has user_id: str = "";
    has name: str = "Default User";
    
    has interests: list[str] = [];
    has reading_history: list[str] = [];
    has bias_preferences: dict = {};
    
    def update_interests(new_interests: list[str]) {
        for interest in new_interests {
            if interest not in self.interests {
                self.interests.append(interest);
            }
        }
    }    
    def record_read(article_id: str) {
        if article_id not in self.reading_history {
            self.reading_history.append(article_id);
        }
    }
}

node Topic {
    has name: str = "";
    has description: str = "";
    has keywords: list[str] = [];
}

node Source {
    has name: str = "";
    has url: str = "";
    has credibility_score: float = 50.0;
    has bias_rating: str = "neutral";
    has article_count: int = 0;
    
    def update_credibility(new_score: float) {
        self.credibility_score = (self.credibility_score * 0.7) + (new_score * 0.3);
    }
}

node Article {
    has article_id: str = "";
    has title: str = "";
    has content: str = "";
    has url: str = "";
    has author: str = "Unknown";
    has published_at: str = "";
    has image_url: str = "";
    
    has summary: str = "";
    has credibility_score: float = 0.0;
    has bias_score: float = 0.0;
    has polarization_score: float = 0.0;
    has claims: list[str] = [];
    has verified_claims: dict = {};
    
    has read_count: int = 0;
}

# ============ EDGES ============

edge interested_in {
    has strength: float = 1.0;
}

edge published_by {
    has published_date: str;
}

edge belongs_to_topic {
    has relevance: float = 1.0;
}

# ============ HELPER FUNCTIONS ============

def filter_by_credibility(articles: list, min_score: float) -> list {
    filtered = [];
    for art in articles {
        if art.credibility_score >= min_score {
            filtered.append(art);
        }
    }
    return filtered;
}

def diversify_viewpoints(articles: list) -> list {
    diverse = [];
    bias_counts = {"not_biased": 0, "neutral": 0, "biased": 0};
    
    for article in articles {
        bias = "neutral";
        if article.bias_score < -30 {
            bias = "not_biased";
        } elif article.bias_score > 30 {
            bias = "biased";
        }
        
        if bias_counts[bias] < 3 {
            diverse.append(article);
            bias_counts[bias] += 1;
        }
    }
    
    return diverse;
}
def get_all_articles() -> dict {
    result = root spawn GetAllArticlesWalker();
    return result.reports[0];
}


# ============ WALKERS ============

walker FetchNewsWalker {
    has topic: str;
    has max_articles: int = 20;
    
    can crawl with `root entry {
        print(f"\nFetching news for: {self.topic}");
        
        newsapi_articles = newsapi_fetcher.fetch(self.topic, 10);
        gnews_articles = gnews_fetcher.fetch(self.topic, 10);
        rss_articles = rss_fetcher.fetch(self.topic, 10);
        
        all_articles = newsapi_articles + gnews_articles + rss_articles;
        
        seen_urls = set();
        raw_articles = [];
        for article in all_articles {
            url = article.get("url", "");
            if url and url not in seen_urls {
                seen_urls.add(url);
                raw_articles.append(article);
            }
        }
        
        print(f"Found {len(raw_articles)} unique articles");
        
        # Find existing topic node - check type explicitly
        all_nodes = [-->];
        topic_node = None;
        for node in all_nodes {
            if isinstance(node, Topic) and node.name == self.topic {
                topic_node = node;
                break;
            }
        }
        
        # Create topic if it doesn't exist
        if not topic_node {
            topic_node = Topic(name=self.topic, description=f"News about {self.topic}");
            here ++> topic_node;
        }
        
        processed = [];
        for raw_art in raw_articles {
            # Check for existing article - use isinstance to filter by type
            all_nodes_check = [-->];
            article_exists = False;
            for node in all_nodes_check {
                if isinstance(node, Article) and node.url == raw_art["url"] {
                    article_exists = True;
                    break;
                }
            }
            
            if article_exists {
                continue;
            }
            
            article = Article(
                article_id=raw_art["url"],
                title=raw_art["title"],
                content=raw_art.get("content", ""),
                url=raw_art["url"],
                author=raw_art.get("author", "Unknown"),
                published_at=raw_art.get("published_at", ""),
                image_url=raw_art.get("image_url", "")
            );
            
            # Find or create source - use isinstance
            all_nodes_src = [-->];
            source = None;
            for node in all_nodes_src {
                if isinstance(node, Source) and node.name == raw_art["source"] {
                    source = node;
                    break;
                }
            }
            
            if not source {
                source = Source(name=raw_art["source"]);
                here ++> source;
            }
            
            source ++> article;
            topic_node ++> article;
            here ++> article;
            processed.append(article);
        }
        
        print(f"Added {len(processed)} new articles\n");
        report {"articles_fetched": len(processed), "articles": processed};
    }
}

walker AnalyzeCredibilityWalker {
    has max_retries: int = 2;
    
    can start with `root entry {
        visit [-->Article];
    }
    
    can analyze with Article entry {
        title_short = here.title[:60] + "..." if len(here.title) > 60 else here.title;
        print(f"Analyzing: {title_short}");
        
        sources = [<--Source];
        if not sources {
            print("No source found");
            return;
        }
        source = sources[0];
        
        retry_count = 0;
        success = False;
        
        while retry_count < self.max_retries and not success {
            try {
                cred_result = analyze_article(here, source);
                here.credibility_score = cred_result.get("credibility_score", 50.0);
                
                bias_result = detect_bias(here.content);
                here.bias_score = bias_result.get("bias_score", 0.0);
                
                here.polarization_score = detect_polarization(here.content);
                here.claims = extract_claims(here.content);
                
                source.update_credibility(here.credibility_score);
                
                print(
                    "   Credibility: " + str(here.credibility_score) +
                    "/100 | Bias: " + str(here.bias_score) +
                    " | Polarization: " + str(here.polarization_score) + "/100"
                );
            }
            except Exception as e {
                retry_count += 1;
                print(f"Attempt {retry_count} failed: {str(e)[:50]}");
                
                if retry_count == 1 and not using_fallback {
                    print("\nSwitching to Groq fallback...");
                    llm = llm_fallback;
                    using_fallback = True;
                } elif retry_count >= self.max_retries {
                    print(f"Analysis failed after {self.max_retries} attempts");
                }
            }
        }
    }
}

walker ProcessArticlesWalker {
    can start with `root entry {
        visit [-->Article];
    }
    
    can process with Article entry {              
        if not here.summary {
            try {
                here.summary = summarize_article(here.content);
                print(f"Summarized: {here.title[:50]}...");
            } except Exception as e {
                print(f"Summary failed: {str(e)[:50]}");
                if not using_fallback {
                    print("\nSwitching to Groq fallback...");
                    llm = llm_fallback;
                    using_fallback = True;
                }
            }
        }
    }
}

walker CrossCheckClaimsWalker {
    has article: Article;
    
    can check with `root entry {
            if not self.article.claims {
            report {"error": "No claims to verify"};
            return;
        }
        
        print(f"\nCross-checking {len(self.article.claims)} claims...");
        
        all_articles = [-->Article];
        
        try {
            verification = verify_claims(self.article.claims, all_articles);
            self.article.verified_claims = verification;
            
            verified = 0;
            disputed = 0;

            for claim in verification {
            status = verification[claim]["status"];
            if status == "verified" {
            verified += 1;
            }
            elif status == "disputed" {
                disputed += 1;
            }
        }         
            print(f"Results: {verified} verified, {disputed} disputed");
            report verification;
            
        } except Exception as e {
            print(f"Verification failed: {e}");
            if not using_fallback {
                print("\nSwitching to Groq fallback...");
                llm = llm_fallback;
                using_fallback = True;
            }
            report {"error": str(e)};
        }
    }
}

walker RecommendArticlesWalker {
    has user_id: str;
    has min_credibility: float = 40.0;
    
    can recommend with `root entry {
        print(f"\nGenerating recommendations for {self.user_id}...");
        
        users = [-->UserProfile(user_id == self.user_id)];
        if not users {
            print("User not found");
            report {"error": "User not found"};
            return;
        }
        user = users[0];
        
        all_articles = [-->Article];
        print(f"   Evaluating {len(all_articles)} articles...");
        
        credible_articles = filter_by_credibility(all_articles, self.min_credibility);
        print(f"   {len(credible_articles)} meet credibility threshold ({self.min_credibility})");
        
        try {
            recommended = recommend_articles(credible_articles, user);
            diversified = diversify_viewpoints(recommended);
            
            print(f"Recommended {len(diversified)} articles");
            
            report {
                "user_id": self.user_id,
                "total_articles": len(all_articles),
                "credible_articles": len(credible_articles),
                "recommended": diversified
            };
            
        } except Exception as e {
            print(f"Recommendation failed: {e}");
            if not using_fallback {
                print("\nSwitching to Groq fallback...");
                llm = llm_fallback;
                using_fallback = True;
            }
            report {"error": str(e)};
        }
    }
}

walker UpdateUserInterestsWalker {
    has user_id: str;
    has article_id: str;
    has engagement_score: float;
    
    can update with `root entry {
        users = [-->UserProfile(user_id == self.user_id)];
        if not users {
            return;
        }
        user = users[0];
        
        articles = [-->Article(article_id == self.article_id)];
        if not articles {
            return;
        }
        article = articles[0];
        # --- Update read history ---
        user.record_read(self.article_id);
        article.read_count += 1;
          # --- Find topics this article belongs to ---
        topics = [article <-- Topic];}
        }


walker GetAllArticlesWalker {
    can get_articles with `root entry {
        all_nodes = [-->];
        article_nodes = [];
        for node in all_nodes {
            if isinstance(node, Article) {
                article_nodes.append(node);
            }
        }
        report {"articles": article_nodes};
    }
}
# ============ ENTRY POINT ============


with entry {   
    print("\n" + "="*60);
    print("   NEWS CURATOR & MISINFORMATION DETECTOR");
    print("="*60);
    print(f"\nPrimary LLM: Google Gemini (gemini-2.0-flash-exp)");
    print(f"Fallback LLM: Groq (llama-3.1-70b-versatile)");
    print(f"News Sources: NewsAPI, GNews, RSS Feeds");
    print("\n" + "="*60 + "\n");
    
    print("Checking LLM connection...");
    print("LLM will be tested lazily on first invocation.\n");
    
    print("Initializing system...\n");
    
    user = UserProfile(
        user_id="user_001",
        interests=["technology", "artificial intelligence", "climate change"]
    );
    root ++> user;
    print(f"User profile created");
    print(f"  Interests: {', '.join(user.interests)}");
    
    print(f"System initialized\n");
    
    print("="*60);
    for interest in user.interests[:2] {
        fetcher = FetchNewsWalker(topic=interest, max_articles=10);
        root spawn fetcher;
    }
    
    print("="*60);
    print("\nSystem ready! You can now:");
    print("   1. Analyze articles with AnalyzeCredibilityWalker");
    print("   2. Get recommendations with RecommendArticlesWalker");
    print("   3. Cross-check claims with CrossCheckClaimsWalker");
    print("\n" + "="*60 + "\n");
}
