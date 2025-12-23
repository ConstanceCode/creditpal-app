import feedparser
import requests
import os

class NewsAPIFetcher:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://newsapi.org/v2/everything"
    
    def fetch(self, topic: str, limit: int = 10):
        if not self.api_key:
            print("Warning: NewsAPI key not found")
            return []
        
        try:
            params = {
                "q": topic,
                "pageSize": limit,
                "language": "en",
                "sortBy": "publishedAt",
                "apiKey": self.api_key
            }
            response = requests.get(self.base_url, params=params, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                articles = []
                for article in data.get("articles", []):
                    articles.append({
                        "title": article.get("title", ""),
                        "content": article.get("content", "") or article.get("description", ""),
                        "author": article.get("author", "Unknown"),
                        "url": article.get("url", ""),
                        "source": article.get("source", {}).get("name", "Unknown"),
                        "published_at": article.get("publishedAt", ""),
                        "image_url": article.get("urlToImage", "")
                    })
                return articles
            else:
                print(f"NewsAPI error: {response.status_code}")
                return []
        except Exception as e:
            print(f"NewsAPI exception: {e}")
            return []

class GNewsAPIFetcher:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://gnews.io/api/v4/search"
    
    def fetch(self, topic: str, limit: int = 10):
        if not self.api_key:
            print("Warning: GNews API key not found")
            return []
        
        try:
            params = {
                "q": topic,
                "lang": "en",
                "max": limit,
                "apikey": self.api_key
            }
            response = requests.get(self.base_url, params=params, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                articles = []
                for article in data.get("articles", []):
                    articles.append({
                        "title": article.get("title", ""),
                        "content": article.get("content", "") or article.get("description", ""),
                        "author": article.get("source", {}).get("name", "Unknown"),
                        "url": article.get("url", ""),
                        "source": article.get("source", {}).get("name", "Unknown"),
                        "published_at": article.get("publishedAt", ""),
                        "image_url": article.get("image", "")
                    })
                return articles
            else:
                print(f"GNews error: {response.status_code}")
                return []
        except Exception as e:
            print(f"GNews exception: {e}")
            return []

class RSSFeedFetcher:
    def __init__(self):
        self.feeds = [
            "http://rss.cnn.com/rss/cnn_topstories.rss",
            "http://feeds.bbci.co.uk/news/rss.xml",
            "https://www.theguardian.com/world/rss",
            "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml",
            "https://feeds.reuters.com/reuters/topNews"
        ]
    
    def fetch(self, topic: str, limit: int = 10):
        articles = []
        topic_lower = topic.lower()
        
        try:
            for feed_url in self.feeds:
                try:
                    print(f"Fetching RSS: {feed_url}")
                    feed = feedparser.parse(feed_url)
                    
                    for entry in feed.entries[:30]:
                        title = entry.get("title", "").lower()
                        summary = entry.get("summary", "").lower()
                        
                        if topic_lower in title or topic_lower in summary:
                            articles.append({
                                "title": entry.get("title", ""),
                                "content": entry.get("summary", "") or entry.get("description", ""),
                                "author": entry.get("author", "Unknown"),
                                "url": entry.get("link", ""),
                                "source": feed.feed.get("title", "RSS Feed"),
                                "published_at": entry.get("published", ""),
                                "image_url": ""
                            })
                            print(f"  Found: {entry.get('title', '')[:50]}")
                        
                        if len(articles) >= limit:
                            break
                except Exception as e:
                    print(f"RSS feed error ({feed_url}): {e}")
                    continue
                
                if len(articles) >= limit:
                    break
            
            print(f"Total RSS articles found: {len(articles)}")
            return articles
        except Exception as e:
            print(f"RSS fetcher exception: {e}")
            return []

def load_env_file(filepath: str = ".env"):
    """Load environment variables from .env file"""
    try:
        from dotenv import load_dotenv
        load_dotenv(filepath)
        print(f"Loaded environment from {filepath}")
        return {}
    except Exception as e:
        print(f"Warning: Could not load {filepath}: {e}")
        return {}
