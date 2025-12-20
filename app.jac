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
    has state: dict[];
    has title: str;
    has description: str;
 
    def add_topic(title: str, description: str) -> Topic{
        new_topic = Topic(
            title = self.title,
            description = self.description

        );
        
    }
    here.state["added_topic"]= def add_topic(here.state);

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
    print(Articles.add_article());
}

edge user_interests{
    has strength: int;
}

edge credibility{
    has score: float;
}

#walkers

walker fetch_articles{
    has state: dict[];
    
    can scrape_articles with User entry{
        def article_scrapper(user: User, topics: Topics) -> list(Articles) by llm{
                articles.append(article);
            }
            return articles;            
        }
        self.state(articles) = article_scrapper(self.state);
        print(f"Fetched Articles: {self.state.articles}");
}

walker recommendations(fetch_articles){
    can recommend_articles with Topics entry{
        def article_reccommender(user: User, articles: list(Articles)) -> list(Articles) by llm{
                recommended.append(article);
            };
            return recommended;
        };
        self.state(recommended) = article_reccommender(self.state)
        print(f"Recommended Articles: {self.state.recommended}");
}

walker check_credibility (fetch_articles) {
    has score_credibility: float;

    can determine_credibilty with Articles entry{    
        def evaluate_credibility(article: Articles) -> float by llm{
            return score;
        };
        self.score_credibility = evaluate_credibility(self.state);
        return self.score_credibility;
    } 
}

with entry{

    root ++> User;
    User ++> Topics ++> Articles;
    User +>: user_interests :+> Topics;


    curator = fetch_articles();
    root spawn curator;


}
