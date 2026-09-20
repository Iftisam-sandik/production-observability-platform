const client = require("@prometheus-io/client");

client.collectDefaultMetrics();

const httpRequestsTotal = new client.Counter({
  name: "http_requests_total",
  help: "Total number of HTTP requests",
  labelNames: ["method", "route", "status_code"]
});

const httpRequestDurationSeconds = new client.Histogram({
  name: "http_request_duration_seconds",
  help: "HTTP request duration in seconds",
  labelNames: ["method", "route", "status_code"],
  buckets: [0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5]
});

const httpRequestsInProgress = new client.Gauge({
  name: "http_requests_in_progress",
  help: "Number of HTTP requests currently being processed"
});

const ordersCreatedTotal = new client.Counter({
  name: "orders_created_total",
  help: "Total number of successfully created orders"
});

const loginFailuresTotal = new client.Counter({
  name: "login_failures_total",
  help: "Total number of failed login attempts"
});

const databaseQueryFailuresTotal = new client.Counter({
  name: "database_query_failures_total",
  help: "Total number of failed database queries"
});

function metricsMiddleware(req, res, next) {
  if (req.path === "/metrics") {
    return next();
  }

  httpRequestsInProgress.inc();

  const start = process.hrtime.bigint();
  let recorded = false;

  function record() {
    if (recorded) return;
    recorded = true;

    const durationSeconds =
      Number(process.hrtime.bigint() - start) / 1e9;

    const labels = {
      method: req.method,
      route: req.route?.path || "unmatched",
      status_code: String(res.statusCode)
    };

    httpRequestsTotal.inc(labels);
    httpRequestDurationSeconds.observe(labels, durationSeconds);
    httpRequestsInProgress.dec();
  }

  res.on("finish", record);
  res.on("close", record);

  next();
}

module.exports = {
  client,
  metricsMiddleware,
  ordersCreatedTotal,
  loginFailuresTotal,
  databaseQueryFailuresTotal
};
