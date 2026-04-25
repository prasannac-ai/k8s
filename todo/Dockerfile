
FROM python:3.11.9-slim


WORKDIR /app


COPY requirements.txt .


RUN pip install -r requirements.txt

COPY . .


EXPOSE 8000

# Command to run the application
CMD ["uvicorn", "todo_v2:app", "--host", "0.0.0.0", "--port", "8000"]
