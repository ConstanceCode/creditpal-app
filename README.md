
# CreditPal App 

CreditPal is an intelligent, graph-powered credit and news analysis platform built using **Jaclang (Jaseci)** and Streamlit frontend stack. The project is designed as a learning-through-building system that combines graph programming, agents, and application logic to explore personalized information systems.

---

##  Project Goals

* Build a **graph-based backend** using Jaclang
* Model **users, topics, sources, and content** as nodes and edges
* Use **walkers and agents** for automation and analysis
* Explore **personalized content delivery and credibility scoring**
* Integrate a modern frontend for interaction and visualization

This project is both a **practical application** and a **learning project** focused on modern backend architectures.

---

##  Tech Stack

### Backend
- Jaclang (Jaseci)
- Jaseci Runtime
- Walkers, nodes, and semantic abilities
- Python-based semantic execution


### Frontend

- Streamlit **(official UI)**

### Tooling

* Python 3.10+
* Git & GitHub (SSH-based auth)
* Python virtual environment (`.venv`)
* VS Code

---

## Project Structure

creditpal/
├── README.md
│
├── app.jac                    # Core Jac app (walkers + API)
├── app.impl.jac               # Semantic implementations
├── app.session                # Runtime session state
├── app.session.users.json     # Session user storage
│
├── tools/
│   ├── news_fetchers.jac      # News fetching walkers
│   └── news_fetchers_py.py    # Python helpers (API calls)
│
├── ui.py                      # Streamlit frontend (MAIN UI)
│
├── src/                       # Legacy frontend (not active)
│   ├── app.js
│   ├── main.js
│   └── client_runtime.js
│
├── build/                     # Legacy build artifacts
├── dist/                      # Legacy build output
│
├── assets/                    # Images / static assets
│
├── package.json
├── package-lock.json
├── vite.config.js
│
└── node_modules/              # Ignored in Git
```

##  Setup Instructions

### Clone the Repository

```
git clone git@github.com:ConstanceCode/creditpal-app.git
cd creditpal-app
```

## Backend Setup (Jaclang)

python3 -m venv .venv
source .venv/bin/activate
pip install jaseci jaseci-serv streamlit requests
```

## Running Jac backend
jac serve app.jac

### Running Streamlit Frontend
Streamlit run ui.py

## Key Concepts Used

* **Nodes** → users, topics, sources, content
* **Edges** → relationships (interest, credibility, interaction)
* **Walkers** → automation and traversal logic
* **Abilities** → reusable behaviors
* **Sessions** → user interaction handling

---

## Project Status

 **Active Development / Learning Project**

Planned improvements:

* Better article normalization
* Topic-based filtering on backend
* User relevance scoring
* Caching & rate limiting
* Test coverage
* Documentation for walkers

## Contributing

This is a personal learning project, but suggestions and improvements are welcome.

1. Fork the repo
2. Create a feature branch
3. Commit changes
4. Open a pull request

---

##  License

This project is for educational purposes.

---

 Author: Constance Mukenyi
GitHub: [@ConstanceCode](https://github.com/ConstanceCode)



