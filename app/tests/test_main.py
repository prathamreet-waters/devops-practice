import pytest
from app.src.main import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_root_endpoint(client):
    response = client.get('/')
    assert response.status_code == 200
    data = response.get_json()
    assert data['service'] == 'devops-practice-api'
    assert data['status'] == 'online'

def test_health_endpoint(client):
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'healthy'
    assert 'uptime_seconds' in data

def test_ready_endpoint(client):
    response = client.get('/ready')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'ready'

def test_info_endpoint(client):
    response = client.get('/api/v1/info')
    assert response.status_code == 200
    data = response.get_json()
    assert data['app_name'] == 'DevOps Practice Service'

def test_metrics_endpoint(client):
    response = client.get('/metrics')
    assert response.status_code == 200
    assert b'http_requests_total' in response.data
