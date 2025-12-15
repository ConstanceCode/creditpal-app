#OUK/JASECI CREDITPAL APP MAIN FILE


import from py {dotenv, load_dotenv}

#load environment varuables from .env file
glob env_loaded = load_dotenv(); #global instance to load my environment in(for my different nodes & walkers)

enum TopicsCategory {
    Technology,
    Business,
    Health,
    Sports,
    Entertainment,
    Science,
    World
    
}

enum LoanType {
    Personal,
    Mortgage,
    Mcash,
    Farming,
    Education,
    Student,
    Business
}

edge HasSettings{}
edge HasCategory{}
edge HasTopic{}
edge HasArticle{}
edge HasSource{}
edge HasClient{}
edge HasLoan{}

node User {
    has name : str;
    has email : str;
    has password: str;
}

node Settings{
    has tasks_alert: bool = true;
    has language: str = "English";
    
}

node Category {
    has name: str;
    has category_type: TopicCategory;
    has description: str;

}
node Topic{
    has name: str;
    has description: str;
    has created_at: str;
}

node Sources{
    has name: str;
    has credibility_score: int;
    has number_of_publications: int;
    has level_of_education: str;
}

node Articles {
    has title: str;
    has author: str;
    has content: str;
    has topic: str;
    has publication_date: str;
    has credibility_score: int;
    has summary: str;

}


node Clients {
    has name: str;
    has number_of_loans: int;
    has type_of_loan: LoanType;
    has repayment_balance: int;
    
    
}

node Loans {
    has type_of_loan: LoanType;
    has disbursment_date: str;
    has due_date: str;
    has outstanding_principal: int;
    has outstanding_interest: int;
    has total_loan_balance: int;
    has penalty: float;
    has reminder: bool = true;
    has arrears: float;
    has prepayment: int;
}



walker init_graph{
    #initialize my graph with default user and settings

    has user_name:str;

    can create_graph with `root entry{ #creates the user node
        user = here ++> User(
            name = self.user_name,
            email = "",
            password = ""
        );
    settings = here ++> Settings(); #creates the default settings
    
    user +: HasCategory :+> settings; #link user to settings through edge category

    #creates category nodes for default categories
    for cat in TopicCategory{
        cat_node = user ++> Category(
            name = str(cat),
            category_type = cat
        );
    };
    report {
        "message": "Graph initialized with default user and settings",
        "user": user.name
        };
}

### walkers for the news & verifications

walker NewsAggregator { #fetch news
    has topics: list[str] = [];
    has source_preferences: list[str] = [];
    has credibility_threshold: int = 50;
    has matched_articles: list[Articles] = [];


    can fetch with User entry{
        visit [-->(`?User)]; #navigate to user node

        report{
            "topic_preferences": self.matched_topics,
            "source_preferences": self.source_preferences,
            "credibility_threshold": self.credibility_threshold
        }
    }

       can fetch_news with Article entry {
            if self.credibility_score >= visitor.credibility_threshold {
                self.topics.append(self.topic);
            }
        };
    }
}

walker FactChecker{
    has minimum_score: int = 70;
    has results: dict = {};

    can check with user entry{
        visit [-->(`?Article)]; #navigate to articles node

        report{
            "verified_articles": self.results
        };
    }


    can fact_check with Article entry{

        verdict = if self.credibility_score > 70 { 
           "Reliable"};
            else { "Unreliable" };

        visitor.results.append({
            "article": self.title,
            "score": self.credibility_score,
            "verdict": verdict
        })

    }
    
}

walker SummarizeArticle{
    has summary_length: int = 100;

    can summarize_article withArticle entry{
        visit [-->(`?Articles)]; #navigate to articles node
        
        if len(self.content) > 100{
            self.summary = subtr(self.content, 0, 120) + "...";
        }
        else{
            self.summary = self.content;
        }

        report{
            "message": "Article summarized",
            "title": self.title,
            "summary": self.summary
        }
    }
}

walker AddTopic {#add a new topic intrest to Topics
    has category_name: str;
    has topic_name: str;


    can add with user entry{
        
    visit [-->(`?Category)]; #navigate to category nodes

    }
    can add with Category entry{
        #to find the matching category
        target_category = None; 

        for cat in [-->](`?Category){
            if cat.name==self.category_name.upper{
                target_category = cat;
                break;
            }
        };
        #if not target_category{
           # for cat in [-->](`?Category){
              #  if cat.category_type == 
           # }
        #}
    }
    #creating a new topic node under the category
    can create_topic with Category entry{
        if self.target_category != None {
            topic_node = self.target_category ++> Topics(
                name = self.subject,
                created_at = get_current_datetime()
            );
        }
    }
    #creates a deefault topic in category for first time users
    can create_default_topic with Category entry{
        if self.target_category != None {
            default_topic = self.target_category ++> Topics(
                name = "Business",
                created_at = get_current_datetime()
            );
        }
    }


    report{
        "message": "New topic interest added",
        "topic": self.subject,
        "category": self.target_category.name,
        "default_topic": "Business"
    }
}

###walkers for the loans and clients

walker LoanPerformance{
    has client_name: str;
    has loan_type: str;
    has defaulted_loans: float;
    has on_sch_loans: float;

    can check loan_performance with Loans entry{
        loan_node = here ++> Loans(
            name = self.client_name,
            created_at = get get_current_datetime(),
            type = self.loan_type,
            default = self.defaulted_loans,
            on_schedule = self.on_sch_loans

        );
    }

    report{
        "message": "Loan performance evaluation started",
        "loans": loan_node.name,
        "type": loan_node.type,
        "defaulted_loans": loan_node.default,
        "on_schedule_loans": loan_node.on_schedule
    }

}

walker get_dashboard_data{
    

    can fetch_data with `root entry{
        visit[-->(`?User)];
    }

    can calculate_data with User entry{
        current_month = get_current_month();
        total_loans = 0;
        category_breakdown = [];

        for cat in [-->(`?Category)]{
            cat_total = 0.0;
        }

        #filter month by moth, current
        for intr in cat [-->(`?Articles)]{
            if intr.date.startwith(current_month){
                cat_articles.append({
                    "topic": intr.topic
                });
            };
        };
    

        category_breakdown[cat.name] =cat.total;
        total_articles += cat_total;

        for loan in [-->(`?Loans)]{ #loans disbursed in current month
            if loan.disbursment_date.startwith(current_month){
                total_loans += 1;
            };
        };

        for loan in [-->(`?Loans)]{#defaulted loans
            if loan.arrears > 0 {
                defaulted_loans += 1;
            };

        }

        for task in [-->(`?todos)]{
            if task.completed == false {
                pending_tasks += 1;
            };
        };

        report{
            "message": "Dashboard data fetched",
            "total_articles": total_articles,
            "category_breakdown": category_breakdown,
            "total_loans": total_loans,
            "defaulted_loans": defaulted_loans,
            "pending_tasks": pending_tasks
        }
    };

}