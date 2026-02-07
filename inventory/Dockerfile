FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY inventory.py .

EXPOSE 8082

CMD ["python", "inventory.py"]
