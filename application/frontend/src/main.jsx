import React, { useEffect, useState } from "react";
import { createRoot } from "react-dom/client";
import "./style.css";

function App() {
  const [orders, setOrders] = useState([]);
  const [customerName, setCustomerName] = useState("");
  const [itemName, setItemName] = useState("");
  const [quantity, setQuantity] = useState(1);
  const [message, setMessage] = useState("");

  async function loadOrders() {
    try {
      const response = await fetch("/api/orders");

      if (!response.ok) {
        throw new Error("Unable to load orders");
      }

      setOrders(await response.json());
    } catch (error) {
      setMessage("Unable to load orders");
    }
  }

  useEffect(() => {
    loadOrders();
  }, []);

  async function createOrder(event) {
    event.preventDefault();
    setMessage("");

    try {
      const response = await fetch("/api/orders", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          customerName,
          itemName,
          quantity: Number(quantity)
        })
      });

      if (!response.ok) {
        throw new Error("Unable to create order");
      }

      setCustomerName("");
      setItemName("");
      setQuantity(1);
      setMessage("Order created successfully");

      await loadOrders();
    } catch (error) {
      setMessage("Unable to create order");
    }
  }

  return (
    <main>
      <section className="header">
        <h1>OrderPulse</h1>
        <p>Observability Demo Application</p>
      </section>

      <section className="card">
        <h2>Create Order</h2>

        <form onSubmit={createOrder}>
          <input
            placeholder="Customer name"
            value={customerName}
            onChange={(event) => setCustomerName(event.target.value)}
            required
          />

          <input
            placeholder="Item name"
            value={itemName}
            onChange={(event) => setItemName(event.target.value)}
            required
          />

          <input
            type="number"
            min="1"
            value={quantity}
            onChange={(event) => setQuantity(event.target.value)}
            required
          />

          <button type="submit">Create Order</button>
        </form>

        {message && <p className="message">{message}</p>}
      </section>

      <section className="card">
        <h2>Recent Orders</h2>

        {orders.length === 0 ? (
          <p>No orders yet.</p>
        ) : (
          <table>
            <thead>
              <tr>
                <th>ID</th>
                <th>Customer</th>
                <th>Item</th>
                <th>Qty</th>
                <th>Status</th>
              </tr>
            </thead>

            <tbody>
              {orders.map((order) => (
                <tr key={order.id}>
                  <td>{order.id}</td>
                  <td>{order.customer_name}</td>
                  <td>{order.item_name}</td>
                  <td>{order.quantity}</td>
                  <td>{order.status}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
    </main>
  );
}

createRoot(document.getElementById("root")).render(<App />);
