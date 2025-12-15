node topics{
    has name: str;
    has description;
    has articles: list[article];
    has reccomended_articles: list[article];
    has state: dict[];
    

}
node article(topics){
    has title: str;
    has content: str;

}

walker FetchNews(topic: str) -> list[article] {
    articles = [];
    # Simulate fetching articles
    #for i in range(5) {
       # article_node = create node article;
        #article_node.title = f"Article {i+1} on {topic}";
       # article_node.content = f"This is the content of article {i+1} about {topic}.";
        #articles.append(article_node);
    #}
    return articles;
}

walker RecommendArticles(user_interests: list[str]) -> list[article] {
    recommended = [];
    # Simulate recommending articles based on user interests
    #for interest in user_interests {
       # articles = FetchNews(interest);
       # recommended.extend(articles[:2]);  # Recommend top 2 articles per interest
    #}
    return recommended;
}