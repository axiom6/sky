
$          = require('jquery')
Data       = require('js/res/Data')
stripeNode = require("stripe")(Data.stripeTestKey) # Using browser

class StripeCC

  module.exports = StripeCC

  constructor:( @stream, @store, @room, @cust, @res ) ->
    @stripeClient = Stripe( Data.stripeTestPub )
    @elements     = @stripeClient.elements()
    @token        = ""
    @totals       = 800
    @desc         = "First Run"

  ready:() ->
    $("#StripeCC").append( @checkOutForm() )
    return

  readyElements:() ->
    $("#StripeCC").append( @elementsForm() )
    @card = @elements.create('card', { style:@elementsStyle() } )
    @card.mount('#card-element')
    @form = document.getElementById('payment-form')
    @card.addEventListener( 'change', (event) => @onCardError(  event ) )
    @form.addEventListener( 'submit', (event) => @onFormSubmit( event ) )
    return

  elementsForm:() ->
    # action="Javascript:#{@doCharge()}"
    """<form action="index.html#Confirm" method="post" id="payment-form">
        <div class="form-row">
          <label for="card-element">Credit or debit card</label>
          <div id="card-element"></div>
          <div id="card-errors"></div>
        </div>
        <button>Submit Payment</button>
      </form>"""

  checkOutForm:() ->
    """<form action=Javascript:#{@doAction()}" method="POST">
        <script
        src="https://checkout.stripe.com/checkout.js" class="stripe-button"
        data-key="pk_test_VmF7xSInW8JHrcUga6yRmjqq"
        data-amount="999"
        data-name="SkylineSue"
        data-description="Widget"
        data-image="https://stripe.com/img/documentation/checkout/marketplace.png"
        data-locale="auto">
        </script>
    </form>"""

  elementsStyle:() ->
    { base: { fontSize:'16px', lineHeight:'24px' } }

  onCardError:( event ) =>
    displayError = document.getElementById('card-errors')
    if event.error
      displayError.textContent = event.error.message
    else
      displayError.textContent = ''
    return

  onFormSubmit:( event ) =>
    event.preventDefault()
    @stripeClient.createToken(@card).then( (result) =>
      if result.error
        errorElement = document.getElementById('card-errors') # Inform the user if there was an error
        errorElement.textContent = result.error.message
      else
        @token = result.token
        @tokenHandler( result.token ) ) # Send the token to your server
    return

  tokenHandler:( token ) =>
    # Insert the token ID into the form so it gets submitted to the server
    hiddenInput = document.createElement('input')
    hiddenInput.setAttribute('type', 'hidden' )
    hiddenInput.setAttribute('name', 'stripeToken' )
    hiddenInput.setAttribute('value', token.id )
    @form.appendChild( hiddenInput )
    @form.submit()
    return

  doCharge:() =>
    stripeNode.charges.create( { amount:@totals, currency:"usd", description:@desc, source:@token }, @onCharge )
    return

  onCharge:( error, charge ) =>
    if error
      Util.error( "StripeCC.onCharge", error  )
    else
      Util.log(   "StripeCC.onCharge", charge )
    return

  doAction:() =>
    Util.log( "StripeCC.doAction", 'called too soon' )
    return

