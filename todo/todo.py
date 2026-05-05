from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI(title="Todo API")

class TodoItem(BaseModel):
    id: int
    title: str
    completed: bool = False

# In-memory storage for simplicity
todos = [
    TodoItem(id=1, title="Buy groceries", completed=False),
    TodoItem(id=2, title="Learn FastAPI", completed=True),
    TodoItem(id=3, title="Walk the dog", completed=False)
]

@app.get("/")
def read_root():
    return {"message": "Welcome to the Todo API"}

@app.get("/todos", response_model=List[TodoItem])
def get_todos():
    return todos

@app.post("/todos", response_model=TodoItem)
def create_todo(todo: TodoItem):
    todos.append(todo)
    return todo

@app.get("/todos/{todo_id}", response_model=TodoItem)
def get_todo(todo_id: int):
    for todo in todos:
        if todo.id == todo_id:
            return todo
    return {"error": "Todo not found"}