

import Data from './Data'
#mport UI   from './UI'

class Season

  constructor:( @stream, @store, @res ) ->
    @rooms         = @res.rooms
    @showingMonth  = 'Master'

  html:() ->
    htm = ""
    for month in Data.season
      htm += """<div id="#{month}C" class="#{month}C">#{@monthTable(month)}</div>"""
    htm

  monthTable:( month ) ->
    monthIdx = Data.months.indexOf(month)
    begDate  = new Date()
    begDate.setYear(  2000+Data.year )
    begDate.setMonth( monthIdx )
    begDate.setDay( 1 )
    begDay   = begDate.getDay() - 1
    endDay   = Data.numDayMonth[monthIdx]
    htm  = """<div   class="SeasonTitle">#{month}</div>"""
    htm += """<table class="SeasonTable"><thead><tr>"""
    for day in [0...7]
      weekday = Data.weekdays[day]
      htm += """<th>#{weekday}</th>"""
    htm += """</tr></thead><tbody>"""
    for row in [0...6]
      htm += """<tr>"""
      for col in [0...7]
        day  = @monthDay( begDay, endDay, row, col )
        htm += """<td><div class="TDC">#{@roomDayHtml(monthIdx,day)}</div></td>"""
      htm += """</tr>"""
    htm += """</tbody></table>"""

  roomDayHtml:( monthIdx, day ) ->
    htm  = ""
    return htm if day is 0
    htm += """<div class="DayC">#{day}</div>"""
    for roomNum in [1..10]
      roomId    = Data.getRoomIdFromNum( roomNum )
      roomClass = "RoomC" + roomId
      date      = Data.toDateStr( day, monthIdx )
      resv      = @res.getResv(  date, roomId )
      last      = if resv? then resv.last else ""
      htm      += """<div class="#{roomClass}">##{roomId} #{last}</div>"""
    htm

  monthDay:( begDay, endDay, row, col ) ->
    day = row*7 + col - begDay
    day = if 1 <= day and day <= endDay then day else 0
    day

  roomDayId:(  monthIdx,  day, roomId ) ->
    date = Data.dateStr( day, monthIdx )
    @cellId( 'S', roomId, date )

  onMonthClick:( event ) =>
    @showMonth( $(event.target).text() )
    return

  showMonth:( month ) ->
    $master = $('#Season')
    if month is @showingMonth    # Show all Months
      @removeAllMonthStyles()
      $('.TDC').hide()
      $master.children().show()
      @showingMonth = 'Master'
    else                          # Show selected month
      $master.children().hide()
      $('.TDC').show()
      @$month( month ).css(  { left:0, top:0, width:'100%', height:'740px', fontSize:'14px', border:'none' } ).show()
      @showingMonth = month
    return

  # Removes expanded style from month and goes back to the month's css selector
  removeAllMonthStyles:() ->
    @$month(month).removeAttr('style') for month in Data.season

  $month:( month ) ->
     $('#'+month+'C')

  cellId:( pre,  date,  roomId ) ->
    pre + date + roomId

  $cell:( pre,  date,  roomId ) ->
    $( '#'+@cellId(pre,date,roomId) )

  allocCell:( roomId, date ) ->
    @cellStatus( @$cell('S',date,roomId) )
    return

  cellStatus:( $cell, status ) ->
    $cell.removeClass().addClass( "own-"+status)
    return

export default Season