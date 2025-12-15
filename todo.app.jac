cl {}

node todos{
    has tasks: list[str];
    has reminders: bool = true;
    has priority_levels: map[str, int];
    has state: dict[];
}

node task(todos){
    has description: str;
    has priority: int;
    has completed: bool = false;

    can mark_complete with 
}

walker initialize_todo_app() -> none {
    todo_node = create node todos;
    todo_node.tasks = [];
    todo_node.reminders = alert();
    todo_node.priority_levels = {"high": 3, "medium": 2, "low": 1};
    todo_node.state = [];
}
walker add_task(task: str, priority: int) -> none {
    todo_node = get_node_by_type(todos)[0];
    todo_node.tasks.append(task);
    todo_node.state.append({"task": task, "priority": priority, "completed": false});

    can create_task with task entry{

    }
}