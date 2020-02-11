// Set your secret key: remember to change this to your live secret key in production
// See your keys here: https://dashboard.stripe.com/account/apikeys
var stripe = require("stripe")("sk_test_FCa6Z3AusbsdhyV93B4CdWnV");

// Token is created using Stripe.js or Checkout!
// Get the payment token submitted by the form:
var token = request.body.stripeToken; // Using Express

// Create a Customer:
stripe.customers.create({
  email: "paying.user@example.com",
  source: token,
}).then(function(customer) {
  // YOUR CODE: Save the customer ID and other info in a database for later.
  return stripe.charges.create({
    amount: 1000,
    currency: "usd",
    customer: customer.id,
  });
}).then(function(charge) {
  // Use and save the charge info.
});

// YOUR CODE (LATER): When it's time to charge the customer again, retrieve the customer ID.
stripe.charges.create({
  amount: 1500, // $15.00 this time
  currency: "usd",
  customer: customerId,
});
