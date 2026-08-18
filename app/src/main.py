import os
import time
import logging
from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s'
)
logger = logging.getLogger("devops-app")

app = Flask(__name__)

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP Requests', ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'HTTP Request Duration', ['endpoint'])

START_TIME = time.time()

@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    resp_time = time.time() - getattr(request, 'start_time', time.time())
    endpoint = request.path
    method = request.method
    status = str(response.status_code)
    
    REQUEST_COUNT.labels(method=method, endpoint=endpoint, status=status).inc()
    REQUEST_LATENCY.labels(endpoint=endpoint).observe(resp_time)
    
    return response

@app.route("/", methods=["GET"])
def root():
    return jsonify({
        "service": "devops-practice-api",
        "status": "online",
        "version": os.getenv("APP_VERSION", "1.0.0"),
        "environment": os.getenv("APP_ENV", "development")
    }), 200

@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "healthy",
        "uptime_seconds": round(time.time() - START_TIME, 2),
        "timestamp": int(time.time())
    }), 200

@app.route("/ready", methods=["GET"])
def ready():
    return jsonify({
        "status": "ready",
        "database": "connected",
        "cache": "connected"
    }), 200

@app.route("/api/v1/info", methods=["GET"])
def info():
    return jsonify({
        "app_name": "DevOps Practice Service",
        "hostname": os.getenv("HOSTNAME", "localhost"),
        "python_version": os.getenv("PYTHON_VERSION", "3.11"),
        "port": int(os.getenv("PORT", "8000"))
    }), 200

@app.route("/metrics", methods=["GET"])
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == "__main__":
    port = int(os.getenv("PORT", "8000"))
    host = os.getenv("FLASK_HOST", "127.0.0.1")
    logger.info("Starting DevOps Practice Service on %s:%d", host, port)
    app.run(host=host, port=port)
