const express = require("express");
const Stripe = require("stripe");
const bodyParser = require("body-parser");

const app = express();
const stripe = Stripe("sk_test_51QnI64HHgxdC6vSSHLuhGELgvQ6pZZnP8zrD0aslPwvxEILsskgXXTvQkS9AnO0c8oPkvQeE1vO77DHFFnzz7uQe004vvBA0Pg");

app.use(bodyParser.json());


app.post("/create-customer", async (req, res) => {
  try {
    const customer = await stripe.customers.create({
      email: req.body.email,
      name: req.body.name,
    });

    res.send({ customerId: customer.id });
  } catch (error) {
    res.status(500).send({ error: error.message });
  }
});

app.post("/attach-payment-method", async (req, res) => {
  try {
    const { paymentMethodId, customerId } = req.body;

    // Associa il metodo di pagamento al cliente
    await stripe.paymentMethods.attach(paymentMethodId, { customer: customerId });

    // Aggiorna il metodo di pagamento predefinito per il cliente
    await stripe.customers.update(customerId, {
      invoice_settings: { default_payment_method: paymentMethodId },
    });

    res.send({ success: true });
  } catch (error) {
    res.status(500).send({ error: error.message });
  }
});

app.post("/create-payment-intent", async (req, res) => {
  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: req.body.amount, // in cents
      currency: "usd",
      payment_method_types: ["card"],
    });

    res.send({
      clientSecret: paymentIntent.client_secret,
    });
  } catch (error) {
    res.status(500).send({ error: error.message });
  }
});

app.post("/get-payment-methods", async (req, res) => {
  try {
    const { customerId } = req.body; // L'ID del cliente viene inviato dal client

    const paymentMethods = await stripe.paymentMethods.list({
      customer: customerId,
      type: "card", // Recupera solo metodi di pagamento di tipo "card"
    });

    res.send(paymentMethods.data); // Restituisce un array di metodi di pagamento
  } catch (error) {
    res.status(500).send({ error: error.message });
  }
});

app.post("/create-customer", async (req, res) => {
  try {
    const customer = await stripe.customers.create({
      email: req.body.email,
      name: req.body.name,
    });

    res.send({ customerId: customer.id });
  } catch (error) {
    res.status(500).send({ error: error.message });
  }
});

app.listen(3000, () => console.log("Server running on port 3000"));