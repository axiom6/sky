
$      = require('jquery')
Data   = require('js/res/Data')
stripe = require("stripe")(Data.stripeTestKey) # Using browser

class StripeNS

  module.exports = StripeNS

  constructor:( @stream, @store, @room, @cust, @res ) ->

  doCharge:(  request, totals, desc ) =>
    token  = request.body.stripeToken
    charge = stripe.charges.create( { amount:totals, currency:"usd", description:desc, source:token }, @onCharge )

  onCharge:( error, charge ) =>
    if error
      Util.error( "StripeNS.onCharge", error  )
    else
      Util.log(   "StripeNS.onCharge", charge )
    return