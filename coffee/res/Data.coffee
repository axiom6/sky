
import Util    from './Util.js'

class Data

  # ---- Read JSON with batch async

  @batchRead:( batch, callback, create=null ) ->
    for  own key, obj of batch
      @batchJSON( obj,   batch, callback, create )
    return

  @batchComplete:( batch ) ->
    for own key, obj of batch
      return false if not obj['data']
    true

# "Access-Control-Request-Headers": "*", "Access-Control-Request-Method": "*"

  @batchJSON:( obj, batch, callback, refine=null ) ->
    url = Data.toUrl(obj.url)
    opt = { mode:'no-cors', headers:{ 'Content-Type':'application/json' } }
    fetch( url, opt )
      .then( (response) =>
        return response.json() )
      .then( (data) =>
        obj['data']     = if Util.isFunc(refine) then refine( data ) else data
        callback( batch ) if Data.batchComplete( batch ) )
      .catch( (error) =>
        console.error( "Data.batchJSON()", { url:url, error:error } ) )
    return

  @toUrl:(url) ->
    if not url.startsWith('../')
      if window.location.href.includes('localhost') then Data.local+url else Data['hosted']+url
    else
      url


  @legacy      = ["unkn",   "canc",      "free",     "mine",   "prep",   "depo",   "chan",   "book",     "cnew",   "bnew"   ]
  @statuses    = ["Unknown","Cancel",    "Free",     "Mine",   "Prepaid","Deposit","Booking","Skyline",  "BookNew","SkylNew"]
  @colors      = ["#E8E8E8","#EEEEEE",   "#FFFFFF",  "#BBBBBB","#AAAAAA","#AAAAAA","#888888","#444444",  "#333333","#222222"]
  @colors1     = ["yellow", "whitesmoke","lightgrey","green",  "#555555","#000000","blue",   "slategray","purple", "black"  ]
  @statusesSel = ["Deposit","Skyline","Prepaid",  "Booking","Cancel"]
  @sources     = ["Skyline","Booking","Website"]
  @tax         = 0.1055 # Official Estes Park tax rate. Also in Booking.com
  @commis      = 0.15   # Bookings commision
  @season      = ["May","June","July","August","September","October"]
  @months      = ["January","February","March","April","May","June","July","August","September","October","November","December"]
  @months3     = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
  @numDayMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
  @weekdays    = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
  @days        = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"]
  @persons     = ["1","2","3","4","5","6","7","8","9","10","11","12"]
  @nighti      = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14"]
  @pets        = ["0","1","2","3","4"]
  @petPrice    = 12
  @year        = 17
  @spaOptOut   = 20
  @monthIdx    = new Date().getMonth()
  @monthIdx    = if 4 <=  Data.monthIdx and Data.monthIdx <= 9 then Data.monthIdx else 4
  @newDays     =  3 # Number of  days to signify a new booking
  @numDays     = 15 # Display 15 days in Guest reservation calendar
  @begMay      = 15
  @begDay      = if Data.monthIdx is 4 then Data.begMay else 1  # Being season on May 15
  @beg         = '170515'  # Beg seasom on May 15, 2017
  @end         = '171009'  # Beg seasom on Oct  9, 2017

  @configSkyriver = {
    apiKey: "AIzaSyDJxypukgOw20z80EZW9w1ObgyqB20qfYI",
    authDomain: "skyriver-81c21.firebaseapp.com",
    databaseURL: "https://skyriver-81c21.firebaseio.com",
    projectId: "skyriver-81c21",
    storageBucket: "skyriver-81c21.appspot.com",
    messagingSenderId: "1090600167020" }

  @tomUID = "4eKA0L3Gl0aR8LSAnFtAlOMWLUd2"
  @skyUID = "zf3UMOQz8FZiQ5hBypHeoAhDQnn2"
  @sueUID = "K2osvFYkZoTGVzkEqdqrH8rkr8h2"
  @skyPrj = "project-1090600167020"

  ###
    SkylineOnTheRiver.com 	TXT 	v=spf1 include:_spf.firebasemail.com ~all
    smtpapi._domainkey.SkylineOnTheRiver.com 	TXT 	k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDPtW5iwpXVPiH5FzJ7Nrl8USzuY9zqqzjE0D1r04xDN6qwziDnmgcFNNfMewVKN2D1O+2J9N14hRprzByFwfQW76yojh54Xu3uSbQ3JP0A7k8o8GutRF8zbFUA8n0ZH2y0cIEjMliXY4W4LwPA7m4q0ObmvSjhd63O9d8z1XkUBwIDAQAB
    SkylineOnTheRiver.com 	TXT 	firebase=skyriver-81c21
  ###

  @configSkytest = {
    apiKey: "AIzaSyAH4gtA-AVzTkwO_FXiEOlgDRK1rKLdJ2k",
    authDomain: "skytest-25d1c.firebaseapp.com",
    databaseURL: "https://skytest-25d1c.firebaseio.com",
    storageBucket: "skytest-25d1c.appspot.com",
    messagingSenderId: "978863515797" }

  @configSkyline = {
    apiKey:       "AIzaSyBjMGVzZ6JgZBs8O7mBQfH6clHYDmjTsGU",
    authDomain:   "skyline-fed2b.firebaseapp.com",
    databaseURL:  "https://skyline-fed2b.firebaseio.com",
    projectId: "skyline-fed2b",
    storageBucket: "skyline-fed2b.appspot.com/",
    messagingSenderId: "279547846849" }

  @toStatus:( status ) ->
    index = Data.legacy.indexOf(status)
    if index > 0 then Data.statuses[index] else status

  @toColor:( status ) ->
    index = Data.statuses.indexOf(status)
    if index > 0 then Data.colors[index] else "yellow"

  @config:( uri ) ->
    switch  uri
      when 'skyriver' then @configSkyriver
      when 'skyline'  then @configSkyline
      else                 @configSkytest

  @databases = { skyriver:"skyline-fed2b", skyline:"skyline-fed2b", skytest:"skytest-25d1c" }

  @stripeTestKey = "sk_test_FCa6Z3AusbsdhyV93B4CdWnV"
  @stripeTestPub = "pk_test_0VHIhWRH8hFwSeP2n084Ze4L"
  @stripeLiveKey = "sk_live_CCbj5oirIeHwTlyKVXJnbrgt"
  @stripeLivePub = "pk_live_Lb83wXgDVIuRoEpmK9ji2AU3"
  @stripeCurlKey = "sk_test_lUkwzunJkKfFmcEjHBtCfvhs"

  @resId:( date, roomId ) ->
    date + roomId

  @dayId:( date, roomId ) ->
    date + roomId

  @roomId:( anyId ) ->
    anyId.substr( 6, 1 )

  @getRoomIdFromNum:( num ) ->
    roomId = num
    roomId = 'N' if roomId is  9
    roomId = 'S' if roomId is 10
    roomId

  @toDate:( anyId ) ->
    if anyId?
      anyId.substr( 0, 6 )
    else
      Util

  @genResId:( roomUIs ) ->
    resId = ""
    for own roomId, roomUI of roomUIs when not Util.isObjEmpty(roomUI.days)
      days  = Util.keys(roomUI.days).sort()
      resId = days[0] + roomId
      break
    Util.error('Data.getResId() resId blank' ) if not Util.isStr(resId)
    resId

  @genCustId:( phone ) ->
    Util.padEnd( phone.substr(0,10), 10, '_' )

  @genPaymentId:( resId, payments ) ->
    pays   = Util.keys(payments).sort()
    payInt = parseInt(pays[pays.length-1])+1
    paySeq = if pays.length > 0 then payInt.toString()  else '1'
    resId  + paySeq

  @randomCustKey:() ->
    Math.floor( Math.random() * (9999999999-1000000000)) + 1000000000

  @today:() ->
    date = new Date()
    year = date.getFullYear() - 2000 # Go Y2K
    Data.toDateStr( date.getDate(), date.getMonth(), year )

  @month:() ->
    Data.months[Data.monthIdx]

  @numDaysMonth:( month=Data.month() ) ->
     mi = Data.months.indexOf(month)
     Data.numDayMonth[mi]

  @advanceDate:( date, numDays ) ->
    [yy,mi,dd] = @yymidd( date )
    dd += numDays
    if dd >       Data.numDayMonth[mi]
       dd  = dd - Data.numDayMonth[mi]
       mi++
    else if dd < 1
      mi--
      dd  = Data.numDayMonth[mi]
    Data.toDateStr( dd, mi, yy )

  @advanceMMDD:( mmdd, numDays ) ->
    [mi,dd] = @midd( mmdd )
    dd += numDays
    if dd >       Data.numDayMonth[mi]
       dd  = dd - Data.numDayMonth[mi]
       mi++
    else if dd < 1
       mi--
       dd  = Data.numDayMonth[mi]
    Util.pad(mi+1) + '/' + Util.pad(dd)

  # Only good for a 28 to 30 day interval
  @nights:( arrive, stayto ) ->
    num       = 0
    arriveDay = parseInt( arrive.substr( 4,2 ) )
    arriveMon = parseInt( arrive.substr( 2,2 ) )
    staytoDay = parseInt( stayto.substr( 4,2 ) )
    staytoMon = parseInt( stayto.substr( 2,2 ) )
    if      arriveMon   is staytoMon
      num = staytoDay - arriveDay + 1
    else if arriveMon+1 is staytoMon
      num = Data.numDayMonth[arriveMon-1] - arriveDay + staytoDay + 1
    Math.abs(num)

  @weekday:( date ) ->
    [yy,mi,dd] = @yymidd( date )
    weekday = new Date()
    weekday.setYear(  2000+yy )
    weekday.setMonth( mi )
    weekday.seDay(    dd )
    Data.weekdays[weekday.getDay()]

  @isDate:( date ) ->
    return false if not Util.isStr(date) or date.length isnt 6
    [yy,mi,dd] = @yymidd( date )
    valid  = true
    valid &= yy is Data.year
    valid &= 0 <= mi and mi <= 11
    valid &= 1 <= dd and dd <= 31
    valid

  @begEndDates:(  begDate1,   endDate1 ) ->
    return [null,null] if not ( begDate1? and endDate1? )
    begDate2 = if begDate1 <= endDate1 then begDate1 else endDate1
    endDate2 = if endDate1 >  begDate1 then endDate1 else begDate1
    [begDate2,endDate2]

  @yymidd:( date ) ->
    yy = parseInt( date.substr( 0,2 ) )
    mi = parseInt( date.substr( 2,2 ) ) - 1
    dd = parseInt( date.substr( 4,2 ) )
    [yy,mi,dd]

  @midd:( mmdd ) ->
    mi = parseInt( mmdd.substr( 0,2 ) ) - 1
    dd = parseInt( mmdd.substr( 3,2 ) )
    [mi,dd]

  @toMMDD:( date ) ->
    [yy,mi,dd] = @yymidd( date )
    Util.pad(mi+1) + '/' + Util.pad(dd)

  @ddMMDD:( dd, mi=Data.monthIdx ) ->
    Util.pad(mi+1) + '/' + Util.pad(dd)

  @toMMDD2:( date ) ->
    [yy,mi,dd] = @yymidd( date )
    str = (mi+1).toString() + '/' + dd.toString()
    Util.log( 'Data.toMMDD()', date, yy, mi, dd, str )
    str

  @isElem:( $elem ) ->
    not (  $elem? and $elem.length? and $elem.length is 0 )

  @dayMonth:( day ) ->
    monthDay = day + Data.begDay - 1
    if monthDay > Data.numDayMonth[@monthIdx] then monthDay-Data.numDayMonth[Data.monthIdx] else monthDay

  @toDateStr:( dd, mi=Data.monthIdx, yy=Data.year ) ->
    yy.toString() + Util.pad(mi+1) + Util.pad(dd)

  @toMonth3DayYear:( date ) ->
    [yy,mi,dd] = if Data.isDate(date) then @yymidd(date) else @yymidd(Data.today())
    Util.log( 'Data.yymidd()', date, yy, mi, dd )
    Data.months3[mi] + dd.toString() + ', ' + (2000+yy).toString()

export default Data