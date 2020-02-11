
import Util from './Util.js'
import Data from './Data'
#mport UI   from './UI'

class Query

  constructor:( @stream, @store, @res, @master ) ->

  readyQuery:() ->
    $('#ResTbl').empty()
    $('#ResTbl').append( @resvHead() )
    @resvSortClick( 'RHBooked', 'booked' )
    @resvSortClick( 'RHRoom' ,  'roomId' )
    @resvSortClick( 'RHArrive', 'arrive' )
    @resvSortClick( 'RHStayTo', 'stayto' )
    @resvSortClick( 'RHName',   'last'   )
    @resvSortClick( 'RHStatus', 'status' )
    @updateBody( @master.begQuery(), Data.toDateStr( Data.numDaysMonth() ), 'arrive' )
    return    

  updateBody:( beg, end, prop ) ->
    $('#QArrive').text( Data.toMMDD(beg) )
    $('#QStayTo').text( Data.toMMDD(end) )
    resvs = []
    if prop is 'depart'
      resvs = @res.resvArrayDepart()
    if end?
      resvs = @res.resvArrayByProp( beg, end, prop )
    else
      resvs = @res.resvArrayByDate( beg )
    @resvBody( resvs )

  resvSortClick:( id, prop ) ->
    $('#'+id).click( () => @resvBody( @res.resvArrayByProp( @master.dateBeg, @master.dateEnd, prop ) ) )

  resvHead:() ->
    htm   = "" #"""<div id="QDates"><span id="QArrive"></span><span id="QStayTo"></span></div>"""
    htm  += """<table class="RTTable"><thead><tr>"""
    htm  += """<th id="RHArrive">Arrive</th><th id="RHStayTo">Stay To</th><th id="RHNights">Nights</th><th id="RHRoom"  >Room</th>"""
    htm  += """<th id="RHName"  >Name</th>  <th id="RHGuests">Guests</th> <th id="RHStatus">Status</th><th id="RHBooked">Booked</th>"""
    htm  += """<th id="RHPrice" >Price</th> <th id="RHTotal" >Total</th>  <th id="RHCommis">Comm</th>  <th id="RHTax"  >Tax</th>"""
    htm  += """<th id="RHCharge">Charge</th>"""
    htm  += """</tr><tr>"""
    htm  += """<th id="QArrive"></th><th id="QStayTo"></th><th></th><th></th>"""
    htm  += """<th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th>"""
    htm  += """</tr></thead><tbody id="RTBody"></tbody></table>"""
    htm

  resvBody:( resvs ) ->
    $('#RTBody').empty()
    htm = ""
    totals  = 0
    taxes   = 0
    commiss = 0
    charges = 0
    for r in resvs
      arrive  = Data.toMMDD(r.arrive)
      stayto  = Data.toMMDD(r.stayto)
      booked  = Data.toMMDD(r.booked)
      commis  = if r.status is 'Booking' or r.status is 'Prepaid' then '$'+Util.toFixed( r.total * Data.commis ) else ''
      tax     = Util.toFixed( r.total * Data.tax    )
      charge  = Util.toFixed( r.total + parseFloat(tax) )
      trClass = 'RTOldRow' # if @res.isNewResv(r) then 'RTNewRow' else 'RTOldRow'
      htm += """<tr class="#{trClass}">"""
      htm += """<td class="RTArrive">#{arrive}  </td><td class="RTStayto">#{stayto}</td><td class="RTNights">#{r.nights}</td>"""
      htm += """<td class="RTRoomId">#{r.roomId}</td><td class="RTLast"  >#{r.last}</td><td class="RTGuests">#{r.guests}</td>"""
      htm += """<td class="RTStatus">#{r.status}</td><td class="RTBooked">#{booked}</td><td class="RTPrice" >$#{r.price}</td>"""
      htm += """<td class="RTTotal" >$#{r.total}</td><td class="RTCommis">#{commis}</td><td class="RTTax"   >$#{tax}    </td>"""
      htm += """<td class="RTCharge">$#{charge} </td></tr>"""
      totals  += r.total
      taxes   += r.total * Data.tax
      commiss += r.total * Data.commis if r.status is 'Booking' or r.status is 'Prepaid'
      charges += r.total + parseFloat(tax)
    taxes   = Util.toFixed( taxes   )
    commiss = Util.toFixed( commiss )
    charges = Util.toFixed( charges )
    htm += """<tr class="'RTTotRow'">"""
    htm += """<td class="RTArrive">          </td><td class="RTStayto">          </td><td class="RTNights">         </td>"""
    htm += """<td class="RTRoomId">          </td><td class="RTLast"  >          </td><td class="RTGuests">         </td>"""
    htm += """<td class="RTStatus">          </td><td class="RTBooked">          </td><td class="RTPrice" >         </td>"""
    htm += """<td class="RTTotal" >$#{totals}</td><td class="RTCommis">#{commiss}</td><td class="RTTax"   >$#{taxes}</td>"""
    htm += """<td class="RTCharge">$#{charges}</td></tr>"""
    $('#RTBody').append( htm )
    return

export default Query