
import from byllm.lib {Model}
import os;
import json;
import re;
import from tools.news_fetchers {
    NewsAPIFetcher,
    GNewsAPIFetcher,
    RSSFeedFetcher
}

# LLM Setup with fallback
glob llm_primary = Model(model_name="groq/llama-3.3-70b-versatile");
glob llm_fallback = Model(model_name="gemini/gemini-2.0-flash-exp");
glob llm = llm_primary;
glob using_fallback = False;

# Initialize news fetchers
glob newsapi_fetcher = NewsAPIFetcher(api_key=os.getenv("NEWSAPI_KEY", ""));
glob gnews_fetcher = GNewsAPIFetcher(api_key=os.getenv("GNEWS_API_KEY", ""));
glob rss_fetcher = RSSFeedFetcher();

# ============ BYLLM FUNCTIONS ============

def analyze_article(article: any, source: any) -> str by llm(incl_info=("Analyze this article for credibility. Consider source reputation, writing quality, fact-checking. Return ONLY a JSON string with this exact structure: {\"credibility_score\": <number 0-100>, \"reasoning\": \"<explanation>\"}"));

def detect_bias(content: str) -> str by llm(incl_info=("Detect political bias in this content. Analyze word choice, framing, balance. Return ONLY a JSON string: {\"bias_score\": <number -100 to 100>, \"explanation\": \"<text>\"}"));

def detect_polarization(content: str) -> str by llm(incl_info=("Measure how polarizing this language is. Look for emotional language, us vs them framing. Return ONLY a number between 0-100 as a string."));

def extract_claims(content: str) -> str by llm(incl_info=("Extract factual claims from this content. Return ONLY a JSON array of strings: [\"claim 1\", \"claim 2\", \"claim 3\"]"));

def summarize_article(content: str) -> str by llm(incl_info=("Summarize this article in 60-80 words, 3-4 sentences. Focus on key facts, maintain neutral tone."));

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
        import time;
        import re;
        
        time.sleep(2);  # Rate limit protection
        
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
                # Truncate content to avoid token limits
                content_truncated = here.content[:3000] if len(here.content) > 3000 else here.content;
                
                # Helper function to clean LLM response
                def clean_json_response(response_str: str) -> str {
                    # Remove markdown code blocks
                    cleaned = response_str.replace("```json", "").replace("```python", "").replace("```", "");
                    # Remove any leading/trailing whitespace
                    cleaned = cleaned.strip();
                    # Replace single quotes with double quotes for valid JSON
                    cleaned = cleaned.replace("'", '"');
                    return cleaned;
                }
                
                # Get credibility analysis
                cred_result_str = analyze_article(here.title + " " + content_truncated[:1000], source);
                cred_result_str = clean_json_response(cred_result_str);
                
                try {
                    cred_result = json.loads(cred_result_str);
                    here.credibility_score = float(cred_result.get("credibility_score", 50.0));
                } except Exception as parse_err {
                    # Extract number from string
                    numbers = re.findall(r'\d+', cred_result_str);
                    here.credibility_score = float(numbers[0]) if numbers else 50.0;
                }
                
                # Get bias analysis  
                bias_result_str = detect_bias(content_truncated[:2000]);
                bias_result_str = clean_json_response(bias_result_str);
                
                try {
                    bias_result = json.loads(bias_result_str);
                    here.bias_score = float(bias_result.get("bias_score", 0.0));
                } except Exception as parse_err {
                    numbers = re.findall(r'-?\d+\.?\d*', bias_result_str);
                    here.bias_score = float(numbers[0]) if numbers else 0.0;
                }
                
                # Get polarization score
                polar_str = detect_polarization(content_truncated[:2000]);
                polar_str = polar_str.strip();
                
                try {
                    here.polarization_score = float(polar_str);
                } except Exception {
                    numbers = re.findall(r'\d+\.?\d*', polar_str);
                    here.polarization_score = float(numbers[0]) if numbers else 0.0;
                }
                
                # Extract claims
                claims_str = extract_claims(content_truncated[:2000]);
                claims_str = clean_json_response(claims_str);
                
                try {
                    here.claims = json.loads(claims_str);
                } except Exception {
                    here.claims = [];
                }
                
                # Generate summary
                here.summary = summarize_article(content_truncated[:2000]);
                if len(here.summary) > 500 {
                    here.summary = here.summary[:500];
                }
                
                # Update source credibility
                source.update_credibility(here.credibility_score);
                
                success = True;
                
                print(
                    "   ✅ Credibility: " + str(int(here.credibility_score)) +
                    "/100 | Bias: " + str(int(here.bias_score)) +
                    " | Polarization: " + str(int(here.polarization_score)) + "/100"
                );
            }
            except Exception as e {
                retry_count += 1;
                print(f"❌ Attempt {retry_count} failed: {str(e)[:200]}");
                
                if retry_count == 1 and not using_fallback {
                    print("\n🔄 Switching to Gemini fallback...");
                    llm = llm_fallback;
                    using_fallback = True;
                } elif retry_count >= self.max_retries {
                    print(f"⚠️  Analysis failed after {self.max_retries} attempts");
                    # Set default values
                    here.credibility_score = 50.0;
                    here.bias_score = 0.0;
                    here.polarization_score = 0.0;
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
        print(f"Updated interests for {self.user_id}");
        report {"updated": True};
          # --- Find topics this article belongs to ---
        topics = [article <-- Topic];}
}
walker FetchNewsAPI {
    has topic: str;

    can fetch with `root entry {
        fetcher = FetchNewsWalker(topic=self.topic, max_articles=10);
        root spawn fetcher;
        report {"status": "fetch_started"};
    }
}
walker GetArticlesByTopicWalker {
    has topic_name: str;
    
    can get_by_topic with `root entry {
        all_nodes = [-->];
        
        # Find the topic node
        topic_node = None;
        for node in all_nodes {
            if isinstance(node, Topic) and node.name == self.topic_name {
                topic_node = node;
                break;
            }
        }
        
        if not topic_node {
            report {"articles": [], "message": "Topic not found"};
            return;
        }
        
        # Get articles connected to this topic
        articles = [topic_node --> Article];
        
        report {"articles": articles, "topic": self.topic_name};
    }
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
walker ClearAllArticlesWalker {
    can clear with `root entry {
        print("\n🗑️  Clearing all articles from database...");
        
        all_nodes = [-->];
        
        # Count what we're deleting
        article_count = 0;
        topic_count = 0;
        source_count = 0;
        
        # Delete all articles, topics, and sources
        for node in all_nodes {
            if isinstance(node, Article) {
                del node;
                article_count += 1;
            } elif isinstance(node, Topic) {
                del node;
                topic_count += 1;
            } elif isinstance(node, Source) {
                del node;
                source_count += 1;
            }
        }
        
        print(f"✅ Deleted: {article_count} articles, {topic_count} topics, {source_count} sources");
        
        report {
            "deleted_articles": article_count,
            "deleted_topics": topic_count,
            "deleted_sources": source_count,
            "message": "Database cleared successfully"
        };
    }
}
# ============ ENTRY POINT ============
with entry {
    print("Starting News Curator backend...");

    user = UserProfile(
        user_id="user_001",
        interests=["technology", "artificial intelligence", "climate change"]
    );
    root ++> user;

    print("Backend ready");
}

