import utils


#load environment varuables from .env file
glob env_loaded = load_dotenv(); #global instance to load my environment in(for my different nodes & walkers)

#BE Code 
node User{
    has name: str;
    has email: str;


    def getUser() -> dict {
        return {
            "name": "johndoe",
            "email": "johndoe@example.com"
        }
    }
}
node Topics{
    has title: str;
    has description: str;
 
    def AddTopic(title: str, description: str) -> Topic{
        new_topic = Topic(
            title = self.title,
            description = self.description
        );
        
    }
}

node Articles{
    has title: str;
    has url: str;
    has content: str;
    has credibility_score: float;
    has summary: str;

    def add_article (article: Articles) -> bool{ #to avoid article repetition
        existing = [self --> essay --> Articles](title == essay.title);
        if existing{
            return false;
        }
    }

}

edge user_interests{
    has strength: int;
}

edge credibility{
    has score: float;
}

walker fetch_articles{
    has articles: list(Articles);
    has recommended: list(Articles);
    
    can scrape_articles with User entry{
        def article_scrapper(user: User, topics: Topics) -> list(Articles) by llm{
                articles.append(article);
            }
            return articles;
            
        }
    can recommend_articles with Topics entry{
        def article_recommender(user: User, articles: list(Articles)) -> list(Articles) by llm{
                recommended.append(article);
            };
            return recommended;
        };
}

walker check_credibility with Articles entry{
    has credibility_score: float;

    def evaluate_credibility(article: Articles) -> float by llm{
            return score;
        };
} 

with entry{

    root ++> User;
    User ++> Topics ++> Articles;
    User :++> user_interests :++> Topics;

    fetched_articles = scrape_articles();
    print(f"Fetched Articles: {fetched_articles}");
    recommended_articles = recommend_articles(fetched_articles);
    print(f"Recommended Articles: {recommended_articles}");

    credibility_score = evaluate_credibility();
    print(f"Credibility Score: {credibility_score}");


}
