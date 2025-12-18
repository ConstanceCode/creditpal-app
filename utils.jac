#utility fuctions

import os;
import requests;
import from datetime {datetime, timedelta}
import from openai


glob env_loaded = load_dotenv(); #load environment varuables from .env file

#News API Key config
openai.api_key = os.getenv("OPENAI_API_KEY")
NEWS_API_KEY = os.getenv("NEWS_API_KEY")

def fetch_news_from_api(topic: str) -> list[dict] {
    url = f"https://newsapi.org/v2/top-headlines?q={topic}&apiKey={NEWS_API_KEY}";
    params = {
        "country": "ke",
        "language": "en",
        "sortBy": "relevancy",
        "apiKey": NEWS_API_KEY
    };
    response = requests.get(url, params=params);
    articles = response.json();

    articles = [];
    for article in articles.get("articles", []) {
        articles.append({
            "title": article["title"],
            "description": article["description"],
            "url": article["url"],
            "source": article["source"]["name"],
            "publishedAt": article["publishedAt"]
        });
    }
    return articles;
}