const express = require("express");
const mysql = require("mysql2/promise");

const {
  client,
  metricsMiddleware,
  ordersCreatedTotal,
  loginFailuresTotal,
  databaseQueryFailuresTotal
} = require("./metrics");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(metricsMiddleware);

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10
});

app.get("/metrics", async (req, res) => {
  try {
    res.set("Content-Type", client.register.contentType);
    res.end(await client.register.metrics());
  } catch (error) {
    console.error("Failed to generate metrics:", error.message);
    res.status(500).end();
  }
});

app.get("/api/health", (req, res) => {
  res.status(200).json({
    status: "ok",
    service: "orderpulse-api"
  });
});

app.get("/api/db-health", async (req, res) => {
  try {
    await pool.query("SELECT 1");

    res.status(200).json({
      status: "ok",
      database: "reachable"
    });
  } catch (error) {
    databaseQueryFailuresTotal.inc();

    console.error("Database health check failed:", error.message);

    res.status(503).json({
      status: "error",
      database: "unreachable"
    });
  }
});

app.get("/api/orders", async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        id,
        customer_name,
        item_name,
        quantity,
        status,
        created_at
      FROM orders
      ORDER BY id DESC
      LIMIT 50
    `);

    res.json(rows);
  } catch (error) {
    databaseQueryFailuresTotal.inc();

    console.error("Failed to fetch orders:", error.message);

    res.status(500).json({
      error: "Unable to fetch orders"
    });
  }
});

app.post("/api/orders", async (req, res) => {
  const { customerName, itemName, quantity } = req.body;

  if (!customerName || !itemName || !quantity || quantity < 1) {
    return res.status(400).json({
      error: "customerName, itemName and a valid quantity are required"
    });
  }

  try {
    const [result] = await pool.execute(
      `INSERT INTO orders
       (customer_name, item_name, quantity, status)
       VALUES (?, ?, ?, ?)`,
      [customerName, itemName, quantity, "created"]
    );

    ordersCreatedTotal.inc();

    res.status(201).json({
      id: result.insertId,
      customerName,
      itemName,
      quantity,
      status: "created"
    });
  } catch (error) {
    databaseQueryFailuresTotal.inc();

    console.error("Failed to create order:", error.message);

    res.status(500).json({
      error: "Unable to create order"
    });
  }
});

app.post("/api/login", (req, res) => {
  const { username, password } = req.body;

  if (
    username !== process.env.DEMO_USERNAME ||
    password !== process.env.DEMO_PASSWORD
  ) {
    loginFailuresTotal.inc();

    return res.status(401).json({
      error: "Invalid credentials"
    });
  }

  res.status(200).json({
    status: "ok"
  });
});

app.get("/api/test/error", (req, res) => {
  console.error("Controlled test error triggered");

  res.status(500).json({
    error: "Controlled test error"
  });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`OrderPulse API listening on port ${PORT}`);
});
