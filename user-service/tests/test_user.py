from app import app
import json

def test_health():
    client = app.test_client()
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json["status"] == "ok"

def test_create_and_get_user():
    client = app.test_client()
    r = client.post("/users", json={"name":"Charlie"})
    assert r.status_code == 201
    uid = r.json["id"]
    r2 = client.get(f"/users/{uid}")
    assert r2.status_code == 200
    assert r2.json["name"] == "Charlie"