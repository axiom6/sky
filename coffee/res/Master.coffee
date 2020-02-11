
import Util   from './Util.js'
import Data   from './Data'
import UI     from './UI'
import Upload from './Upload'
import Query  from './Query'
import Input  from './Input'
import Season from './Season'

class Master

  constructor:( @stream, @store, @res ) ->
    @rooms         = @res.rooms
    @upload        = new Upload( @stream, @store, @res    )
    @query         = new Query(  @stream, @store, @res, @ )
    @input         = new Input(  @stream, @store, @res, @ )
    @season        = new Season( @stream, @store, @res    )
    @res.master    = @
    @dateBeg       = @res.today
    @dateEnd       = @res.today
    @dateSel       = "End"
    @roomId        = null
    @nextId        = null
    @resMode       = 'Table' # or 'Input'

  ready:() ->
    #@selectToDays() if @store.justMemory
    @listenToDays()
    #listenToResv()
    $('#MasterBtn').click( @onMasterBtn )
    $('#MasterPrt').click( @onMasterPrt )
    $('#ResTblPrt').click( @onResTblPrt )
    $('#MakResBtn').click( @onMakResBtn )
    $('#SeasonBtn').click( @onSeasonBtn )
    $('#SeasonPrt').click( @onSeasonPrt )
    $('#DailysBtn').click( @onDailysBtn )
    $('#DailysPrt').click( @onDailysPrt )
    $('#UploadBtn').click( @onUploadBtn )
    $('#ReadyMBtn').click( @readyMaster )
    #res.dateRange( Data.beg, Data.end, @readyMaster ) # This works
    #res.selectAllDaysResvs( @readyMaster )
    @res.selectAllResvs( @readyMaster, true )
    return

  onMasterBtn:( onComplete=null ) =>
    @resMode = 'Table'
    $('#Season').hide()
    $('#Dailys').hide()
    $('#Upload').hide()
    $('#ResAdd').hide()
    $('#ResTbl').show()
    $('#Master').show()
    onComplete() if Util.isFunc(onComplete)
    return

  doPrint:() =>
    window.print()
    $('#Buttons').show('fast')
    return

  onMasterPrt:() =>
    onComplete = () =>
      $('#Buttons, #ResTbl').hide( 'fast', @doPrint )
    @onMasterBtn( onComplete )
    return

  onResTblPrt:() =>
    $('#QArrive').text( Data.ddMMDD( 1                   ) )
    $('#QStayTo').text( Data.ddMMDD( Data.numDaysMonth() ) )
    @query.resvBody( @res.resvArrayDepart() )
    onComplete = () =>
      $('#Buttons, #Master').hide( 'fast', @doPrint )
    @onMasterBtn( onComplete )
    return

  begStayTo:() ->
    Data.toDateStr( Data.numDaysMonth(), Data.monthIdx-1 )

  begQuery:() ->
    [yy,mi,dd] = Data.yymidd( @res.today )
    dt = if mi is Data.monthIdx then dd else 1
    Data.toDateStr( dt )

  onMakResBtn:() =>
    @resMode = 'Input'
    $('#Season').hide()
    $('#Dailys').hide()
    $('#Upload').hide()
    $('#ResAdd').show()
    $('#ResTbl').hide()
    $('#Master').show()
    @fillInCells( @dateBeg, @dateEnd, @roomId, 'Mine', 'Free' ) # Clear any previous fill
    @dateEnd = @dateBeg
    return

  onSeasonBtn:( onComplete=null ) =>
    $('#Master').hide()
    $('#Dailys').hide()
    $('#Upload').hide()
    $('#Season').append( @season.html() ) if Util.isEmpty( $('#Season').children() )
    $('.SeasonTitle').click( (event) => @season.onMonthClick(event) )
    @season.showMonth( Data.month() ) # Show the current month
    $('#ResAdd').hide()
    $('#ResTbl').hide()
    $('#Season').show()
    onComplete() if Util.isFunc(onComplete)
    return

  onSeasonPrt:() =>
    onComplete = () =>
      $('#Buttons').hide( 'fast', @doPrint )
    @onSeasonBtn( onComplete )
    return

  onDailysBtn:( onComplete=null ) =>
    $('#ResAdd').hide()
    $('#ResTbl').hide()
    $('#Master').hide()
    $('#Season').hide()
    $('#Upload').hide()
    $('#Dailys').append( @dailysHtml() ) if Util.isEmpty( $('#Dailys').children() )
    $('#Dailys').show()
    onComplete() if Util.isFunc(onComplete)
    return

  onDailysPrt:() =>
    onComplete = () =>
      $('#Buttons').hide( 'fast', @doPrint )
    @onDailysBtn( onComplete )
    return

  onUploadBtn:() =>
    $('#ResAdd').hide()
    $('#ResTbl').hide()
    $('#Master').hide()
    $('#Season').hide()
    $('#Dailys').hide()
    $('#Upload').append( @upload.html() ) if Util.isEmpty( $('#Upload').children() )
    @upload.bindUploadPaste()
    $('#UploadRes').click( @upload.onUploadRes )
    $('#UploadCan').click( @upload.onUploadCan )
    $('#UpdateDay').click( @upload.onUpdateDay )
    $('#CreateCan').click( @upload.onCreateCan )
    $('#CustomFix').click( @upload.onCustomFix )
    $('#Upload').show()
    return

  readyMaster:() =>
    $('#Master').empty()
    $('#Master').append( @html() )
    @showMonth( Data.month(), false ) # Show the current month
    $('.PrevMonth').click( (event) => @onMonthClick(event) )
    $('.ThisMonth').click( (event) => @onMonthClick(event) )
    $('.NextMonth').click( (event) => @onMonthClick(event) )
    @query.readyQuery()
    @input.readyInput()
    @readyCells()
    #Util.log( 'Master.readyMaster()' )
    return

  readyCells:() =>

    doCell = (event) =>
      @fillInCells( @dateBeg, @dateEnd, @roomId, 'Mine', 'Free' )
      $cell   = $(event.target)
      $cell   = if $cell.is('div') then $cell.parent() else $cell
      date    = if $cell.is('td' ) then $cell.attr('data-date'  ) else Data.toDateStr( $cell.text() )
      @nextId = if $cell.is('td' ) then $cell.attr('data-roomid') else 0
      return if not date? or not @nextId?
      [@dateBeg,@dateEnd,@dateSel,@roomId] = @mouseDates(date)

      if @roomId is 0
        $('#ResAdd').hide()
        $('#ResTbl').show()
        @fillInCells( @dateBeg, @dateEnd, @roomId, 'Free', 'Mine' )
        @query.updateBody( @dateBeg, @dateEnd, 'arrive' )
      else
        $('#ResTbl').hide()
        $('#ResAdd').show()
        resv = @res.getResv( date, @roomId )
        if not resv?
          @input.createResv( @dateBeg, @dateEnd, @roomId )
        else
          @input.updateResv( resv )
      return

    $('thead #Day th'  ).click(       doCell )
    $('[data-cell="y"]').click(       doCell )
    $('[data-cell="y"]').contextmenu( doCell )
    return

  mouseDates:( date ) ->
    @res.order = 'Decend' # Will flip to 'Ascend'
    if        @nextId isnt @roomId
              @dateBeg  =  date
              @dateEnd  =  date
    else if   @dateBeg <= date and date <= @dateEnd
      if      @dateSel is 'Beg'
              @dateBeg  =  date
              @dateSel  = 'End'
      else if @dateSel is 'End'
              @dateEnd  = date
              @dateSel  = 'Beg'
    else # Not needed but good for expression
      @dateEnd  = date if @dateEnd < date
      @dateBeg  = date if @dateBeg > date
    #Util.log( 'Master.mouseDates()', @dateBeg, date, @dateEnd, @dateSel )
    [@dateBeg,@dateEnd,@dateSel,@nextId]

  # Only fill in freeStatus cells return success
  # Also order dates if necessary
  fillInCells:( begDate, endDate, roomId, free, fill ) ->
    return [null,null] if not ( begDate? and endDate? and roomId? )
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
       if roomId is 0 then @dayStatus($cell,fill) else @cellStatus($cell,fill)
    [beg,end]

  listenToDays:() =>
    doDays = (dayId,day) =>
      if dayId? and day?
        @res.days[dayId] = day
        @onAlloc( dayId )
    @res.onDay( 'add',  doDays )
    @res.onDay( 'put',  doDays )
    return

  listenToResv:() =>
    doAdd = (resId,resv) =>
      if resId? and resv? and not @res.resvs[resId]
        @res.resvs[resId] = resv
    doDel = (resId,resv) =>
      if resId? and resv? and @res.resvs[resId]
        delete @res.resvs[resId]
    @res.onRes( 'add', doAdd )
    @res.onRes( 'put', doAdd )
    @res.onRes( 'del', doDel )
    return

  selectToDays:() =>
    doDays = (days) =>
      #console.log( 'Master.selectDays()', days )
      @allocDays( days )
    @res.onDays( 'select', doDays )
    @store.select( 'Days' )
    return

  allocDays:(  days ) =>
    @onAlloc(  dayId ) for own dayId, day of days
    return

  onAlloc:(  dayId ) =>
    date   = Data.toDate( dayId )
    roomId = Data.roomId( dayId )
    #Util.log( 'Master.onAlloc', date, roomId )
    @allocCell(        roomId, date )
    @season.allocCell( roomId, date ) if @season?
    return

  cellId:( pre,  date,  roomId ) ->
      pre + date + roomId

  $cell:( pre,  date,  roomId ) ->
    $( '#'+@cellId(pre,date,roomId) )

  allocCell:( roomId, date ) ->
    klass  = @res.klass( date, roomId )
    @cellStatus( @$cell('M',date,roomId), klass )
    return

  fillCell:( date, roomId, klass ) ->
    @cellStatus( @$cell('M',date,roomId), klass )
    return

  cellStatus:( $cell, klass ) ->
    $cell.removeClass().addClass( "room-"+klass)
    $cell.css( { background:Data.toColor(klass) } )
    return

  dayStatus:( $cell, klass ) ->
    $cell.css( { background:Data.toColor(klass) } )
    return

  onMonthClick:( event ) =>
    @showMonth( $(event.target).text() )
    return

  showMonth:( month, second=true ) ->
    $master = $('#Master')
    if month is Data.month() and second  # Show all Months
      @removeAllMonthStyles()
      $master.css(  { height:'860px' } )
      $master.children().show()
    else                          # Show selected month
      Data.monthIdx = Data.months.indexOf(month)
      $master.children().hide()
      $master.css( { height:'475px' } )
      $('#'+month).css(  { left:0, top:0, width:'100%', height:'475px', fontSize:'14px' } ).show()
    return

  # Removes expanded style from month and goes back to the month's css selector
  removeAllMonthStyles:() ->
    $('#'+month).removeAttr('style') for month in Data.season

  html:() ->
    htm = ""
    for month in Data.season
      htm += """<div id="#{month}" class="#{month}">#{@roomsHtml( Data.year, month )}</div>"""
    htm

  roomsHtml:( year, month ) ->
    monthIdx   = Data.months.indexOf(month)
    prevMonth  = if monthIdx > 4 then """<span class="PrevMonth">#{Data.months[monthIdx-1]}</span>""" else ""
    nextMonth  = if monthIdx < 9 then """<span class="NextMonth">#{Data.months[monthIdx+1]}</span>""" else ""
    begDay     = 1                           # if month isnt 'May'     then 1 else 17
    endDay     = Data.numDayMonth[monthIdx] # if month isnt 'October' then Data.numDayMonth[monthIdx] else 15
    weekday = new Date()
    weekday.setYear( 2000+year )
    weekday.setMonth( monthIdx )
    weekday.setDay( 1 )
    weekdayIdx = weekday.getDay()
    htm  = """<div   class="MasterTitle">#{prevMonth}<span class="ThisMonth">#{month}</span>#{nextMonth}</div>"""
    htm += """<table class="MonthTable"><thead>"""
    htm += """<tr><th></th>"""
    for day in [begDay..endDay]
      weekday = Data.weekdays[(weekdayIdx+day-1)%7].charAt(0)
      htm += """<th>#{weekday}</th>"""
    htm  += """</tr><tr id="Day""><th></th>"""
    for day in [begDay..endDay]
      date = Data.toDateStr( day, monthIdx )
      htm += """<th id="#{@cellId('M',date,0)}">#{day}</th>"""
    htm  += "</tr></thead><tbody>"
    for own roomId, room of @rooms
      htm += """<tr id="#{roomId}"><td>#{roomId}</td>"""
      for day in [begDay..endDay]
        date = Data.toDateStr( day, monthIdx )
        htm += @createCell(  date, roomId )
      htm += """</tr>"""
    htm += "</tbody></table>"
    htm

  createCell:( date, roomId ) ->
    [yy,mi,dd] = Data.yymidd( date )
    resv   = @res.getResv( date, roomId )
    klass  = @res.klass(   date, roomId )
    bord   = @border(      date, roomId, resv, klass )
    last   = if resv? and ( resv.arrive is date or dd is 1 ) then "<div>#{resv.last}</div>" else ''
    htm    = """<td id="#{@cellId('M',date,roomId)}" class="room-#{klass}" style="#{bord}" """
    htm   += """data-roomid="#{roomId}" data-date="#{date}" data-cell="y">#{last}</td>""" # Lower case roomid
    htm

  addLast:(    date, roomId, last, status ) ->
    if status is false then {}
    $cell = @$cell( 'M',  date,  roomId )
    $div  =  $cell.find('div')
    if UI.isElem( $div )
      $div.text(last)
    else
      $cell.append( "<div>#{last}</div>" )
    return

  updArrival:( arrive0, arrive1, roomId, last, status ) ->
    @fillCell( arrive0, roomId, 'Free'       ) if arrive1 > arrive0
    @delLast(  arrive0, roomId               )
    @fillCell( arrive1, roomId, status       ) if arrive1 < arrive0
    @addLast(  arrive1, roomId, last, status )
    return

  delLast:(     date, roomId ) ->
    @$cell('M', date, roomId ).empty()

  border:( date, roomId,   resv, klass ) ->
    color = Data.toColor( klass )
    bord  = ""
    if resv?
      bord    = "background-color:#{color}; border-top: 2px solid black;     border-bottom:2px solid black;   "
      if date is resv.arrive
        bord += "background-color:#{color}; border-left: 2px solid black;    border-right:2px solid #{color}; "
      else if date is resv.stayto
        bord += "background-color:#{color}; border-right:2px solid black;    border-left:2px  solid #{color}; "
      else
        bord += "background-color:#{color}; border-right:2px solid #{color}; border-left:2px  solid #{color}; "
    else
      bord    = "border:1px solid black;"
    bord

  dailysHtml:() ->
    htm  = ""
    htm += """<h1 class="DailysH1">Daily Activities</h1>"""
    htm += """<h2 class="DailysH2">Arrivals</h2>"""
    htm += """<h2 class="DailysH2">Departures</h2>"""
    htm

  # Not Used
  calcSpan:( date, roomId, mi, dd, endDay ) ->
    span   = 1
    resv   = @res.getResv( date, roomId )
    if resv?
      ya=0; ma=0; da=0; ys=0; ms=0; ds=0;
      [ya,ma,da] = Data.yymidd( resv.arrive )
      [ys,ms,ds] = Data.yymidd( resv.stayto )
      if resv.arrive is date
        span = Math.min( resv.nights, endDay-dd+1 )
      else if ma isnt ms and mi is ms
        span = ds
      else
        span = 0
    span

export default Master