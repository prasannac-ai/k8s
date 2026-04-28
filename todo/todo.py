from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI(title="Todo API")


@app.get("/")
def read_root():
    return {"message": "Welcome to the Todo API"}
