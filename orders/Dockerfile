FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY orders.py .

EXPOSE 8081

CMD ["python", "orders.py"]
