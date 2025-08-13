FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir -r requirements.txt \
    fastapi uvicorn[standard] scikit-learn pandas numpy joblib aiofiles

COPY . /app

CMD ["uvicorn", "takeshi_y.takeshi:app", "--host", "0.0.0.0", "--port", "8080"]

