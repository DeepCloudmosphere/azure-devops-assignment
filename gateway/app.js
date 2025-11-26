// gateway/app.js
const express = require('express');
const fetch = require('node-fetch');

const app = express();
app.use(express.json());

function userSvcBase() {
  return process.env.USER_SVC || "http://user-service:5000";
}
function orderSvcBase() {
  return process.env.ORDER_SVC || "http://order-service:5001";
}

app.get("/health", (req, res) => res.json({ status: "ok" }));

app.get("/users", async (req, res) => {
  try {
    const r = await fetch(`${userSvcBase()}/users`);
    const json = await r.json();
    res.json(json);
  } catch (err) {
    console.error("Error fetching users:", err.message);
    res.status(502).json({ error: "upstream error" });
  }
});

app.get("/orders", async (req, res) => {
  try {
    const r = await fetch(`${orderSvcBase()}/orders`);
    const json = await r.json();
    res.json(json);
  } catch (err) {
    console.error("Error fetching orders:", err.message);
    res.status(502).json({ error: "upstream error" });
  }
});

// Only start listening when run directly
if (require.main === module) {
  const port = process.env.PORT || 3000;
  app.listen(port, () => console.log(`Gateway listening on ${port}`));
}

module.exports = app;
