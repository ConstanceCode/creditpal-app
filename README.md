
# CreditPal App 

CreditPal is an intelligent, graph-powered credit and news analysis platform built using **Jaclang (Jaseci)** and a modern **Node.js + Vite + React** frontend stack. The project is designed as a learning-through-building system that combines graph programming, agents, and application logic to explore personalized information systems.

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

* **Jaclang (Jaseci)** – graph programming language
* **Jaseci Runtime** – execution engine
* Walkers, nodes, edges, and abilities

### Frontend

* **Node.js**
* **Vite**
* **React**

### Tooling

* Git & GitHub (SSH-based auth)
* Python virtual environment (`.venv`)
* VS Code

---

## Project Structure


creditpal-app/
├── .gitignore
├── .babelrc
├── README.md
├── package.json
├── package-lock.json
├── vite.config.js
├── .env.sample
│
├── app.jac                 # Main Jac application
├── app.cl.jac              # Application logic
├── news.app.jac            # News / content logic
├── todo.app.jac            # Example feature app
├── utils.jac               # Shared helpers
├── main2.jac               # Experiments / entry points
│
├── src/                    # Frontend source
│   ├── main.js
│   ├── app.js
│   └── client_runtime.js
│
├── build/                  # Build artifacts
├── dist/                   # Frontend output
└── .venv/                  # Python virtual environment (ignored)
```

---

##  Setup Instructions

### Clone the Repository

```bash
git clone git@github.com:ConstanceCode/creditpal-app.git
cd creditpal-app
```

### Backend Setup (Jaclang)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install jaseci jaseci-serv
```

## Running Jac Code

make sure node modules are installed:
```bash
npm install
```

To run your Jac code, use the Jac CLI:

```bash
jac serve app.jac
```

---

### Frontend Setup

```bash
npm install
npm run dev
```

---

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

* Credibility scoring logic
* Personalization rules
* Graph visualization
* Better frontend integration
* Documentation & tests

---

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



