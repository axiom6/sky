
import Credit from './Credit.js'
import Util   from './Util.js'
import Data   from './Data.js'
#mport UI     from './UI'

class Pay

  constructor:( @stream, @store, @res, @home=null ) ->
    @credit = new Credit()
    @uri    = "https://api.stripe.com/v1/"
    @subscribe()
    $.ajaxSetup( { headers: { "Authorization": Data.stripeCurlKey } } )
    @resv    = null
    @amount  = 0
    @purpose = 'PayInFull' # 'Deposit' 'PayBalance'
    @testing = false
    @errored = false
    #doPut = (onPut) -> Util.log('Res.subscribeToDays onPut', onPut )
    #@res.onDays( doPut )

  initPayResv:( totals, cust, rooms ) =>
    @resv      = @res.createRoomResv( 'Mine', 'card', totals, cust, rooms )
    @amount    = totals - @resv.paid
    $('#Pays'        ).empty()
    $('#Pays'        ).append( @confirmHead(  @resv ) )
    $('#ConfirmBlock').append( @confirmTable( @resv, 'Guest' ) )
    $('#Pays'        ).append( @confirmBtns(  @resv ) )
    $('#PayDiv'      ).append( @payHtml()      )
    $('#Pays'        ).append( @termsHtml()    )
    @initCCPayment( @resv, @amount )
    @credit.init( 'cc-num', 'cc-exp', 'cc-cvc', 'cc-com' )
    $('#Pays').show()
    @testPop() if @testing
    return

  initCCPayment:( resv, amount ) =>
    @hideCCErrors()
    $('#cc-amt' ).text( '$'+amount )
    $('#ChangeReser').click(  (e) => @onChangeReser( e ) )
    $('#MakeDeposit').click(  (e) => @onMakeDeposit( e ) )
    $('#MakePayment').click(  (e) => @onMakePayment( e ) )
    $('#cc-sub'     ).click(  (e) => @submitPayment( e ) )
    $('#cc-can'     ).click(  (e) => @onCancel(      e ) )
    return

  hideCCErrors:() ->
    $('#er-num').text('Invalid Number')
    $('#er-num').hide()
    $('#er-exp').hide()
    $('#er-cvc').hide()
    $('#er-sub').hide()
    return

  testPop:() ->
    $('#cc-num').val( '4242424242424242' )
    $('#cc-exp').val( '10/19'            )
    $('#cc-cvc').val( '555'              )
    return

  onChangeReser:( e ) =>
    e.preventDefault()
    $('#Make').text( 'Change Reservation')
    $('#Pays').hide()
    $('#Book').show()
    return

  onCancel:( e ) =>
    e.preventDefault()
    @home.onHome()  if @home?
    return

  calcDeposit:() ->
    Math.round(   @resv.totals * 50 ) / 100

  onMakeDeposit:( e ) =>
    e.preventDefault()
    @amount  =  @ccAmt( 'Deposit' )
    $('#MakePay').text('Make 50% Deposit')

  onMakePayment:( e ) =>
    e.preventDefault()
    @amount  =  @ccAmt( 'PayInFull' )
    $('#MakePay').text('Make Payment with Visa Mastercard or Discover')

  ccAmt:( purpose=@purpose ) ->
    @purpose = purpose
    amount   = if @purpose is 'Deposit' then @calcDeposit() else @resv.totals
    $("#cc-amt" ).text('$'+amount)
    amount

  confirmHead:( resv ) ->
    console.log( 'Pay.confirmHead', resv )
    htm   = """<div id="ConfirmTitle" class= "Title"><span>Confirmation # #{resv.resId}</span><span>  For: #{resv.cust.first} </span><span>#{resv.cust.last} </span></div>"""
    #tm  += """<div><div id="ConfirmName"></div></div>"""
    htm  += """<div id="ConfirmBlock" class="DivCenter"></div>"""
    htm
 
  confirmTable:( resv, appName ) ->
    htm  = ""
    htm += @confirmRooms(    resv, appName )
    htm += @confirmPayments( resv )
    htm

  confirmRooms:( resv, appName ) ->
    htm   = """<table id="ConfirmTable"><thead>"""
    htm  += """<tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>Spa</th><th>Price</th><th class="arrive">Arrive</th><th class="depart">Depart</th><th>Nights</th><th>Total</th></tr>"""
    htm  += """</thead><tbody>"""
    arriveTimes = if appName is 'Guest' then "Arrival is from 3:00-8:00PM" else ""
    departTimes = if appName is 'Guest' then "Checkout is before 10:00AM"  else ""
    for own roomId, r of resv.rooms
      days   = Util.keys(r.days).sort()
      arrive = @confirmDate( days[0],             "", false )
      depart = @confirmDate( days[days.length-1], "", true  )
      htm += """<tr><td class="td-left">#{r.name}</td><td class="guests">#{r.guests}</td><td class="pets">#{r.pets}</td><td>#{@spa(resv,roomId)}</td><td class="room-price">$#{r.price}</td><td>#{arrive}</td><td>#{depart}</td><td class="nights">#{r.nights}</td><td id="#{roomId}TR" class="room-total">$#{r.total}</td></tr>"""
    htm
    htm  += """<tr><td></td><td></td><td></td><td></td><td></td><td class="arrive-times">#{arriveTimes}</td><td class="depart-times">#{departTimes}</td><td></td><td  id="TT" class="room-total">$#{resv.totals}</td></tr>"""
    htm  += """</tbody></table>"""

  confirmPayments:( resv ) ->
    htm   = """<table id="ConfirmPayment"><thead>"""
    htm  += """<tr><th>Amount</th><th>Purpose</th><th>Date</th><th>With</th><th>Last 4</th></tr>"""
    htm  += """</thead><tbody>"""
    for own payId, pay of resv.payments
      date  = @confirmDate( pay.date, "", false )
      htm  += """<tr><td>$#{pay.amount}</td><td>#{pay.purpose}</td><td>#{date}</td><td>#{pay.with}</td><td>#{pay.num}</td></tr>"""
    htm  += """</tbody></table>"""
    htm  += """<table id="ConfirmBalance" style="margin-top:20px;"><thead>"""
    htm  += """<tr><th>Total</th><th>Paid</th><th>Balance</th></tr>"""
    htm  += """</thead><tbody>"""
    htm  += """<tr><td>$#{resv.totals}</td><td>$#{resv.paid}</td><td>$#{resv.balance}</td></tr>"""
    htm  += """</tbody></table>"""
    htm

  # Call after @res.postResv(...)
  confirmEmail:( resv ) ->
    win = window.open("""mailto:#{resv.cust.email}?subject=Skyline Cottages Confirmation&body=#{@confirmEmailBody(resv)}""","EMail")
    #win.close() if win? and not win.closed
    Util.noop( win )
    return

  confirmEmailBody:( resv ) =>
    body  = """\n      Confirmation ##{resv.resId}\nFor: #{resv.cust.first} #{resv.cust.last}\nPhone: #{resv.cust.phone}\n\n"""
    body += @confirmEmailRooms( resv )
    body += """\n Totals:$#{resv.totals} Paid:$#{resv.paid} Balance:$#{resv.balance} """
    body = escape(body)
    body

  confirmEmailRooms:( resv) ->
    text = ""
    for own roomId, r of resv.rooms
      name   = Util.padEnd( r.name+' ', 26, '-' )
      days   = Util.keys(r.days).sort()
      arrive = @confirmDate( days[0],             "", false )
      depart = @confirmDate( days[days.length-1], "", true  )
      text  += """#{name} $#{r.price}  #{r.guests}-Guests #{r.pets}-Pets Arrive:#{arrive} Depart:#{depart} #{r.nights}-Nights $#{r.total}\n"""
    text

  confirmContent2:( resv, stuff ) ->
    content = ""
    Util.log( 'Pay.confirmContent rooms', resv.rooms )
    for own roomId, r of resv.rooms
      name   = Util.padEnd( r.name+' ', 26, '-' )
      days   = Util.keys(r.days).sort()
      bday   = days[0]
      i      = 0
      while i < r.nights
        eday   = days[i]
        if i is r.nights-1 or days[i+1] isnt Data.advanceDate( eday, 1 )
          arrive   = @confirmDate( bday, "", false )
          depart   = @confirmDate( eday, "", true  )
          if      stuff is 'html'
            content += """<tr><td class="td-left">#{r.name}</td><td class="guests">#{r.guests}</td><td class="pets">#{r.pets}</td><td>#{@spa(resv,roomId)}</td><td class="room-price">$#{r.price}</td><td>#{arrive}</td><td>#{depart}</td><td class="nights">#{r.nights}</td><td id="#{roomId}TR" class="room-total">$#{r.total}</td></tr>"""
          else if stuff is 'body'
            content  += """#{name} $#{r.price}  #{r.guests}-Guests #{r.pets}-Pets Arrive:#{arrive} Depart:#{depart} #{r.nights}-Nights $#{r.total}\n"""
          bday     = days[i+1]
        i++
    content

  spa:( resv,roomId ) ->
    change = resv.rooms[roomId].change
    has    = @res.hasSpa(roomId)
    if  !has then '' else if change is -20 then 'N' else 'Y'

  confirmBtns:( resv ) ->
    canDeposit = @canMakeDeposit( resv )
    htm   = """<div class="PayBtns">"""
    htm  += """  <button class="btn btn-primary" id="ChangeReser">Change Reservation</button>"""
    htm  += """  <button class="btn btn-primary" id="MakeDeposit">Make 50% Deposit</button>""" if canDeposit
    htm  += """  <button class="btn btn-primary" id="MakePayment">Make Payment</button>"""     if canDeposit
    htm  += """</div>"""
    htm  += """<div id="MakePay" class="Title">Make Payment</div>"""
    htm  += """<div id="PayDiv"></div>"""
    htm  += """<div id="Approval"></div>"""
    htm

  canMakeDeposit:( resv ) ->
    arrive  = parseInt( resv.arrive )
    advance = parseInt( Data.advanceDate( resv.booked, 7 ) )
    #Util.log('Pay.canMakeDeposit()', { booked:resv.booked, arrive:arrive, advance:advance, can:arrive >= advance } )
    arrive >= advance

  departDate:( monthI, dayI, weekdayI ) ->
    dayO     = dayI + 1
    monthO   = monthI
    weekdayO = ( weekdayI + 1 ) % 7
    if dayI >= Data.numDayMonth[monthI]
       dayO     = 1
       monthO   = monthI + 1
    [monthO, dayO, weekdayO]

  confirmDate:( dayStr, msg, isDepart ) ->
    year       = parseInt( dayStr.substr(0,2) ) + 2000
    monthIdx   = parseInt( dayStr.substr(2,2) ) - 1
    day        = parseInt( dayStr.substr(4,2) )
    weekday = new Date()
    weekday.setYear(  year )
    weekday.setMonth( monthIdx )
    weekday.setDay(   day )
    weekdayIdx = weekday.getDay()
    [monthIdx,day,weekdayIdx] = @departDate( monthIdx,day,weekdayIdx ) if isDepart
    """#{Data.weekdays[weekdayIdx]} #{Data.months[monthIdx]} #{day}, #{year}  #{msg}"""

  payHtml:() ->
    numPtn="\d{4} \d{4} \d{4} \d{4}"
    expPtn="(1[0-2]|0[1-9])\/\d\d"
    cvcPtn="\d{3}"
    """
    <div id="form-pay">
      <span class="form-group">
        <label for="cc-num" class="control-label" id="cc-com">Card Number</label>
        <input id= "cc-num" type="tel" class="input-lg form-control cc-num masked" placeholder="•••• •••• •••• ••••" pattern="#{numPtn}" required>
        <div   id= "er-num" class="cc-msg">Invalid Number</div>
      </span>

      <span class="form-group">
        <label for="cc-exp" class="control-label">MM/YY Expiration</label>
        <input id= "cc-exp" type="tel" class="input-lg form-control cc-exp masked" placeholder="MM/YY" pattern="#{expPtn}" required>
        <div   id= "er-exp" class="cc-msg">Invalid MM/YY</div>
      </span>

      <span class="form-group">
        <label for="cc-cvc" class="control-label">CVC</label>
        <input id= "cc-cvc" type="tel" class="input-lg form-control cc-cvc masked" placeholder="•••" pattern="#{cvcPtn}"  required>
        <div   id= "er-cvc" class="cc-msg">Invalid CVC</div>
      </span>

      <span class="form-group">
        <label for="cc-amt"   class="control-label">Amount</label>
        <div   id= "cc-amt" class="input-lg form-control cc-amt"></div>
        <div   id= "er-amt" class="cc-msg"></div>
      </span>

      <span class="form-group">
        <label  for="cc-sub" class="control-label">&nbsp;</label>
        <button id= "cc-sub" class="btn btn-lg btn-primary">Pay</button>
        <div    id= "er-sub" class="cc-msg"></div>
      </span>

      <span class="form-group">
        <label  for="cc-can" class="control-label">&nbsp;</label>
        <button id= "cc-can" class="btn btn-lg btn-primary">Cancel</button>
        <div    id= "er-can" class="cc-msg"></div>
      </span>
    </div>
    """

  submitPayment:( e ) =>
    e.preventDefault() if e?
    @hideCCErrors()

    num = $('#cc-num').val().toString()
    exp = $('#cc-exp').val().toString()
    cvc = $('#cc-cvc').val().toString()
    @last4 = num.substr( 11, 4 )

    card   = @credit.cardFromNumber(  num )
    iry    = @credit.parseCardExpiry( exp )
    accept = @cardAccept(card.type)

    ne = @credit.validateCardNumber( num )
    ee = @credit.validateCardExpiry( iry )
    ce = @credit.validateCardCVC(    cvc, card.type )

    mon =      exp.substr(0,2)
    yer = '20'+exp.substr(5,2)
    if ne and ee and ce and accept
      @hidePay()
      $('#Approval').text("Waiting For Approval...").show()
      @token( num, mon, yer, cvc )  # Call Stripe

    else
      ae = card.type + ' not accepted'
      $('#er-num').text(ae) if not accept
      $('#er-num').show()   if not ne or not accept
      $('#er-exp').show()   if not ee
      $('#er-cvc').show()   if not ce

    #Util.log( 'Pay.submitPayment()', { num:num, ne:ne, exp:exp, ee:ee, cvc:cvc, ce:ce, mon:mon, yer:yer } )
    return

  hidePay:() ->
    $('#MakePay' ).hide()
    $('#PayDiv'  ).hide()
    $('.PayBtns' ).hide()

  showPay:() ->
    $('#MakePay' ).show()
    $('#PayDiv'  ).show()
    $('.PayBtns' ).show()

  isValid:( name, test, testing=false ) ->
    value = $('#'+name).val()
    valid = Util.isStr( value )
    if testing
      $('#'+name).val(test)
      value = test
      valid = true
    [value,valid]

  cardAccept:( cardType ) ->
    cardType is 'Visa' or cardType is 'Mastercard' or cardType is 'Discover'

  subscribe:() ->
    @stream.subscribe( 'tokens',  @onToken,  @onError )
    @stream.subscribe( 'charges', @onCharge, @onError )

  token:( number, exp_month, exp_year, cvc ) ->
    input = { "card[number]":number, "card[exp_month]":exp_month, "card[exp_year]":exp_year, "card[cvc]":cvc }
    #ajaxRest( "tokens", 'post', input, @onTokenError )
    @memToken( "tokens", 'post', input, @onTokenError )
    return

  charge:( token, amount, currency, description ) ->
    input = { source:token, amount:amount, currency:currency, description:description }
    #ajaxRest(  "charges", 'post', input, @onChargeError )
    @memCharge( "charges", 'post', input, @onChargeError )
    return

  onTokenError:( error, status ) =>
    Util.noop(   error, status )
    @showPay()
    $('#Approval').text("Unable to Verify Card").show()
    return

  onChargeError:( error, status ) =>
    Util.noop(    error, status )
    @showPay()
    $('#Approval').text("Payment Denied").show()
    return

  onToken:(obj) =>
    #Util.log( 'StoreRest.onToken()', obj )
    @tokenId  = obj.id
    @cardId   = obj.card.id
    @charge( @tokenId, @amount, 'usd', @resv.cust.first + " " + @resv.cust.last )

  memToken:( table, op, input, onError ) ->
    if input   is false then {}
    if onError is false then {}
    result = { id:"tokenId", card:{ id:"cardId" } }
    @stream.publish( table, result )
    return

  memCharge:( table, op, input, onError ) ->
    if input   is false then {}
    if onError is false then {}
    result = { outcome: { type:"authorized" } }
    @stream.publish( table, result )
    return

  onCharge:(obj) =>
    #Util.log( 'Pay.onCharge()', obj )
    if obj['outcome'].type is 'authorized'
      @doPost(       @resv )
      @res.postResv( @resv, 'post', @amount, 'Credit', @last4, @purpose )
      #confirmEmail( @resv )
    else
      @amount = 0
      @doDeny(       @resv )
      @res.postResv( @resv, 'deny', @amount, 'Credit', @last4, @purpose )

  doPost:( resv ) ->
    @hidePay()
    $('#Approval').text("Approved: A Confirnation Email Been Sent To #{resv.cust.email}")
    @home.showConfirm()  if @home?

  doDeny:( resv ) ->
    if resv   is false then {}
    @showPay()
    $('#Approval').text('Payment Denied').show()

  onError:(obj) =>
    Util.error( 'StoreRest.onError()', obj )

  ajaxRest:( table, op, input, onError ) ->
    url       = @uri + table
    settings  = { url:url, type:op }
    settings.headers = { Authorization: 'Bearer '+ Data.stripeTestKey }
    settings.data = input
    settings.success = ( result,  status, jqXHR ) =>
      @stream.publish( table, result )
      Util.noop( jqXHR, status )
      return
    settings.error   = ( jqXHR, status, error ) =>
      Util.noop( jqXHR )
      onError( status, error )
    $.ajax( settings )
    return

  toQuery:( input ) ->
    query = ""
    return query if not input?
    for own key, val of input
      query += """@#{key}=#{val}"""
    query[0] = '?'

  toJSON:(     obj  ) -> if obj? then JSON.stringify(obj) else ''

  toObject:(   json ) -> if json then JSON.parse(json) else {}

  termsHtml:() ->
    """
      <ul class="Terms">
        <li>The number of guests and pets has to be declared in the reservation.</li>
        <li>Prices have been automatically calculated.</li>
        <li style="margin-left:20px;">Additional guests are $10 per night above the base rate for 2-4 guests.</li>
        <li style="margin-left:20px;">Each pet is $12 per night.</li>
        <li>A deposit is 50% of the total reservation.</li>
        <li>There will be a deposit refund with a 50-day cancellation notice, less a $50 fee.</li>
        <li>Less than 50-day notice, deposit is forfeited.</li>
        <li>Short term reservations have a 3-day cancellation deadline.</li>
      </ul>
    """

export default Pay