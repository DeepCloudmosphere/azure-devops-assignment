import os
from flask import Flask, jsonify, request

# ---- OpenTelemetry / Azure Monitor setup ----
conn_str = os.getenv("APPINSIGHTS_CONNECTION_STRING", None)
if conn_str:
    from opentelemetry import trace
    from opentelemetry.sdk.resources import Resource
    from opentelemetry.sdk.trace import TracerProvider
    from opentelemetry.sdk.trace.export import BatchSpanProcessor
    from opentelemetry.exporter.azuremonitor import AzureMonitorSpanExporter
    from opentelemetry.instrumentation.flask import FlaskInstrumentor
    from opentelemetry.instrumentation.requests import RequestsInstrumentor

    resource = Resource.create({"service.name": "user-service"})
    provider = TracerProvider(resource=resource)
    trace.set_tracer_provider(provider)
    exporter = AzureMonitorSpanExporter(connection_string=conn_str)
    provider.add_span_processor(BatchSpanProcessor(exporter))
    FlaskInstrumentor().instrument()
    RequestsInstrumentor().instrument()

    
app = Flask(__name__)

USERS = {
    1: {"id":1, "name":"Alice"},
    2: {"id":2, "name":"Bob"}
}

@app.route("/health")
def health():
    return jsonify(status="ok"), 200

@app.route("/users")
def list_users():
    return jsonify(list(USERS.values()))

@app.route("/users/<int:user_id>")
def get_user(user_id):
    user = USERS.get(user_id)
    if user:
        return jsonify(user)
    return jsonify({"error":"not found"}), 404

@app.route("/users", methods=["POST"])
def create_user():
    data = request.get_json() or {}
    new_id = max(USERS.keys()) + 1
    user = {"id": new_id, "name": data.get("name","Unknown")}
    USERS[new_id] = user
    return jsonify(user), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)