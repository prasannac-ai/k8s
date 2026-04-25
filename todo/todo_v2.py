import httpx
from fastapi import FastAPI, APIRouter
from pydantic import BaseModel
from typing import List

# ── App ──────────────────────────────────────────────────────────────
app = FastAPI(
    title="Todo API — Versioned",
    description="v1: Basic CRUD  |  v2: AI-powered task expansion via Gemma 4 E2B (Ollama)",
    version="2.0.0",
)

# ── Ollama config ────────────────────────────────────────────────────
OLLAMA_URL = "http://host.docker.internal:11434/api/generate"
MODEL_NAME = "gemma4:e2b"  # Gemma 4 E2B tag in Ollama

# ── Models ───────────────────────────────────────────────────────────
class TodoItem(BaseModel):
    id: int
    title: str
    completed: bool = False

class TodoItemV2(BaseModel):
    id: int
    title: str
    completed: bool = False
    subtasks: List[str] = []

# ── Shared in-memory store ──────────────────────────────────────────
todos_v1 = [
    TodoItem(id=1, title="Buy groceries", completed=False),
    TodoItem(id=2, title="Learn FastAPI", completed=True),
    TodoItem(id=3, title="Walk the dog", completed=False),
]

todos_v2: List[TodoItemV2] = []

# =====================================================================
#  V1 — Basic CRUD (unchanged from todo.py)
# =====================================================================
v1 = APIRouter(prefix="/api/v1", tags=["v1 – Basic"])

@v1.get("/")
def v1_root():
    return {"message": "Welcome to the Todo API v1"}

@v1.get("/todos", response_model=List[TodoItem])
def v1_get_todos():
    return todos_v1

@v1.post("/todos", response_model=TodoItem)
def v1_create_todo(todo: TodoItem):
    todos_v1.append(todo)
    return todo

@v1.get("/todos/{todo_id}", response_model=TodoItem)
def v1_get_todo(todo_id: int):
    for todo in todos_v1:
        if todo.id == todo_id:
            return todo
    return {"error": "Todo not found"}

# =====================================================================
#  V2 — AI-Powered (Gemma 4 E2B via Ollama)
# =====================================================================
v2 = APIRouter(prefix="/api/v2", tags=["v2 – AI Powered"])

async def expand_with_gemma(task_title: str) -> List[str]:
    """Call local Ollama to break a task into sub-steps using Gemma 4 E2B."""
    prompt = (
        f"You are a DevOps assistant. The user wants to: {task_title}.\n"
        "Provide a concrete 3-step technical checklist to achieve this "
        "in a Kubernetes environment.\n"
        "Output ONLY the bullet points, no extra text."
    )
    payload = {"model": MODEL_NAME, "prompt": prompt, "stream": False}

    try:
        async with httpx.AsyncClient() as client:
            resp = await client.post(OLLAMA_URL, json=payload, timeout=30.0)
            if resp.status_code == 200:
                raw = resp.json().get("response", "")
                lines = [
                    line.strip("- ").strip("* ").strip()
                    for line in raw.strip().split("\n")
                    if line.strip()
                ]
                return lines[:5]
    except Exception as e:
        print(f"Ollama error: {e}")
        return ["Error: Could not reach Ollama"]
    return []

@v2.get("/")
async def v2_root():
    return {
        "message": "Todo API v2 — powered by Gemma 4 E2B",
        "model": MODEL_NAME,
    }

@v2.get("/todos", response_model=List[TodoItemV2])
async def v2_get_todos():
    return todos_v2

@v2.post("/todos", response_model=TodoItemV2)
async def v2_create_todo(todo: TodoItemV2):
    """
    Create a todo.  
    Include **[AI]** anywhere in the title to auto-generate subtasks  
    using Gemma 4 E2B.

    Example: {"id": 1, "title": "[AI] Setup HPA for todo-app"}
    """
    if "[AI]" in todo.title:
        clean = todo.title.replace("[AI]", "").strip()
        print(f"🤖 Gemma 4 expanding: {clean}")
        todo.subtasks = await expand_with_gemma(clean)
    todos_v2.append(todo)
    return todo

@v2.get("/todos/{todo_id}", response_model=TodoItemV2)
async def v2_get_todo(todo_id: int):
    for todo in todos_v2:
        if todo.id == todo_id:
            return todo
    return {"error": "Todo not found"}

# ── Register routers ────────────────────────────────────────────────
app.include_router(v1)
app.include_router(v2)

@app.get("/")
async def root():
    return {
        "api": "Todo API",
        "versions": {
            "v1": "/api/v1  — Basic CRUD",
            "v2": "/api/v2  — AI-powered (Gemma 4 E2B)",
        },
        "docs": "/docs",
    }

# ── Run directly ────────────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
