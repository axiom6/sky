
$ = require( 'jquery' )

class Res

  module.exports = Res
  Res.Rooms = require( 'data/room.json' )
  Res.Resvs = {} #require( 'data/res.json'  )
  Res.Days  = {} #require( 'data/days.json' )
  Res.Sets  = ['full','book','resv','chan']  # Data set for @res.days and @res.resv

  constructor:( @stream, @store, @Data, @appName ) ->
    @rooms    = Res.Rooms
    @roomKeys = Util.keys( @rooms )
    @book     = null
    @master   = null
    @days     = {}
    @resvs    = {}  # Only use occasionally
    @dateRange( @Data.beg, @Data.end, 'full' ) if @appName is 'Guest' # Get entire season for both Guest and Owner
    @populateMemory()      if @store.justMemory

  populateMemory:() ->
    @onResv(  'add', (resv) => Util.noop( 'onResv', resv ) )
    @onDays(  'put', (days) => Util.noop( 'onDays', days ) ) if @store.justMemory
    @insertNewTables() # Populate Memory

  dateRange:( beg, end, set, onComplete=null ) ->
    @store.subscribe( 'Days', 'range', 'none', (days) =>
      Util.error( 'Res.dateRange() unknown data set', set ) if not Util.inArray( Res.Sets, set )
      @days[set] = days
      #console.log( 'Res.dateRange()', beg, end, daysProp, @days[daysProp] )
      onComplete() if onComplete? )
    @store.range( 'Days', beg, end )
    return

  resvRange:( beg, end, set, onComplete=null ) ->
    Util.log( 'Res.resvRange()', beg, end, set )
    resvSelect = () =>
      Util.log( 'Days', @days[set] )
      @store.subscribe( 'Res', 'select', 'none', (resvs) =>
        for date, day in @days[set]
          @resvs[set][day.resId] = resvs[day.resId]
          Util.log( 'Day', day )
          Util.log( 'Res', resvs[day.resId] )
        onComplete() if onComplete? )
      @store.select( 'Res' )
    @dateRange( beg, end, set, resvSelect )

  insertNewTables:() ->
    @insertRooms( Res.Rooms )
    @insertResvs( Res.Resvs )
    @insertDays(  Res.Resvs )

  getStatus:( roomId, date ) ->
    day   = if @days['full']? then @days['full'][date]
    entry = if  day?  and  day[roomId]? then day[roomId] else null
    if entry? then entry.status else 'free'

  resId:(    roomId, date ) ->
    day   = if @days['full']? then @days['full'][date]
    entry = if day? and day[roomId]? then day[roomId] else null
    if entry? then entry.resId else 'none' # Need to determine if resId == 'none' if the way to go

  # Note the expanded roomUI is for Book.coffee and should never be persisted
  roomUI:( rooms ) ->
    for own key, room of rooms
      room.$ = {}
      room   = @populateRoom( room, {}, 0, 0, 2, 0 )
    return

  populateRoom:( room, days, total, price, guests, pets ) ->
   room.days    = days
   room.total   = total
   room.price   = price
   room.guests  = guests
   room.pets    = pets
   room.change  = 0         # Changes usually to spa opt out
   room.reason  = 'No Changes'
   room

  optSpa:( roomId ) -> @rooms[roomId].spa is 'O'
  hasSpa:( roomId ) -> @rooms[roomId].spa is 'O' or @rooms[roomId].spa is 'Y'

  createRoomResv:( status, method, totals, cust, rooms ) ->
    resv          = {}
    resv.resId    = @Data.genResId( rooms )
    resv.totals   = totals
    resv.paid     = 0
    resv.balance  = 0
    resv.status   = status
    resv.method   = method
    resv.booked   = @Data.today()
    resv.arrive   = resv.resId.substr(0,6)
    resv.rooms    = {}
    for own roomId, room of rooms when not Util.isObjEmpty(room.days)
      delete room.$ # So not to persist jQuery
      room.nights  = Util.keys(room.days).length
      resv.rooms[roomId] = room
      for own day, obj of room.days
        day.status = status if day.status is 'mine'
        resv.arrive = day   if day < resv.arrive
    resv.payments = {}
    resv.cust     = cust
    #@subscribeToResId( resv.resId, 'add', (resv), Util.log( 'Resv', { resId:resv.resId, resv:resv )
    resv

  allocRooms:( resv ) ->
    for own  roomId, room of resv.rooms
      for own dayId, day  of room.days
        @setDayRoom( day, resv.status, resv.resId ) # setDayRoom also works for days in rooms
      delete room.group
      @allocRoom( roomId, room.days )

  allocRoom:( roomId, days ) ->
    @book.  onAlloc( roomId, days ) if @book?
    @master.onAlloc( roomId, days ) if @master?

  onResId:( op, doResv, resId ) => @store.on( 'Res',  op,  resId, (resv) => doResv(resv) )
  onResv:(  op, doResv        ) => @store.on( 'Res',  op, 'none', (resv) => doResv(resv) )
  onDays:(  op, doDay         ) => @store.on( 'Days', op, 'none', (day)  => doDay(day)   )

  dayResvs:( today ) ->
    resvs = {}
    for own date, day of @days['full'] when date is today
      resvs[day.resId] = @resvs[day.resId]
    resvs

  insertRooms:( rooms ) =>
    @store.subscribe( 'Room', 'make', 'none', (make)  => @store.insert( 'Room', rooms ); Util.noop(make)  )
    @store.make( 'Room' )
    return

  insertResvs:( resvs ) ->
    @allocRooms( resv ) for own resId,  resv of resvs
    @store.subscribe( 'Res', 'make', 'none', () => @store.insert( 'Res', resvs ) )
    @store.make( 'Res' )
    return

  insertDays:( resvs ) ->
    @days = @createDaysFromResvs( resvs, {} )
    for own dayId, day of @days
      @store.add( 'Days', dayId, day )
    #console.log('Res.insertDays() days', @days  )
    return

  createDaysFromResvs:( resvs, days ) ->
    for own resvId, resv of resvs
      days = @createDaysFromResv( resv, days )
    days

  createDaysFromResv:( resv, days ) ->
    for   own roomId, room of resv.rooms
      for own  dayId, rday of room.days
        dayRoom = @createDayRoom( days, dayId, roomId )
        @setDayRoom( dayRoom, rday.status, rday.resId )
    days

  # Inexplicable this maybe randomly generating arrays on [roomId]
  createDayRoom:( days, dayId, roomIdA ) ->
    roomId = roomIdA.toString()
    days[dayId]         = {} if not days[dayId]?
    days[dayId][roomId] = {}
    days[dayId][roomId]


  calcPrice:( roomId, guests, pets  )
    @rooms[roomId][guests] + pets*@Data.petPrice

  spaOptOut:( roomId, isSpaOptOut=true ) ->
    if @rooms[roomId].spa is 'O' and isSpaOptOut then Data.spaOptOut else 0

  createResvSkyline:( arrive, stayto, roomId, last, status, guests, pets, spa=false, cust={}, payments={} ) ->
    price  = @rooms[roomId][guests] + pets*@Data.petPrice
    depart = @Data.advanceDate( depart, 1 )
    nights = @Data.nights( arrive, depart )
    total  = price * nights
    @createResv( arrive, stayto, roomId, last, status, guests, 'Skyline', total, spa, cust, payments )

  createResvBooking:( arrive, depart, roomId, last, status, guests, total ) ->
    stayto   = @Data.advanceDate( depart, -1 )
    @createResv( arrive, stayto, roomId, last, status, guests, 'Booking', total )

  createResv:( arrive, stayto, roomId, last, status, guests, source, total, spa=false, cust={}, payments={} ) ->
    resv           = {}
    resv.arrive    = arrive
    resv.stayto    = stayto
    resv.depart    = @Data.advanceDate( stayto, 1 )
    resv.nights    = @Data.nights( arrive, depart )
    resv.roomId    = roomId
    resv.last      = last
    resv.status    = status
    resv.guests    = guests
    resv.source    = source
    resv.resId     = arrive + roomId
    resv.total     = total
    resv.price     = total / resv.nights
    resv.tax       = Util.toFixed( total * @Data.tax )
    resv.spaOptOut = @spaOptOut( roomId, spa )
    resv.charge    = total + parseFloat( tax ) - resv.spaOptOut
    resv.paid      = 0
    resv.balance   = 0
    resv.cust      = cust
    resv.payments  = payments
    resv

  createCust:( first, last, phone, email, source ) ->
    cust = {}
    cust.custId = @Data.genCustId( phone )
    cust.first  = first
    cust.last   = last
    cust.phone  = phone
    cust.email  = email
    cust.source = source
    cust

  createPayment:( amount, method, last4, purpose ) ->
    payment = {}
    payment.amount  = amount
    payment.date    = @Data.today()
    payment.method  = method
    payment.with    = method
    payment.last4   = last4
    payment.purpose = purpose
    payment.cc      = ''
    payment.exp     = ''
    payment.cvc     = ''
    payment

  setResvStatus:( resv, post, purpose ) ->
    if        post is 'post'
        resv.status = 'book' if purpose is 'PayInFull' or purpose is 'Complete'
        resv.status = 'depo' if purpose is 'Deposit'
    else if   post is 'deny'
        resv.status = 'free'
    if not Util.inArray(['book','depo','free'], resv.status )
      Util.error( 'Pay.setResStatus() unknown status ', resv.status )
      resv.status = 'free'
    resv.status

  postResvChan:( resv ) ->
    @allocRooms( resv )
    @store.add( 'Res', resv.resId, resv )

  postResv:( resv, post, amount, method, last4, purpose ) ->
    status = @setResvStatus( resv, post, purpose )
    if status is 'book' or status is 'depo'
      payId = @Data.genPaymentId( resv.resId, resv.payments )
      resv.payments[payId] = @createPayment( amount, method, last4, purpose )
      resv.paid   += amount
      resv.balance = resv.totals - resv.paid
      @allocRooms( resv )
      @store.add( 'Res', resv.resId, resv )
      @days = @mergePostDays( resv, @days )
   # Util.log('Res.postResv()', resv )

  mergePostDays:( resv, allDays) ->
    newDays = @createDaysFromResv( resv, {} )
    for own newDayId, newDay of newDays
      for own roomId, room   of newDay
        dayRoom = @createDayRoom( allDays, newDayId, roomId )
        @setDayRoom( dayRoom, room.status, room.resId )
        # We do not publish from Days with the newDayId+'/'+roomId grand child
        # Instead @allocRoom( resv ) is driven by resv
        @store.put( 'Days', newDayId+'/'+roomId, dayRoom )
    allDays

  createRoomDays:( arrive, nights, status, resId ) ->
    days = {}
    for i in [0...nights]
      dayId = @Data.advanceDate( arrive, i )
      days[dayId] = {}
      @setDayRoom( days[dayId], status, resId )
    days

  # Used for Days / dayId / roomId and for Res / rooms[dayId] since both has status and resid properties
  setDayRoom:( dayRoom, status, resId ) ->
    dayRoom.status = status
    dayRoom.resId  = resId

  # UI Element that does that quite belong here
  htmlSelect:( htmlId, array, choice, klass="", max=undefined ) ->
    style = if Util.isStr(klass) then klass else htmlId
    htm   = """<select name="#{htmlId}" id="#{htmlId}" class="#{style}">"""
    where = if max? then (elem) -> elem <= max else () -> true
    for elem in array when where(elem)
      selected = if elem is Util.toStr(choice) then "selected" else ""
      htm += """<option#{' '+selected}>#{elem}</option>"""
    htm += "</select>"

  # UI Element that does that quite belong here
  htmlInput:( htmlId, klass, value="", label="", type="text" ) ->
    htm  = ""
    htm += """<label for="#{htmlId}" class="#{klass+'Label'}">#{label}</label>"""  if Util.isStr(label)
    htm += """<input id= "#{htmlId}" class="#{klass}" value="#{value}" type="#{type}">"""
    htm

  htmlButton:( htmlId, klass, title ) ->
    """<button id="#{htmlId}" class="btn btn-primary #{klass}">#{title}</button>"""

  # Sets htmlId property on obj
  makeSelect:( htmlId, obj ) =>
    onSelect = (event) -> obj[htmlId] = $(event.target).value
    $('#'+htmlId).change( onSelect )
    return

  # Sets htmlId property on obj
  makeInput:( htmlId, obj ) =>
    onInput = (event) -> obj[htmlId] = $(event.target).value # $('#'+htmlId).val()
    $('#'+htmlId).change( onInput )
    return

