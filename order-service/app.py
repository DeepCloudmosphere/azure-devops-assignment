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

    resource = Resource.create({"service.name": "order-service"})
    provider = TracerProvider(resource=resource)
    trace.set_tracer_provider(provider)
    exporter = AzureMonitorSpanExporter(connection_string=conn_str)
    provider.add_span_processor(BatchSpanProcessor(exporter))
    FlaskInstrumentor().instrument()
    RequestsInstrumentor().instrument()

app = Flask(__name__)

ORDERS = {
    1: {"id":1, "user_id":1, "amount":100},
    2: {"id":2, "user_id":2, "amount":200}
}

@app.route("/health")
def health():
    return jsonify(status="ok"), 200

@app.route("/orders")
def list_orders():
    return jsonify(list(ORDERS.values()))

@app.route("/orders/<int:order_id>")
def get_order(order_id):
    order = ORDERS.get(order_id)
    if order:
        return jsonify(order)
    return jsonify({"error":"not found"}), 404

@app.route("/orders", methods=["POST"])
def create_order():
    data = request.get_json() or {}
    new_id = max(ORDERS.keys()) + 1
    order = {
        "id": new_id,
        "user_id": data.get("user_id"),
        "amount": data.get("amount", 0)
    }
    ORDERS[new_id] = order
    return jsonify(order), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
