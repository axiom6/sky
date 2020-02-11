
import Util     from './Util.js'
import Data     from './Data.js'
#mport UI       from  './UI.js'
import Bookings from  './Bookings.js'

class Upload

  constructor:( @stream, @store, @res ) ->
    @uploadedText  = ""
    @uploadedResvs = {}

  html:() ->
    htm  = ""
    htm += """<h1  class="UploadH1">Upload Booking.com</h1>"""
    htm += """<button   id="UploadRes"  class="btn btn-primary">Upload Res</button>"""
    htm += """<button   id="UploadCan"  class="btn btn-primary">Upload Can</button>"""
    htm += """<button   id="UpdateDay"  class="btn btn-primary">Update Day</button>"""
    htm += """<button   id="CustomFix"  class="btn btn-primary">Custom Fix</button>"""
    htm += """<textarea id="UploadText" class="UploadText" rows="50" cols="100"></textarea>"""
    htm

  bindUploadPaste:() ->
    onPaste = (event) =>
      if window.clipboardData and window.clipboardData.getData # IE
        @uploadedText = window.clipboardData.getData('Text')
      else if event.clipboardData and event.clipboardData.getData
        @uploadedText = event.clipboardData.getData('text/plain')
      event.preventDefault()
      if Util.isStr(    @uploadedText )
         @uploadedResvs = @uploadParse(  @uploadedText )
         $('#UploadText').text( @uploadedText )
    document.addEventListener( "paste", onPaste )

  uploadParse:( text ) ->
    resvs   = {}
    return resvs if not Util.isStr( text )
    lines = text.split('\n')
    for line in lines
      toks = line.split('\t')
      continue if toks[0] is 'Guest name'
      book   = @bookFromToks( toks )
      resv   = @resvFromBook( book )
      resvs[resv.resId ] = resv if resv?
    resvs

  bookFromToks:( toks ) ->
    book           = {}
    book.names     = toks[0]
    book.arrive    = toks[1]
    book.depart    = toks[2]
    book.room      = toks[3]
    book.booked    = toks[4]
    book.status    = toks[5]
    book.total     = toks[6]
    book.commis    = toks[7]
    book.bookingId = toks[8]
    #Util.log( 'Book......')
    #Util.log(  book )
    book

  resvFromBook:( book ) ->
    names  = book.names.split(' ')
    arrive = @toResvDate( book.arrive )
    depart = @toResvDate( book.depart )
    stayto = Data.advanceDate( depart, -1 )
    booked = @toResvDate( book.booked )
    roomId = @toResvRoomId( book.room )
    #first = names[0]
    last   = names[1]
    status = @toStatusBook( book.status )
    guests = @toNumGuests( names )
    total  = parseFloat( book.total.substr(3) )
    if status is 'Booking'
      @res.createResvBooking( arrive, stayto, roomId, last, status, guests, total, booked )
    else
      null

  onUploadRes:() =>
    Util.log( 'Upload.onUploadRes')
    if not Util.isStr( @uploadedText )
      @uploadedText  = Bookings.bookingResvs
      @uploadedResvs = @uploadParse(  @uploadedText )
      $('#UploadText').text( @uploadedText )
    return if Util.isObjEmpty(    @uploadedResvs )
    return if not @updateValid(   @uploadedResvs )
    @res.updateResvs(             @uploadedResvs )
    @uploadedResvs = {}

  onUploadCan:() =>
    Util.log( 'Upload.onUploadCan')
    if not Util.isStr( @uploadedText )
      @uploadedText  = Data.canceled
      @uploadedResvs = @uploadParse(  @uploadedText )
      $('#UploadText').text( @uploadedText )
    return if Util.isObjEmpty(    @uploadedResvs )
    return if not @updateValid(   @uploadedResvs )
    @res.updateCancels(           @uploadedResvs )
    @uploadedResvs = {}

  ### For dev only. Repopulates database
  onCreateRes:() =>
    Util.log( 'Upload.onCreateRes')
    for own resId, resv of @res.resvs
      @res.delResv( resv )
    resvs = require( 'data/res.json' )
    for own resId, resv of resvs
      @res.addResv( resv )
    return
  ###

  onUpdateDay:() =>
    Util.log( 'Upload.onUpdateDay')
    onComplete = () =>
      for own dayId, day  of @res.days
        @res.delDay( day )
        #Util.log( 'Upload.onUpdateDay() day del', day )
      for own resId, resv of @res.resvs
        @res.updateDaysFromResv( resv )
    @res.selectAllDays( onComplete )
    return

  onCreateCan:() =>
    Util.log( 'Upload.onCreateCan')
    #@store.make( 'Can' ) # Unexplicably Deleted Tables 'Res' and 'Day'
    cans  = require( 'data/can.json' )
    for own canId, can of cans
      @res.addCan( can )
    return

  onCustomFix:() =>
    resvs = @fixParse()
    if resvs is false then {}
    #for resId,  resv of resvs
    #  @res.addResv( resv )
    return

  fixParse:() ->
    resvs   = {}
    for text in [Bookings.june,Bookings.july,Bookings.aug,Bookings.sept,Bookings.july19]
      lines = text.split('\n')
      for line in lines
        toks = line.split(' ')
        book   = @fixToks( toks )
        resv   = @fixResv( book )
        resvs[resv.resId ] = resv
    resvs

  fixToks:( toks ) ->
    book           = {}
    book.arrive    = toks[0]
    book.stayto    = toks[1]
    book.nights    = toks[2]
    book.room      = toks[3]
    book.last      = toks[4]
    book.guests    = toks[5]
    book.status    = toks[6]
    book.booked    = toks[7]
    #Util.log( 'Book......')
    #Util.log(  book )
    book

  fixResv:( book ) ->
    arrive = @toFixDate(  book.arrive )
    stayto = @toFixDate(  book.stayto )
    nights = Data.nights( arrive, stayto )
    roomId = book.room
    last   = book.last
    status = @toStatusFix( book.status )
    guests = book.guests
    booked = @toFixDate(  book.booked )
    total  = @res.total( status, nights, roomId, guests )
    @res.createResv( arrive, stayto, booked, roomId, last, status, guests, 0, status, total )

  toFixDate:( mmdd ) ->
    [mi,dd] = if mmdd.length <= 2 then [6,parseInt(mmdd)] else Data.midd(mmdd)
    Data.toDateStr( dd, mi )

  toStatusFix:( s ) ->
    r = s
    if s.length is 1
      r = if  s is 'B' then 'Booking' else 'Skyline'
    r

  updateValid:( uploadedResvs ) ->
    valid = true
    for own resId, u of uploadedResvs
      v  = true
      #.v &= Util.isStr( u.first )
      v &= Util.isStr( u.last  )
      v &= 1 <= u.guests and u.guests <= 12
      v &= Data.isDate( u.arrive )
      v &= Data.isDate( u.depart )
      v &= if typeof(pets) is 'number' then 0 <= u.pets   and u.pets   <=  4 else true
      v &= 0 <= u.nights and u.nights <= 28
      v &= Util.inArray( @res.roomKeys, u.roomId )
      v &=   0.00 <= u.total and u.total <= 8820.00
      v &= 120.00 <= u.price and u.price <=  315.00
      valid &= v
      if not v
        Util.log( 'Resv Not Valid', resId, v )
        Util.log(  u )
    Util.log( 'Master.updateValid()', valid )
    true

  toNumGuests:( names ) ->
    for i in [0...names.length] when names[i] is 'guest' or names[i] is 'guests'
      return names[i-1]
    return '0' # This will invalidate

  toResvDate:( bookDate ) ->
    toks  = bookDate.split(' ')
    year  = Data.year
    month = Data.months.indexOf(toks[1]) + 1
    day   = toks[0]
    year.toString() + Util.pad(month) + day

  toResvRoomId:( bookRoom ) ->
    toks  = bookRoom.split(' ')
    if toks[0].charAt(0) is '#'
       toks[0].charAt(1)
    else
       toks[2].charAt(0)

  toStatusBook:( bookingStatus ) ->
    switch   bookingStatus
      when 'OK'       then 'Booking'
      when 'Canceled' then 'Cancel'
      else                 'Unknown'

export default Upload