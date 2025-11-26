// gateway/tests/gateway.test.js

// set test-specific env BEFORE requiring the app
process.env.USER_SVC = 'http://mock-user';
process.env.ORDER_SVC = 'http://mock-order';

const request = require('supertest');
const nock = require('nock');
const app = require('../app');

describe('Gateway', () => {
  afterEach(() => {
    nock.cleanAll();
  });

  test('GET /health returns ok', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: 'ok' });
  });

  test('GET /users proxies to user-service and returns list', async () => {
    const users = [{ id: 1, name: 'Alice' }];
    nock('http://mock-user').get('/users').reply(200, users);

    const res = await request(app).get('/users');
    expect(res.status).toBe(200);
    expect(res.body).toEqual(users);
  });

  test('GET /orders proxies to order-service and returns list', async () => {
    const orders = [{ id: 1, user_id: 1, amount: 100 }];
    nock('http://mock-order').get('/orders').reply(200, orders);

    const res = await request(app).get('/orders');
    expect(res.status).toBe(200);
    expect(res.body).toEqual(orders);
  });

  test('proxied upstream error returns 502', async () => {
    nock('http://bad-user').get('/users').replyWithError('oh no');

    // override env for this scenario
    process.env.USER_SVC = 'http://bad-user';
    const res = await request(app).get('/users');
    expect(res.status).toBe(502);
    expect(res.body).toHaveProperty('error');
  });
});
