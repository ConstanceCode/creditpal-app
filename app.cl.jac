# Pages
import from react {useState, useEffect}
import from react_router {initRouter, navigate}
import from `@jac-client/auth' {jacLogin, jacRegister, jacIsLoggedIn, jacLogout}
import from lodash {*as _}
import from antd {Button, Card, Input, Form, Select, DatePicker, Alert}
include '@jac-client/utils'



 def NavigationBar() -> any {
    return (
        #<nav>
            #<ul>
                #<li><a href="/">Home</a></li>
                #<li><a href="/news">News</a></li>
                #<li><a href="/todo">To do tasks</a></li>
                #<li><a href="/login">Login</a></li>
            #</ul>
        #</nav>
    );
 }

def LoginForm() -> any {
        async def handleLogin(e: any) -> None {
            e.preventDefault();
            username = document.getElementById("username").value;
            password = document.getElementById("password").value;

            success = await jacLogin(username, password);

            if success {
                navigate("/dashboard");
            } else {
                alert("Login failed");
            }
        }

        return <form onSubmit={handleLogin}>
            <input id="username" type="text" placeholder="Username" />
            <input id="password" type="password" placeholder="Password" />
            <button type="submit">Login</button>
        </form>;
        <p>Lack an account? 
            <button onClick = {RegisterForm}> Register </button>
        </p>;
}

def RegisterForm() -> any {
        async def handleRegister(e: any) -> None {
            e.preventDefault();
            username = document.getElementById("username").value;
            password = document.getElementById("password").value;

            success = await jacRegister(username, password);

            if success {
                navigate("/login");
            } else {
                alert("Registration failed");
            }
        }

        return <form onSubmit={handleRegister}>
            <input id="username" type="text" placeholder="Username" />
            <input id="password" type="password" placeholder="Password" />
            <button type="submit">Register</button>
        </form>;
        <p>Already have an account? 
            <button onClick={LoginForm}>Login here</button>
        </p>;
}

def Dashboard() -> any {
    if not jacIsLoggedIn() {
        navigate("/login");
        return null;
    }
    return <div>
        <h1>Welcome to your Dashboard</h1>
        <Header />
    </div>;
}

def Header() -> any {
        def handleLogout() -> None {
            jacLogout();
            navigate("/login");
        }

        return <header>
            <button onClick={handleLogout}>Logout</button>
        </header>;
}

def TopicInput() -> any {
    return (
        <div>
            <label htmlFor="topic">Enter topics you are interested in:</label>
            <input type="text" id="topic" name="topic" placeholder="Type your topic here..." />
        </div>
    );
}

def app() -> any {
    
    return (
        routes = [
            {"path": "/login", "component": lambda -> any { return LoginPage(); }, "guard": None},
            {"path": "/dashboard", "component": lambda -> any { return Dashboard(); }, "guard": jacIsLoggedIn}
        ];

        router = initRouter(routes, "/login")
    );

     let [topics, setTopics] = useState([]);
        <div>
            <TopicInput />
        </div>

}
