from flask import Flask
import requests

app = Flask(__name__)   # ✅ THIS WAS MISSING

@app.route("/orders")
def orders():
    inv = requests.get("http://inventory:8082/inventory").json()
    return {
        "orders": 5,
        "inventory": inv
    }

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8081)

