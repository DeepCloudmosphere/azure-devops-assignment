from app import app

def test_health():
    client = app.test_client()
    r = client.get("/health")
    assert r.status_code == 200

def test_create_order():
    client = app.test_client()
    r = client.post("/orders", json={"user_id":1,"amount":50})
    assert r.status_code == 201
    assert "id" in r.json
