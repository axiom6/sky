
import Util from './Util.js'
import Data from './Data.js'
import UI   from './UI.js'

class Book

  constructor:( @stream, @store, @res, @pay, @pict ) ->
    @rooms    = @res.rooms
    @res.book = @
    @$cells   = []
    @last     = null # Last date clicked
    @totals   = 0
    @method   = 'site'

  ready:() ->
    @res.roomUI( @rooms )
    $('#Book'    ).empty()
    $('#Pays'    ).empty()
    $('#Book'    ).append( @bookHtml()  )
    $('#Insts'   ).append( @instructHtml() )
    $('#Inits'   ).append( @initsHtml() )
    $('#Guest'   ).append( @guestHtml() )
    $('.guests'  ).change( @onGuests  )
    $('.pets'    ).change( @onPets    )
    $('.SpaCheck').change( @onSpa     )
    $('#Months'  ).change( @onMonth   )
    $('#Days'    ).change( @onDay     )
    $('#Pop'     ).click(  @onPop     )
    $('#Test'    ).click(  @onTest     )
    $('#GoToPay' ).click(  @onGoToPay ) # .prop('disabled',true)
    $('#Totals').css( { height:'21px' } )
    $('#Navb').hide()
    onComplete = () =>
      $('#Rooms').append( @roomsHtml(Data.year,Data.monthIdx,Data.begDay,Data.numDays) )
      @roomsJQuery()
      $('#Book').show()
    @res.dateRange( Data.beg, Data.end, onComplete )
    return

  bookHtml:() ->
    """
    <div id="Make" class="Title">Make Your Reservation</div>
    <div id="Insts"></div>
    <div><div id="Inits"></div></div>
    <div id="Rooms"></div>
    <div id="Guest"></div>
    """

  instructHtml:() ->
    """
    <div   class="Instruct">
      <div>1. Select Month and Day of Arrival 2. Then for each Room Select:</div>
      <div style="padding-left:16px;">3. Number of Guests 4. Number of Pets 5. Click the Days</div>
      <div>6. Enter Contact Information: First Last Names, Phone and EMail</div>
    </div>
    """

  initsHtml:() ->
    htm  = """<label for="Months" class="InitIp">Start: #{ UI.htmlSelect( "Months", Data.season, Data.month() ) }</label>"""
    htm += """<label for="Days"   class="InitIp">       #{ UI.htmlSelect( "Days",   Data.days,   Data.begDay  ) }</label>"""
    htm += """<label class="InitIp">&nbsp;&nbsp;#{2000+Data.year}</label>"""
    htm += """<span  id="Pop"  class="Test">Pop</span>"""
    htm += """<span  id="Test" class="Test">Test</span>"""
    htm

  seeRoom:( roomId, room ) ->
    #"""<a href="rooms/#{roomId}.html" id="#{roomId}L">#{room.name}</a>"""
    room.name

  roomsHtml:( year, monthIdx, begDay, numDays ) ->
    date        = new Data()
    date.setYear( 2000+year )
    date.setMonth( monthIdx )
    data.setDay(   1        )
    weekdayIdx  = date.getDay()
    htm   = "<table><thead>"
    htm  += """<tr><th></th><th></th><th></th><th></th><th></th>"""
    for day in [1..numDays]
      weekday = Data.weekdays[(weekdayIdx+begDay+day-2)%7]
      htm += "<th>#{weekday}</th>"
    htm  += "<th>Room</th></tr><tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>Spa</th><th>Price</th>"
    for day in [1..numDays]
      htm += "<th>#{Data.dayMonth(day)}</th>"
    htm += "<th>Total</th></tr></thead><tbody>"
    for own roomId, room of @rooms
      htm += """<tr id="#{roomId}"><td class="td-left">#{@seeRoom(roomId,room)}</td><td class="guests">#{@g(roomId)}</td><td class="pets">#{@p(roomId)}</td><td>#{@spa(roomId)}</td><td id="#{roomId}M" class="room-price">#{'$'+@calcPrice(roomId)}</td>"""
      for day in [1..numDays]
        date = Data.toDateStr( Data.dayMonth(day) )
        htm += @createCell( date, roomId )
      htm += """<td class="room-total" id="#{roomId}T"></td></tr>"""
    htm += """<tr>"""
    htm += """<td></td>""" for day in [1..numDays+5]
    htm += """<td class="room-total" id="Totals">&nbsp;</td></tr>"""
    htm += "</tbody></table>"
    htm

  guestHtml:() ->
    phPtn = "\d{3} \d{3} \d{4}" # pattern="#{phPtn}"
    """
    <form autocomplete="on" method="POST" id="FormName">
      <div id="Names">
        <span class="SpanIp">
          <label for="First" class="control-label">First Name</label>
          <input id= "First" type="text" class="input-lg form-control" autocomplete="given-name" required>
          <div   id= "FirstER" class="NameER">* Required</div>
        </span>

        <span class="SpanIp">
          <label for="Last" class="control-label">Last Name</label>
          <input id= "Last" type="text" class="input-lg form-control" autocomplete="family-name" required>
          <div   id= "LastER" class="NameER">* Required</div>
        </span>

        <span class="SpanIp">
          <label for="Phone" class="control-label">Phone</label>
          <input id= "Phone" type="tel" class="input-lg form-control" placeholder="••• ••• ••••"  pattern="#{phPtn}" required>
          <div   id= "PhoneER" class="NameER">* Required</div>
        </span>

        <span class="SpanIp">
          <label for="EMail"   class="control-label">Email</label>
          <input id= "EMail" type="email" class="input-lg form-control" autocomplete="email" required>
          <div   id= "EMailER" class="NameER">* Required</div>
        </span>
      </div>
      <div id="GoToDiv" style="text-align:center;">
       <button class="btn btn-primary" type="submit" id="GoToPay">Go To Confirmation and Payment</button>
      </div>
    </form>
    """

  isValid:( name, test, testing=false ) ->
    value = $('#'+name).val()
    valid = Util.isStr( value )
    if testing
      $('#'+name).val(test)
      value = test
      valid = true
    #$('#'+name+'ER').show() if not valid
    [value,valid]

  createCust:( testing=false ) ->
    [first,fv] = @isValid('First', 'Samuel',      testing )
    [last, lv] = @isValid('Last',  'Hosendecker', testing )
    [phone,pv] = @isValid('Phone', '3037977129',  testing )
    [email,ev] = @isValid('EMail', 'Thomas.Edmund.Flaherty@gmail.com', testing )
    tv   = @totals > 0
    cust = @res.createCust( first, last, phone, email, "site" )
    [tv,fv,lv,pv,ev,cust]

  # Significant transition from Book to Pay
  onGoToPay:( e ) =>
    e.preventDefault() if e?
    [tv,fv,lv,pv,ev,cust] = @createCust()
    if tv and fv and lv and pv and ev
      $('.NameER').hide()
      $('#Book').hide()
      @pay.initPayResv( @totals, cust, @rooms )
    else
      alert( @onGoToMsg( tv,fv,lv,pv,ev ) )
    return

  onGoToMsg:( tv,fv,lv,pv,ev ) ->
    msg  = ""
    msg += "Total is 0\n"           if not tv
    msg += "Need to Click Rooms\n"  if not tv
    msg += "Enter First Name\n"     if not fv
    msg += "Enter Last  Name\n"     if not lv
    msg += "Enter Phone Number\n"   if not pv
    msg += "Enter Email\n"          if not ev
    msg

  #Util.log('Book.createCell', { date:date, roomId:roomId, status:status, color:Data.toColor(status), style:style, htm:htm } )
  createCell:( date, roomId ) ->
    status = @res.status( date, roomId )
    style  = """background:#{Data.toColor(status)};"""
    """<td id="#{@cellId(date,roomId)}" class="room-#{status}" style="#{style}"></td>"""

  cellId:( date,  roomId ) ->
     'R' + date + roomId

  roomIdCell:( $cell ) ->
    $cell.attr('id').substr(7,1)

  dateCell:( $cell ) ->
    $cell.attr('id').substr(1,6)

  $cell:( date,  roomId ) ->
    $( '#' + @cellId(date,roomId) )

  roomsJQuery:() ->
    $cell.unbind( "click" ) for $cell in @$cells
    @$cells = []
    for roomId, room of @rooms
      room.$ = $('#'+roomId) # Keep jQuery out of room database table
      for day in [1..Data.numDays]
        date  = Data.toDateStr( Data.dayMonth(day) )
        $cell = @$cell(date,roomId)
        $cell.click( (event) => @onCellBook(event) )
        @$cells.push( $cell )
        @updateTotal( roomId )
        status = @res.status( date, roomId )
        @cellStatus( $cell, status )
    return

  calcPrice:( roomId ) =>
    room       = @rooms[roomId]
    room.price = @res.calcPrice( roomId, room.guests, room.pets, 'Skyline' )
    room.price

  updateTotal:( roomId ) ->
    price  = @calcPrice( roomId )
    $('#'+roomId+'M').text("#{'$'+ price }")
    room   = @rooms[roomId]
    nights = Util.keys(room.days).length
    room.total = price * nights + room.change
    # Util.log( 'Book.updateTotal()', { roomId:roomId, nights:nights, change:room.change, total:room.total } )
    text = if room.total is 0 then '' else '$'+room.total
    $('#'+roomId+'T').text(text)
    @updateTotals()
    return

  updateTotals:() ->
    @totals = 0
    for own roomId, room of @rooms
      @totals += room.total
    text = if @totals is 0 then '' else '$'+@totals
    $('#Totals').text(text)
    $('#GoToPay').prop('disabled',false) if @totals > 0
    return

  g:(roomId) -> UI.htmlSelect( roomId+'G', Data.persons, 2, 'guests', @rooms[roomId].max )
  p:(roomId) -> UI.htmlSelect( roomId+'P', Data.pets,    0, 'pets',   3                  )

  onGuests:( event ) =>
    roomId = $(event.target).attr('id').charAt(0)
    @rooms[roomId].guests = event.target.value
    @updateTotal(roomId)
    return

  onPets:( event ) =>
    roomId = $(event.target).attr('id').charAt(0)
    @rooms[roomId].pets = event.target.value
    @updateTotal(roomId)
    return

  spa:( roomId ) ->
    if @res.optSpa(roomId) then """<input id="#{roomId}SpaCheck" class="SpaCheck" type="checkbox" value="#{roomId}" checked>""" else ""

  onSpa:( event ) =>
    $elem   = $(event.target)
    roomId  = $elem.attr('id').charAt(0)
    room    = @rooms[roomId]
    checked = $elem.is(':checked')
    spaFee  = if checked then  20         else -20
    reason  = if checked then 'Spa Added' else 'Spa Opted Out'
    room.change += spaFee
    room.reason  = reason
    @updateTotal( roomId )  if room.total > 0
    return

  onMonth:( event ) =>
    Data.monthIdx  = Data.months.indexOf(event.target.value)
    Data.begDay    = if Data.month() is 'May' then Data.begMay else 1
    $('#Days').val(Data.begDay.toString())
    @resetRooms() # or resetDateRange:()
    return

  onDay:( event ) =>
    Data.begDay = parseInt(event.target.value)
    if Data.month() is 'October' and Data.begDay > 1
      Data.begDay = 1
      alert( 'The Season Ends on October 15' )
    @resetRooms() # or resetDateRange:()
    return

  # Not needed because we have the whole date range for the season
  resetDateRange:() ->
    beg = Data.toDateStr( Data.begDay, Data.monthIdx )
    end = Data.advanceDate( beg, Data.numDays-1 )
    @res.dateRange( beg, end, @resetRooms )

  resetRooms:() =>

  resetRooms2:() =>
    $('#Rooms').empty()
    $('#Rooms').append( @roomsHtml( Data.year, Data.monthIdx, Data.begDay, Data.numDays ) )
    @roomsJQuery()

  onPop:() =>
    #Util.log( 'Book.onPop()'  )
    @createCust( true )
    @pay.testing = true
    return

  onTest:() =>
    @test.doTest() if @test?
    return
    
  onCellBook:( event ) =>
    $cell  = $(event.target)
    [date,roomId,status] = @cellBook( $cell )
    @fillInCells( @last, date, roomId, 'Free', status ) if status is 'Mine'
    @last = date
    return

  fillInCells:( begDate, endDate, roomId, free, fill ) ->
    return if not ( begDate? and endDate? and roomId? )
    [beg,end] = Data.begEndDates( begDate, endDate )
    $cells = []
    next   = beg
    while next <= end
      $cell  = @$cell( 'M', next, roomId )
      status = @res.status( next, roomId )
      if status is free or status is fill or status is 'Cancel'
        $cells.push( $cell )
        next = Data.advanceDate( next, 1 )
      else
        return [null,null]
    for $cell in $cells
      @cellStatus( $cell, fill )
    return

  cellBook:( $cell ) ->
    date   = @dateCell(   $cell )
    roomId = @roomIdCell( $cell )
    resId  = Data.resId(  date, roomId )
    status = @res.status( date, roomId )
    if      status is 'Free'
      status = 'Mine'
      @updateCellStatus( $cell, 'Mine', resId )
    else if status is 'Mine'
      status = 'Free'
      @updateCellStatus( $cell, 'Free', resId )
    [date,roomId,status]

  updateCellStatus:( $cell, status, resId ) ->
    @cellStatus(     $cell, status )
    date   = @dateCell(   $cell )
    roomId = @roomIdCell( $cell )
    resId  = Data.resId( date, roomId )
    day    = @res.day(   date, roomId )
    if status is 'Mine'
      @res.setDay( day, status, resId )
    else if status is 'Free'
      weekday = Data.weekday(date)
      if weekday is 'Fri' or weekday is 'Sat'
        nday = Data.advanceDate( date, 1 )
        @cellStatus( @$cell( nday, roomId ), 'Free' )
    @updateTotal( roomId  )
    [roomId,status]

  allocDays:( days ) =>
    for own dayId, day of days
      date   = Data.toDate( dayId )
      roomId = Data.roomId( dayId )
      @allocCell( date, day.status, roomId )
    return

  allocCell:( date, status, roomId ) ->
    @cellStatus( @$cell(date,roomId), status )

  cellStatus:( $cell, klass ) ->
    $cell.removeClass().addClass("room-"+klass)
    $cell.css( { background:Data.toColor(klass) } )
    #Util.log( 'Book.cellStatus', klass, Data.toColor(klass) )
    return

export default Book
