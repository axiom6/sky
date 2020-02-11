
class Data

  module.exports = Data

  @legacy      = ["free","mine","depo",   "book",   "prep",   "chan",   "canc"  ]
  @statuses    = ["Free","Mine","Deposit","Skyline","Prepaid","Booking","Cancel"]
  @statusesSel = [              "Deposit","Skyline","Prepaid","Booking","Cancel"]
  @sources     = ["Skyline","Booking","Website"]
  @tax         = 0.1055 # Official Estes Park tax rate. Also in Booking.com
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
  @month       = Data.months[Data.monthIdx]
  @numDays     = 15 # Display 15 days in Guest reservation calendar
  @begMay      = 15
  @begDay      = if Data.month is 'May' then Data.begMay else 1  # Being season on May 15
  @beg         = '170515'  # Beg seasom on May 15, 2017
  @end         = '171009'  # Beg seasom on Oct  9, 2017

  # npm -g install webpack@3.0.0 --save-dev

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
    storageBucket: "skyline-fed2b.appspot.com/",
    messagingSenderId: "279547846849" }

  @toStatus:( status ) ->
    index = Data.legacy.indexOf(status)
    if index > 0 then Data.statuses[index] else status

  @config:( uri ) ->
    if uri is 'skyline' then @configSkyline else @configSkytest

  @databases = { skyline:"skyline-fed2b", skytest:"skytest-25d1c" }

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
    paySeq = if pays.length > 0 then toString(parseInt(pays[pays.length-1])+1)  else '1'
    resId  + paySeq

  @randomCustKey:() ->
    Math.floor( Math.random() * (9999999999-1000000000)) + 1000000000

  @today:() ->
    date = new Date()
    year = date.getFullYear() - 2000 # Go Y2K
    Data.toDateStr( date.getDate(), date.getMonth(), year )

  @advanceDate:( resDate, numDays ) ->
    Util.trace( 'advanceDate', resDate ) if not Data.isDate(resDate)
    year     =           resDate.substr( 0,2 )
    monthIdx = parseInt( resDate.substr( 2,2 ) ) - 1
    day      = parseInt( resDate.substr( 4,2 ) ) + numDays
    if day  >       Data.numDayMonth[monthIdx]
       day  = day - Data.numDayMonth[monthIdx]
       monthIdx++
    Data.toDateStr( day, monthIdx, year )

  # Only good for a 28 to 30 day interval
  @nights:( arrive, depart ) ->
    num       = 0
    arriveDay = parseInt( arrive.substr( 4,2 ) )
    arriveMon = parseInt( arrive.substr( 2,2 ) )
    departDay = parseInt( depart.substr( 4,2 ) )
    departMon = parseInt( depart.substr( 2,2 ) )
    if      arriveMon   is departMon
      num = departDay - arriveDay
    else if arriveMon+1 is departMon
      num = Data.numDayMonth[arriveMon-1] - arriveDay + departDay
    Math.abs(num)

  @weekday:( date ) ->
    [yy,mi,dd] = @yymidd( date )
    weekdayIdx = new Date( 2000+yy, mi, dd ).getDay()
    Data.weekdays[weekdayIdx]

  @isDate:( date ) ->
    [yy,mi,dd] = @yymidd( date )
    valid  = true
    valid &= yy is Data.year
    valid &= 0 <= mi and mi <= 11
    valid &= 1 <= dd and dd <= 31
    valid

  @yymidd:( date ) ->
    yy = parseInt( date.substr( 0,2 ) )
    mi = parseInt( date.substr( 2,2 ) ) - 1
    dd = parseInt( date.substr( 4,2 ) )
    [yy,mi,dd]

  @toMMDD:( date ) ->
    [yy,mi,dd] = @yymidd( date )
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

  @toDateStr:( day, monthIdx=Data.monthIdx, year=Data.year ) ->
    year.toString() + Util.pad(monthIdx+1) + Util.pad(day)

  @toMonth3DayYear:( date ) ->
    [yy,mi,dd] = if Data.isDate(date) then @yymidd(date) else @yymidd(Data.today())
    Util.log( 'Data.yymidd()', date, yy, mi, dd )
    Data.months3[mi] + dd.toString() + ', ' + (2000+yy).toString()

  @bookingResvsL  = """
Guest name	Arrival	Departure	Room name	Booked on	Status	Total price	Commission	Reference number
susan settle 2 guests	12 August 2017	16 August 2017	#4 One Room Cabin	03 July 2017	OK	US$580	US$87	1791937613
Melissa Seacreas 4 guests	01 September 2017	04 September 2017	#8 Western Unit	03 July 2017	OK	US$360	US$54	1180590619
"""

  @bookingResvsK = """
Guest name	Arrival	Departure	Room name	Booked on	Status	Total price	Commission	Reference number
juan pablo bours 8 guests	10 July 2017	12 July 2017	#3 Southwest Spa	04 July 2017	OK	US$630	US$94.50	1490587666
Nick Russo 2 guests	11 July 2017	13 July 2017	#8 Western Unit	03 July 2017	OK	US$240	US$36	1251292752
louis maufrais 4 guests	13 July 2017	15 July 2017	#8 Western Unit	03 July 2017	OK	US$240	US$36	2051998205
Tyron Becker 4 guests	16 July 2017	20 July 2017	Upper Skyline North	03 July 2017	OK	US$660	US$99	1477467166
"""

  @bookingResvsJ = """
Guest name	Arrival	Departure	Room name	Booked on	Status	Total price	Commission	Reference number
susan settle 2 guests	12 August 2017	16 August 2017	#4 One Room Cabin	03 July 2017	OK	US$580	US$87	1791937613
Melissa Seacreas 4 guests	01 September 2017	04 September 2017	#8 Western Unit	03 July 2017	OK	US$360	US$54	1180590619
DAN NICHOLS 2 guests	22 August 2017	27 August 2017	#8 Western Unit	02 July 2017	OK	US$600	US$90	2069315513
Alberta Retana 2 guests	02 September 2017	04 September 2017	Upper Skyline South	02 July 2017	OK	US$310	US$46.50	1180598317
robert stone 2 guests	22 July 2017	24 July 2017	#5 Cabin with a View	03 July 2017	OK	US$390	US$58.50	1933816072
Roxane Romero 8 guests	14 July 2017	16 July 2017	#3 Southwest Spa	02 July 2017	OK	US$630	US$94.50	1297543429
Josh Murphy 4 guests	10 July 2017	12 July 2017	#5 Cabin with a View	01 July 2017	OK	US$390	US$58.50	1251493462
jay wills 4 guests	21 July 2017	23 July 2017	#2 Mountain Spa	01 July 2017	OK	US$370	US$55.50	1121958938
"""

  @CanceledA = """Pauline McClendon 5 guests	25 August 2017	27 August 2017	#6 Large River Cabin	29 June 2017	Canceled	US$0	US$0	1335821435
Erma Henry 1 guest	31 July 2017	30 August 2017	#4 One Room Cabin	25 June 2017	Canceled	US$0	US$0	1225084642
Melissa Seacreas 3 guests	01 September 2017	04 September 2017	#8 Western Unit	23 June 2017	Canceled	US$0	US$0	1822387695
Stephanie Buel 4 guests	31 July 2017	03 August 2017	#8 Western Unit	07 June 2017	Canceled	US$0	US$0	1120884797
vinay singh 4 guests	01 August 2017	03 August 2017	#4 One Room Cabin	07 June 2017	Canceled	US$0	US$0	1438534254
susannah mitchell 1 guest	31 August 2017	03 September 2017	#1 One Room Cabin	04 June 2017	Canceled	US$0	US$0	1034276945
Gregory Church 4 guests	30 July 2017	01 August 2017	#8 Western Unit	03 June 2017	Canceled	US$0	US$0	1357716307
Johnathan Koeltzow 2 guests	11 August 2017	13 August 2017	#8 Western Unit	02 June 2017	Canceled	US$0	US$0	1756807815
clarice fenton 4 guests	22 July 2017	26 July 2017	Upper Skyline South	23 June 2017	Canceled	US$0	US$0	1538156772
Susan Arnold 4 guests	07 July 2017	11 July 2017	#5 Cabin with a View	19 June 2017	Canceled	US$0	US$0	2079181490
Changying Shen 4 guests	19 July 2017	21 July 2017	#8 Western Unit	17 June 2017	Canceled	US$0	US$0	1309599829
T Lobenstein 3 guests	22 July 2017	24 July 2017	Upper Skyline South	16 June 2017	Canceled	US$0	US$0	2007936653
Han Jooyoun 4 guests	17 July 2017	19 July 2017	Upper Skyline South	12 June 2017	Canceled	US$0	US$0	1679229728
Ritu Singh 4 guests	13 July 2017	17 July 2017	#8 Western Unit	08 June 2017	Canceled	US$0	US$0	1760649274
Ryan Martin 4 guests	05 July 2017	08 July 2017	#8 Western Unit	07 June 2017	Canceled	US$0	US$0	1490387834
Lance richardson 2 guests 2 guest messages to answer	11 July 2017	13 July 2017	#8 Western Unit	05 June 2017	Canceled	US$0	US$0	1853235506
Desiree Schwalm 12 guests 1 guest message to answer	01 July 2017	03 July 2017	#6 Large River Cabin	01 June 2017	Canceled	US$0	US$0	1724384266
Jeremy Goldsmith 1 guest	01 July 2017	04 July 2017	#7 Western Spa	01 June 2017	Canceled	US$0	US$0	1849068878
Karthikeyan Shanmugavadivel 4 guests	01 July 2017	03 July 2017	#8 Western Unit	01 June 2017	Canceled	US$0	US$0	1919159565
Karen Palmer 4 guests	18 August 2017	21 August 2017	#8 Western Unit	16 June 2017	Cancelled	US$0	US$0	1747537592
Pauline McClendon 5 guests	25 August 2017	27 August 2017	#6 Large River Cabin	29 June 2017	Cancelled	US$0	US$0	1335821435
"""

  @weirdA = """
Elisabetta Casali 16 guests	09 August 2017	11 August 2017	#4 One Room Cabin, #6 Large River Cabin	30 June 2017	OK	US$890	US$133.50	1563316762
Elisabetta Casali 16 guests	10 August 2017	12 August 2017	#6 Large River Cabin, #4 One Room Cabin	30 June 2017	Canceled	US$0	US$0	2042380958
"""




  @bookingResvsI = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Gregory Hebbler 2 guests	18 July 2017	25 July 2017	#5 Cabin with a View	28 June 2017	OK	US$1365	US$204.75	1643093209
Shivrajsinh Rana 3 guests	30 June 2017	03 July 2017	#8 Western Unit	28 June 2017	OK	US$360	US$54	1643057108
Thelma Carrera 3 guests	27 June 2017	29 June 2017	Upper Skyline South	27 June 2017	OK	US$310	US$46.50	1799824520
Jessica Henderson 4 guests	21 July 2017	24 July 2017	Upper Skyline North	27 June 2017	OK	US$495	US$74.25	1980882577
"""

  @bookingResvsH = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Amber Ramos 2 guests 1 guest message to answer	28 July 2017	30 July 2017	#2 Mountain Spa	30 June 2017	OK	US$370	US$55.50	1335843833
Lynda Krupa 3 guests	31 July 2017	04 August 2017	Upper Skyline South	30 June 2017	OK	US$620	US$93	1652225524
Sara Zink 4 guests	04 August 2017	07 August 2017	Upper Skyline North	30 June 2017	OK	US$495	US$74.25	1054573838
Elisabetta Casali 16 guests	09 August 2017	11 August 2017	#6 Large River Cabin, #4 One Room Cabin	30 June 2017	OK	US$890	US$133.50	1563316762
Elisabetta Casali 16 guests	10 August 2017	12 August 2017	#6 Large River Cabin, #4 One Room Cabin	30 June 2017	Canceled	US$0	US$0	2042380958
Ryan Mitchell 4 guests	18 August 2017	20 August 2017	#2 Mountain Spa	30 June 2017	OK	US$370	US$55.50	1192666554
George Fleming 2 guests	07 September 2017	10 September 2017	Upper Skyline North	30 June 2017	OK	US$495	US$74.25	1186587856
Michael Shriver 4 guests	26 July 2017	30 July 2017	Upper Skyline North	29 June 2017	OK	US$660	US$99	1054547744
Mary Hagen 2 guests	04 August 2017	06 August 2017	#4 One Room Cabin	29 June 2017	OK	US$290	US$43.50	1340661006
Steven Ravel 4 guests	28 July 2017	30 July 2017	Upper Skyline South	28 June 2017	OK	US$310	US$46.50	1217657012
Donna Bardallis 3 guests	28 July 2017	30 July 2017	#8 Western Unit	26 June 2017	OK	US$240	US$36	1368306301
Stephanie Hedgecock 8 guests	04 August 2017	06 August 2017	#3 Southwest Spa	24 June 2017	OK	US$630	US$94.50	1772131650
Melissa Seacreas 3 guests 1 guest message to answer	01 September 2017	04 September 2017	#8 Western Unit	24 June 2017	OK	US$360	US$54	1555046433
LAYLA YEAGER 12 guests 2 guest messages to answer	01 August 2017	03 August 2017	#6 Large River Cabin	22 June 2017	OK	US$630	US$94.50	1270507767
Laura Steiner 3 guests	25 July 2017	27 July 2017	#4 One Room Cabin	20 June 2017	OK	US$290	US$43.50	1504399864
Karen Palmer 4 guests	18 August 2017	21 August 2017	#8 Western Unit	16 June 2017	OK	US$360	US$54	1747537592
Margaret Dreiling 1 guest	08 September 2017	10 September 2017	Upper Skyline South	15 June 2017	OK	US$310	US$46.50	1977820063
Sarah Troia 12 guests	04 August 2017	06 August 2017	#6 Large River Cabin	14 June 2017	OK	US$630	US$94.50	1175185436
Mohamed Basiouny 4 guests	19 August 2017	21 August 2017	Upper Skyline South	13 June 2017	OK	US$310	US$46.50	2008176523
karissa Wight 4 guests	07 September 2017	09 September 2017	#4 One Room Cabin	13 June 2017	OK	US$290	US$43.50	1779163724
Inez Cunningham 3 guests	07 September 2017	13 September 2017	#3 Southwest Spa	13 June 2017	OK	US$1890	US$283.50	1831513503
SHIU TAK LEUNG 2 guests	14 August 2017	17 August 2017	Upper Skyline South	12 June 2017	OK	US$465	US$69.75	1679266889
Tony Hajek 2 guests	08 September 2017	10 September 2017	#8 Western Unit	12 June 2017	OK	US$240	US$36	1420506143
terrus huls 2 guests	24 July 2017	26 July 2017	Upper Skyline North	11 June 2017	OK	US$330	US$49.50	1747067222
Debbie Young 4 guests	30 July 2017	05 August 2017	#8 Western Unit	08 June 2017	OK	US$720	US$108	1209962879
ARTURAS VINKEVICIUS 4 guests	01 August 2017	05 August 2017	#5 Cabin with a View	08 June 2017	OK	US$780	US$117	1335350823
Terri Richardson 4 guests	26 July 2017	28 July 2017	Upper Skyline South	07 June 2017	OK	US$310	US$46.50	1435907150
Carol Leech 4 guests	14 August 2017	16 August 2017	#8 Western Unit	07 June 2017	OK	US$260	US$39	1740250954
Virginia Clark 4 guests 1 guest message to answer	10 August 2017	13 August 2017	#8 Western Unit	06 June 2017	OK	US$390	US$58.50	1853252311
Todd Featherstun 1 guest	08 September 2017	10 September 2017	#1 One Room Cabin	02 June 2017	OK	US$290	US$43.50	1489205592
"""

  @bookingResvsG = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Amber Ramos 2 guests 1 guest message to answer	28 July 2017	30 July 2017	#2 Mountain Spa	30 June 2017	OK	US$370	US$55.50	1335843833
Lynda Krupa 3 guests	31 July 2017	04 August 2017	Upper Skyline South	30 June 2017	OK	US$620	US$93	1652225524
Sara Zink 4 guests	04 August 2017	07 August 2017	Upper Skyline North	30 June 2017	OK	US$495	US$74.25	1054573838
Ryan Mitchell 4 guests	18 August 2017	20 August 2017	#2 Mountain Spa	30 June 2017	OK	US$370	US$55.50	1192666554
George Fleming 2 guests	07 September 2017	10 September 2017	Upper Skyline North	30 June 2017	OK	US$495	US$74.25	1186587856
Michael Shriver 4 guests	26 July 2017	30 July 2017	Upper Skyline North	29 June 2017	OK	US$660	US$99	1054547744
"""

  @bookingResvsF = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Thelma Carrera 3 guests	27 June 2017	29 June 2017	Upper Skyline South	27 June 2017	OK	US$310	US$46.50	1799824520
Jessica Henderson 4 guests	21 July 2017	24 July 2017	Upper Skyline North	27 June 2017	OK	US$495	US$74.25	1980882577
"""

  @bookingResvsE = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Thelma Carrera 3 guests	27 June 2017	29 June 2017	Upper Skyline South	27 June 2017	OK	US$310	US$46.50	1799824520
Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Jessica Henderson 4 guests	21 July 2017	24 July 2017	Upper Skyline North	27 June 2017	OK	US$495	US$74.25	1980882577
Adam Broten 4 guests	21 July 2017	25 July 2017	Upper Skyline South	25 June 2017	OK	US$620	US$93	1619898321
clarice fenton 4 guests	22 July 2017	26 July 2017	Upper Skyline South	23 June 2017	Canceled	US$0	US$0	1538156772
Lauren Feldewert 2 guests	04 July 2017	07 July 2017	Upper Skyline North	22 June 2017	OK	US$495	US$74.25	1237235769
Gregory Shinn 3 guests	07 July 2017	12 July 2017	#2 Mountain Spa	21 June 2017	OK	US$925	US$138.75	1063805416
Isabella Preiss 2 guests	07 July 2017	09 July 2017	#8 Western Unit	21 June 2017	OK	US$240	US$36	1063879525
William Chitty 2 guests	07 July 2017	10 July 2017	Upper Skyline North	21 June 2017	OK	US$495	US$74.25	1337417993
Shuyan Qiu 4 guests	12 July 2017	14 July 2017	#4 One Room Cabin	21 June 2017	OK	US$290	US$43.50	1987323639
Cynthia south 2 guests	07 July 2017	09 July 2017	Upper Skyline South	20 June 2017	OK	US$310	US$46.50	1840978596
melissa larson 3 guests	15 July 2017	17 July 2017	#2 Mountain Spa	20 June 2017	OK	US$370	US$55.50	1559251465
Susan Arnold 4 guests	07 July 2017	11 July 2017	#5 Cabin with a View	19 June 2017	Canceled	US$0	US$0	2079181490
Changying Shen 4 guests	19 July 2017	21 July 2017	#8 Western Unit	17 June 2017	Canceled	US$0	US$0	1309599829
Dennis Micheal Freiberg 2 guests	21 July 2017	23 July 2017	#8 Western Unit	17 June 2017	OK	US$240	US$36	1515589419
James Woods 1 guest	30 June 2017	03 July 2017	#7 Western Spa	16 June 2017	OK	US$525	US$78.75	1090962106
T Lobenstein 3 guests	22 July 2017	24 July 2017	Upper Skyline South	16 June 2017	Canceled	US$0	US$0	2007936653
Scott Wilkins 4 guests	17 July 2017	21 July 2017	Upper Skyline South	15 June 2017	OK	US$620	US$93	1332065103
steven wolery 1 guest	17 July 2017	19 July 2017	#7 Western Spa	14 June 2017	OK	US$350	US$52.50	1082997039
Jonathan Calvin 5 guests	10 July 2017	13 July 2017	#6 Large River Cabin	13 June 2017	OK	US$945	US$141.75	1233373950
Susan Haynes 3 guests	28 June 2017	01 July 2017	#5 Cabin with a View	12 June 2017	OK	US$585	US$87.75	1315640448
Carmel Contreras 4 guests	14 July 2017	16 July 2017	Upper Skyline North	12 June 2017	OK	US$330	US$49.50	1199985479
Han Jooyoun 4 guests	17 July 2017	19 July 2017	Upper Skyline South	12 June 2017	Canceled	US$0	US$0	1679229728
Scott Bonnel 1 guest 1 guest message to answer	03 July 2017	08 July 2017	#7 Western Spa	09 June 2017	OK	US$875	US$131.25	1152594137
Duelberg 1 guest	09 July 2017	16 July 2017	Upper Skyline South	09 June 2017	OK	US$1085	US$162.75	1152517257
Thomas Hall 2 guests	15 July 2017	18 July 2017	#8 Western Unit	09 June 2017	OK	US$360	US$54	1285019793
Ritu Singh 4 guests	13 July 2017	17 July 2017	#8 Western Unit	08 June 2017	Canceled	US$0	US$0	1760649274
Thomas Sturrock 12 guests 2 guest messages to answer	14 July 2017	16 July 2017	#6 Large River Cabin	08 June 2017	OK	US$630	US$94.50	1335353110
Allison Mann 4 guests	23 July 2017	27 July 2017	#8 Western Unit	08 June 2017	OK	US$480	US$72	1529537163
Ryan Martin 4 guests	05 July 2017	08 July 2017	#8 Western Unit	07 June 2017	Canceled	US$0	US$0	1490387834
Patricia Curtis 4 guests	08 July 2017	11 July 2017	#4 One Room Cabin	07 June 2017	OK	US$435	US$65.25	2065156596
Tiffany Keleher 8 guests	21 July 2017	23 July 2017	#3 Southwest Spa	07 June 2017	OK	US$630	US$94.50	1741695563
CHARLES FREEMAN 4 guests	26 June 2017	30 June 2017	#4 One Room Cabin	06 June 2017	OK	US$580	US$87	1525366564
Hari Nepal 4 guests	27 June 2017	29 June 2017	#8 Western Unit	06 June 2017	OK	US$260	US$39	1277611253
Teresa Kile 4 guests	03 July 2017	07 July 2017	Upper Skyline South	06 June 2017	OK	US$620	US$93	1529786552
Kelli Pachner 4 guests	29 June 2017	07 July 2017	#2 Mountain Spa	05 June 2017	OK	US$1480	US$222	1150950465
Debra Hakar 2 guests	09 July 2017	11 July 2017	#8 Western Unit	05 June 2017	OK	US$260	US$39	1529718572
Lance richardson 2 guests 2 guest messages to answer	11 July 2017	13 July 2017	#8 Western Unit	05 June 2017	Canceled	US$0	US$0	1853235506
Nirmala Narasimhan 10 guests 1 guest message to answer	23 July 2017	26 July 2017	#6 Large River Cabin	05 June 2017	OK	US$945	US$141.75	1258789416
Taylor Robertson 3 guests	14 July 2017	16 July 2017	#4 One Room Cabin	04 June 2017	OK	US$290	US$43.50	1034229994
Olga Diachuk 2 guests	01 July 2017	04 July 2017	Upper Skyline North	03 June 2017	OK	US$495	US$74.25	1276208822
Wanda Markotter 8 guests	02 July 2017	05 July 2017	#3 Southwest Spa	03 June 2017	OK	US$945	US$141.75	1480632756
Michael Villanueva 12 guests	20 July 2017	22 July 2017	#6 Large River Cabin	03 June 2017	OK	US$630	US$94.50	1197903266
Wanda Markotter 8 guests	02 July 2017	05 July 2017	#3 Southwest Spa	02 June 2017	Canceled	US$0	US$0	1936424490
Consuelo Chavarria 4 guests 2 guest messages to answer	03 July 2017	05 July 2017	#8 Western Unit	02 June 2017	Canceled	US$0	US$0	1289646030
Linda Kroeger 12 guests	05 July 2017	09 July 2017	#6 Large River Cabin	02 June 2017	OK	US$1260	US$189	1784265520
Eric Johnson 2 guests	10 July 2017	14 July 2017	Upper Skyline North	02 June 2017	OK	US$660	US$99	1159618525
Vanessa Garcia 4 guests	16 July 2017	19 July 2017	#4 One Room Cabin	02 June 2017	OK	US$435	US$65.25	2047390051
Aman Hota 4 guests	30 June 2017	03 July 2017	Upper Skyline South	01 June 2017	OK	US$465	US$69.75	1540200140
Desiree Schwalm 12 guests 1 guest message to answer	01 July 2017	03 July 2017	#6 Large River Cabin	01 June 2017	Canceled	US$0	US$0	1724384266
Jeremy Goldsmith 1 guest	01 July 2017	04 July 2017	#7 Western Spa	01 June 2017	Canceled	US$0	US$0	1849068878
Karthikeyan Shanmugavadivel 4 guests	01 July 2017	03 July 2017	#8 Western Unit	01 June 2017	OK	US$290	US$43.50	1919159565
Jeffrey Sterup 2 guests	21 July 2017	23 July 2017	#4 One Room Cabin	01 June 2017	OK	US$290	US$43.50	1065585580
"""

  @bookingResvsD = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Adam Broten 4 guests	21 July 2017	25 July 2017	Upper Skyline South	25 June 2017	OK	US$620	US$93	1619898321
clarice fenton 4 guests	22 July 2017	26 July 2017	Upper Skyline South	23 June 2017	Canceled	US$0	US$0	1538156772
Lauren Feldewert 2 guests	04 July 2017	07 July 2017	Upper Skyline North	22 June 2017	OK	US$495	US$74.25	1237235769
Gregory Shinn 3 guests	07 July 2017	12 July 2017	#2 Mountain Spa	21 June 2017	OK	US$925	US$138.75	1063805416
Isabella Preiss 2 guests	07 July 2017	09 July 2017	#8 Western Unit	21 June 2017	OK	US$240	US$36	1063879525
William Chitty 2 guests	07 July 2017	10 July 2017	Upper Skyline North	21 June 2017	OK	US$495	US$74.25	1337417993
Shuyan Qiu 4 guests	12 July 2017	14 July 2017	#4 One Room Cabin	21 June 2017	OK	US$290	US$43.50	1987323639
Cynthia south 2 guests	07 July 2017	09 July 2017	Upper Skyline South	20 June 2017	OK	US$310	US$46.50	1840978596
melissa larson 3 guests	15 July 2017	17 July 2017	#2 Mountain Spa	20 June 2017	OK	US$370	US$55.50	1559251465
Susan Arnold 4 guests	07 July 2017	11 July 2017	#5 Cabin with a View	19 June 2017	Canceled	US$0	US$0	2079181490
Changying Shen 4 guests	19 July 2017	21 July 2017	#8 Western Unit	17 June 2017	Canceled	US$0	US$0	1309599829
Dennis Micheal Freiberg 2 guests	21 July 2017	23 July 2017	#8 Western Unit	17 June 2017	OK	US$240	US$36	1515589419
James Woods 1 guest	30 June 2017	03 July 2017	#7 Western Spa	16 June 2017	OK	US$525	US$78.75	1090962106
T Lobenstein 3 guests	22 July 2017	24 July 2017	Upper Skyline South	16 June 2017	Canceled	US$0	US$0	2007936653
Scott Wilkins 4 guests	17 July 2017	21 July 2017	Upper Skyline South	15 June 2017	OK	US$620	US$93	1332065103
steven wolery 1 guest	17 July 2017	19 July 2017	#7 Western Spa	14 June 2017	OK	US$350	US$52.50	1082997039
Jonathan Calvin 5 guests	10 July 2017	13 July 2017	#6 Large River Cabin	13 June 2017	OK	US$945	US$141.75	1233373950
Susan Haynes 3 guests	28 June 2017	01 July 2017	#5 Cabin with a View	12 June 2017	OK	US$585	US$87.75	1315640448
Carmel Contreras 4 guests	14 July 2017	16 July 2017	Upper Skyline North	12 June 2017	OK	US$330	US$49.50	1199985479
Han Jooyoun 4 guests	17 July 2017	19 July 2017	Upper Skyline South	12 June 2017	Canceled	US$0	US$0	1679229728
Scott Bonnel 1 guest 1 guest message to answer	03 July 2017	08 July 2017	#7 Western Spa	09 June 2017	OK	US$875	US$131.25	1152594137
Duelberg 1 guest	09 July 2017	16 July 2017	Upper Skyline South	09 June 2017	OK	US$1085	US$162.75	1152517257
Thomas Hall 2 guests	15 July 2017	18 July 2017	#8 Western Unit	09 June 2017	OK	US$360	US$54	1285019793
Ritu Singh 4 guests	13 July 2017	17 July 2017	#8 Western Unit	08 June 2017	Canceled	US$0	US$0	1760649274
Thomas Sturrock 12 guests 2 guest messages to answer	14 July 2017	16 July 2017	#6 Large River Cabin	08 June 2017	OK	US$630	US$94.50	1335353110
Ryan Martin 4 guests	05 July 2017	08 July 2017	#8 Western Unit	07 June 2017	Canceled	US$0	US$0	1490387834
Patricia Curtis 4 guests	08 July 2017	11 July 2017	#4 One Room Cabin	07 June 2017	OK	US$435	US$65.25	2065156596
Tiffany Keleher 8 guests	21 July 2017	23 July 2017	#3 Southwest Spa	07 June 2017	OK	US$630	US$94.50	1741695563
CHARLES FREEMAN 4 guests	26 June 2017	30 June 2017	#4 One Room Cabin	06 June 2017	OK	US$580	US$87	1525366564
Hari Nepal 4 guests	27 June 2017	29 June 2017	#8 Western Unit	06 June 2017	OK	US$260	US$39	1277611253
Teresa Kile 4 guests	03 July 2017	07 July 2017	Upper Skyline South	06 June 2017	OK	US$620	US$93	1529786552
Kelli Pachner 4 guests	29 June 2017	07 July 2017	#2 Mountain Spa	05 June 2017	OK	US$1480	US$222	1150950465
Debra Hakar 2 guests	09 July 2017	11 July 2017	#8 Western Unit	05 June 2017	OK	US$260	US$39	1529718572
Lance richardson 2 guests 2 guest messages to answer	11 July 2017	13 July 2017	#8 Western Unit	05 June 2017	Canceled	US$0	US$0	1853235506
Nirmala Narasimhan 10 guests 1 guest message to answer	23 July 2017	26 July 2017	#6 Large River Cabin	05 June 2017	OK	US$945	US$141.75	1258789416
Taylor Robertson 3 guests	14 July 2017	16 July 2017	#4 One Room Cabin	04 June 2017	OK	US$290	US$43.50	1034229994
Olga Diachuk 2 guests	01 July 2017	04 July 2017	Upper Skyline North	03 June 2017	OK	US$495	US$74.25	1276208822
Wanda Markotter 8 guests	02 July 2017	05 July 2017	#3 Southwest Spa	03 June 2017	OK	US$945	US$141.75	1480632756
Michael Villanueva 12 guests	20 July 2017	22 July 2017	#6 Large River Cabin	03 June 2017	OK	US$630	US$94.50	1197903266
Wanda Markotter 8 guests	02 July 2017	05 July 2017	#3 Southwest Spa	02 June 2017	Canceled	US$0	US$0	1936424490
Consuelo Chavarria 4 guests 2 guest messages to answer	03 July 2017	05 July 2017	#8 Western Unit	02 June 2017	Canceled	US$0	US$0	1289646030
Linda Kroeger 12 guests	05 July 2017	09 July 2017	#6 Large River Cabin	02 June 2017	OK	US$1260	US$189	1784265520
Eric Johnson 2 guests	10 July 2017	14 July 2017	Upper Skyline North	02 June 2017	OK	US$660	US$99	1159618525
Vanessa Garcia 4 guests	16 July 2017	19 July 2017	#4 One Room Cabin	02 June 2017	OK	US$435	US$65.25	2047390051
Jana Green 4 guests	25 June 2017	27 June 2017	#2 Mountain Spa	01 June 2017	OK	US$370	US$55.50	1065504281
Aman Hota 4 guests	30 June 2017	03 July 2017	Upper Skyline South	01 June 2017	OK	US$465	US$69.75	1540200140
Desiree Schwalm 12 guests 1 guest message to answer	01 July 2017	03 July 2017	#6 Large River Cabin	01 June 2017	Canceled	US$0	US$0	1724384266
Jeremy Goldsmith 1 guest	01 July 2017	04 July 2017	#7 Western Spa	01 June 2017	Canceled	US$0	US$0	1849068878
Karthikeyan Shanmugavadivel 4 guests	01 July 2017	03 July 2017	#8 Western Unit	01 June 2017	OK	US$290	US$43.50	1919159565
Jeffrey Sterup 2 guests	21 July 2017	23 July 2017	#4 One Room Cabin	01 June 2017	OK	US$290	US$43.50	1065585580
"""

  @bookingResvsC = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Lauren Feldewert 2 guests	04 July 2017	07 July 2017	Upper Skyline North	22 June 2017	OK	US$495	US$74.25	1237235769
Gregory Shinn 3 guests	07 July 2017	12 July 2017	#2 Mountain Spa	21 June 2017	OK	US$925	US$138.75	1063805416
Isabella Preiss 2 guests	07 July 2017	09 July 2017	#8 Western Unit	21 June 2017	OK	US$240	US$36	1063879525
William Chitty 2 guests	07 July 2017	10 July 2017	Upper Skyline North	21 June 2017	OK	US$495	US$74.25	1337417993
Shuyan Qiu 4 guests	12 July 2017	14 July 2017	#4 One Room Cabin	21 June 2017	OK	US$290	US$43.50	1987323639
Cynthia south 2 guests	07 July 2017	09 July 2017	Upper Skyline South	20 June 2017	OK	US$310	US$46.50	1840978596
melissa larson 3 guests	15 July 2017	17 July 2017	#2 Mountain Spa	20 June 2017	OK	US$370	US$55.50	1559251465
Susan Arnold 4 guests	07 July 2017	11 July 2017	#5 Cabin with a View	19 June 2017	OK	US$780	US$117	2079181490
James Woods 1 guest	30 June 2017	03 July 2017	#7 Western Spa	16 June 2017	OK	US$525	US$78.75	1090962106
Scott Wilkins 4 guests	17 July 2017	21 July 2017	Upper Skyline South	15 June 2017	OK	US$620	US$93	1332065103
steven wolery 1 guest	17 July 2017	19 July 2017	#7 Western Spa	14 June 2017	OK	US$350	US$52.50	1082997039
NAIWEN CUI 2 guests	23 June 2017	25 June 2017	#2 Mountain Spa	13 June 2017	OK	US$370	US$55.50	1949904287
Jonathan Calvin 5 guests	10 July 2017	13 July 2017	#6 Large River Cabin	13 June 2017	OK	US$945	US$141.75	1233373950
Susan Haynes 3 guests	28 June 2017	01 July 2017	#5 Cabin with a View	12 June 2017	OK	US$585	US$87.75	1315640448
Carmel Contreras 4 guests	14 July 2017	16 July 2017	Upper Skyline North	12 June 2017	OK	US$330	US$49.50	1199985479
Pauline Segura 4 guests 1 guest message to answer	23 June 2017	25 June 2017	#5 Cabin with a View	11 June 2017	OK	US$390	US$58.50	2086414716
Scott Bonnel 1 guest	03 July 2017	08 July 2017	#7 Western Spa	09 June 2017	OK	US$875	US$131.25	1152594137
Duelberg 1 guest	09 July 2017	16 July 2017	Upper Skyline South	09 June 2017	OK	US$1085	US$162.75	1152517257
Thomas Hall 2 guests	15 July 2017	18 July 2017	#8 Western Unit	09 June 2017	OK	US$360	US$54	1285019793
Andrew Impagliazzo 4 guests	23 June 2017	26 June 2017	#8 Western Unit	08 June 2017	OK	US$360	US$54	1055950974
Ritu Singh 4 guests	13 July 2017	17 July 2017	#8 Western Unit	08 June 2017	Canceled	US$0	US$0	1760649274
Thomas Sturrock 12 guests 2 guest messages to answer	14 July 2017	16 July 2017	#6 Large River Cabin	08 June 2017	OK	US$630	US$94.50	1335353110
Ryan Martin 4 guests	05 July 2017	08 July 2017	#8 Western Unit	07 June 2017	Canceled	US$0	US$0	1490387834
Patricia Curtis 4 guests	08 July 2017	11 July 2017	#4 One Room Cabin	07 June 2017	OK	US$435	US$65.25	2065156596
Kristi Stoll 2 guests	22 June 2017	24 June 2017	#8 Western Unit	06 June 2017	Canceled	US$0	US$0	1120838596
CHARLES FREEMAN 4 guests	26 June 2017	30 June 2017	#4 One Room Cabin	06 June 2017	OK	US$580	US$87	1525366564
Hari Nepal 4 guests	27 June 2017	29 June 2017	#8 Western Unit	06 June 2017	OK	US$260	US$39	1277611253
Teresa Kile 4 guests	03 July 2017	07 July 2017	Upper Skyline South	06 June 2017	OK	US$620	US$93	1529786552
Kelli Pachner 4 guests	29 June 2017	07 July 2017	#2 Mountain Spa	05 June 2017	OK	US$1480	US$222	1150950465
Debra Hakar 2 guests	09 July 2017	11 July 2017	#8 Western Unit	05 June 2017	OK	US$260	US$39	1529718572
Lance richardson 2 guests 2 guest messages to answer	11 July 2017	13 July 2017	#8 Western Unit	05 June 2017	Canceled	US$0	US$0	1853235506
Yessenia Chan;Che Yun Chan;So Sum Daphne Chan 8 guests 2 guest messages to answer	23 June 2017	25 June 2017	#3 Southwest Spa	04 June 2017	OK	US$630	US$94.50	1362060631
Taylor Robertson 3 guests	14 July 2017	16 July 2017	#4 One Room Cabin	04 June 2017	OK	US$290	US$43.50	1034229994
Tanya Thomas 2 guests 2 guest messages to answer	23 June 2017	25 June 2017	Upper Skyline North	03 June 2017	OK	US$330	US$49.50	1584941695
Olga Diachuk 2 guests	01 July 2017	04 July 2017	Upper Skyline North	03 June 2017	OK	US$495	US$74.25	1276208822
Wanda Markotter 8 guests	02 July 2017	05 July 2017	#3 Southwest Spa	03 June 2017	OK	US$945	US$141.75	1480632756
Consuelo Chavarria 4 guests 2 guest messages to answer	03 July 2017	05 July 2017	#8 Western Unit	02 June 2017	Canceled	US$0	US$0	1289646030
Linda Kroeger 12 guests	05 July 2017	09 July 2017	#6 Large River Cabin	02 June 2017	OK	US$1260	US$189	1784265520
Eric Johnson 2 guests	10 July 2017	14 July 2017	Upper Skyline North	02 June 2017	OK	US$660	US$99	1159618525
Vanessa Garcia 4 guests	16 July 2017	19 July 2017	#4 One Room Cabin	02 June 2017	OK	US$435	US$65.25	2047390051
Cherry Lofstrom 1 guest	23 June 2017	25 June 2017	#1 One Room Cabin	01 June 2017	OK	US$290	US$43.50	1065507845
Encarnita Pascuzzi 4 guests	23 June 2017	26 June 2017	#8 Western Unit	01 June 2017	Canceled	US$0	US$0	1361910794
Joseph Shuck 4 guests	23 June 2017	25 June 2017	Upper Skyline South	01 June 2017	OK	US$310	US$46.50	1716314897
Jana Green 4 guests	25 June 2017	27 June 2017	#2 Mountain Spa	01 June 2017	OK	US$370	US$55.50	1065504281
Aman Hota 4 guests	30 June 2017	03 July 2017	Upper Skyline South	01 June 2017	OK	US$465	US$69.75	1540200140
Desiree Schwalm 12 guests 1 guest message to answer	01 July 2017	03 July 2017	#6 Large River Cabin	01 June 2017	Canceled	US$0	US$0	1724384266
Jeremy Goldsmith 1 guest	01 July 2017	04 July 2017	#7 Western Spa	01 June 2017	Canceled	US$0	US$0	1849068878
Karthikeyan Shanmugavadivel 4 guests	01 July 2017	03 July 2017	#8 Western Unit	01 June 2017	OK	US$290	US$43.50	1919159565
Jacen Roper 4 guests	23 June 2017	26 June 2017	#4 One Room Cabin	31 May 2017	OK	US$435	US$65.25	1771276433
Laura Steiner 3 guests	25 July 2017	27 July 2017	#4 One Room Cabin	20 June 2017	OK	US$290	US$43.50	1504399864
Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Han Jooyoun 4 guests	17 July 2017	19 July 2017	Upper Skyline South	12 June 2017	Canceled	US$0	US$0	1679229728
Changying Shen 4 guests	19 July 2017	21 July 2017	#8 Western Unit	17 June 2017	Canceled	US$0	US$0	1309599829
Michael Villanueva 12 guests	20 July 2017	22 July 2017	#6 Large River Cabin	03 June 2017	OK	US$630	US$94.50	1197903266
Jeffrey Sterup 2 guests	21 July 2017	23 July 2017	#4 One Room Cabin	01 June 2017	OK	US$290	US$43.50	1065585580
Dennis Micheal Freiberg 2 guests	21 July 2017	23 July 2017	#8 Western Unit	17 June 2017	OK	US$240	US$36	1515589419
Tiffany Keleher 8 guests	21 July 2017	23 July 2017	#3 Southwest Spa	07 June 2017	OK	US$630	US$94.50	1741695563
T Lobenstein 3 guests	22 July 2017	24 July 2017	Upper Skyline South	16 June 2017	Canceled	US$0	US$0	2007936653
Nirmala Narasimhan 10 guests 1 guest message to answer	23 July 2017	26 July 2017	#6 Large River Cabin	05 June 2017	OK	US$945	US$141.75	1258789416
Allison Mann 4 guests	23 July 2017	27 July 2017	#8 Western Unit	08 June 2017	OK	US$480	US$72	1529537163
terrus huls 2 guests	24 July 2017	26 July 2017	Upper Skyline North	11 June 2017	OK	US$330	US$49.50	1747067222
Laura Steiner 3 guests	25 July 2017	27 July 2017	#4 One Room Cabin	20 June 2017	OK	US$290	US$43.50	1504399864
Terri Richardson 4 guests	26 July 2017	28 July 2017	Upper Skyline South	07 June 2017	OK	US$310	US$46.50	1435907150
Debbie Young 4 guests	30 July 2017	05 August 2017	#8 Western Unit	08 June 2017	OK	US$720	US$108	1209962879
Gregory Church 4 guests	30 July 2017	01 August 2017	#8 Western Unit	03 June 2017	Canceled	US$0	US$0	1357716307
Stephanie Buel 4 guests	31 July 2017	03 August 2017	#8 Western Unit	07 June 2017	Canceled	US$0	US$0	1120884797
LAYLA YEAGER 12 guests	01 August 2017	03 August 2017	#6 Large River Cabin	22 June 2017	OK	US$630	US$94.50	1270507767
ARTURAS VINKEVICIUS 4 guests	01 August 2017	05 August 2017	#5 Cabin with a View	08 June 2017	OK	US$780	US$117	1335350823
vinay singh 4 guests	01 August 2017	03 August 2017	#4 One Room Cabin	07 June 2017	Canceled	US$0	US$0	1438534254
Sarah Troia 12 guests	04 August 2017	06 August 2017	#6 Large River Cabin	14 June 2017	OK	US$630	US$94.50	1175185436
Virginia Clark 4 guests 1 guest message to answer	10 August 2017	13 August 2017	#8 Western Unit	06 June 2017	OK	US$390	US$58.50	1853252311
Johnathan Koeltzow 2 guests	11 August 2017	13 August 2017	#8 Western Unit	02 June 2017	Canceled	US$0	US$0	1756807815
SHIU TAK LEUNG 2 guests	14 August 2017	17 August 2017	Upper Skyline South	12 June 2017	OK	US$465	US$69.75	1679266889
Carol Leech 4 guests	14 August 2017	16 August 2017	#8 Western Unit	07 June 2017	OK	US$260	US$39	1740250954
Karen Palmer 4 guests	18 August 2017	21 August 2017	#8 Western Unit	16 June 2017	OK	US$360	US$54	1747537592
Mohamed Basiouny 4 guests	19 August 2017	21 August 2017	Upper Skyline South	13 June 2017	OK	US$310	US$46.50	2008176523
susannah mitchell 1 guest	31 August 2017	03 September 2017	#1 One Room Cabin	04 June 2017	Canceled	US$0	US$0	1034276945
karissa Wight 4 guests	07 September 2017	09 September 2017	#4 One Room Cabin	13 June 2017	OK	US$290	US$43.50	1779163724
Inez Cunningham 3 guests	07 September 2017	13 September 2017	#3 Southwest Spa	13 June 2017	OK	US$1890	US$283.50	1831513503
Tony Hajek 2 guests	08 September 2017	10 September 2017	#8 Western Unit	12 June 2017	OK	US$240	US$36	1420506143
Todd Featherstun 1 guest	08 September 2017	10 September 2017	#1 One Room Cabin	02 June 2017	OK	US$290	US$43.50	1489205592
Margaret Dreiling 1 guest	08 September 2017	10 September 2017	Upper Skyline South	15 June 2017	OK	US$310	US$46.50	1977820063
"""

  @bookingResvsB = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Laura Steiner 3 guests	25 July 2017	27 July 2017	#4 One Room Cabin	20 June 2017	OK	US$290	US$43.50	1504399864
Stephanie Sanchez 4 guests	21 June 2017	23 June 2017	Upper Skyline North	21 June 2017	OK	US$330	US$49.50	1074850281
Gregory Shinn 3 guests	07 July 2017	12 July 2017	#2 Mountain Spa	21 June 2017	OK	US$925	US$138.75	1063805416
Isabella Preiss 2 guests	07 July 2017	09 July 2017	#8 Western Unit	21 June 2017	OK	US$240	US$36	1063879525
William Chitty 2 guests	07 July 2017	10 July 2017	Upper Skyline North	21 June 2017	OK	US$495	US$74.25	1337417993
Shuyan Qiu 4 guests	12 July 2017	14 July 2017	#4 One Room Cabin	21 June 2017	OK	US$290	US$43.50	1987323639
Cynthia south 2 guests	07 July 2017	09 July 2017	Upper Skyline South	20 June 2017	OK	US$310	US$46.50	1840978596
melissa larson 3 guests	15 July 2017	17 July 2017	#2 Mountain Spa	20 June 2017	OK	US$370	US$55.50	1559251465
Susan Arnold 4 guests	07 July 2017	11 July 2017	#5 Cabin with a View	19 June 2017	OK	US$780	US$117	2079181490
James Woods 1 guest	30 June 2017	03 July 2017	#7 Western Spa	16 June 2017	OK	US$525	US$78.75	1090962106
"""

  @bookingResvsA = """Sheri Carpenter 2 guests	16 June 2017	18 June 2017	#2 Mountain Spa	15 June 2017	OK	US$370	US$55.50	1492157385
Susan Arnold 4 guests	07 July 2017	11 July 2017	#5 Cabin with a View	19 June 2017	OK	US$780	US$117	2079181490
Jennifer Rutledge;Terry Rutledge 4 guests	20 June 2017	22 June 2017	#4 One Room Cabin	18 June 2017	OK	US$290	US$43.50	1777384627
Changying Shen 4 guests	19 July 2017	21 July 2017	#8 Western Unit	17 June 2017	Canceled	US$0	US$0	1309599829
Dennis Micheal Freiberg 2 guests	21 July 2017	23 July 2017	#8 Western Unit	17 June 2017	OK	US$240	US$36	1515589419
James Woods 1 guest	30 June 2017	03 July 2017	#7 Western Spa	16 June 2017	OK	US$525	US$78.75	1090962106
"""

  @bookingResvs1 = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Scott Wilkins 4 guests	17 July 2017	21 July 2017	Upper Skyline South	15 June 2017	OK	US$620	US$93	1332065103
steven wolery 1 guest	17 July 2017	19 July 2017	#7 Western Spa	14 June 2017	OK	US$350	US$52.50	1082997039
NAIWEN CUI 2 guests	23 June 2017	25 June 2017	#2 Mountain Spa	13 June 2017	OK	US$370	US$55.50	1949904287
Jonathan Calvin 5 guests	10 July 2017	13 July 2017	#6 Large River Cabin	13 June 2017	OK	US$945	US$141.75	1233373950
Susan Haynes 3 guests	28 June 2017	01 July 2017	#5 Cabin with a View	12 June 2017	OK	US$585	US$87.75	1315640448
Carmel Contreras 4 guests	14 July 2017	16 July 2017	Upper Skyline North	12 June 2017	OK	US$330	US$49.50	1199985479
Han Jooyoun 4 guests 1 guest message to answer	17 July 2017	19 July 2017	Upper Skyline South	12 June 2017	Canceled	US$0	US$0	1679229728
Pauline Segura 4 guests	23 June 2017	25 June 2017	#5 Cabin with a View	11 June 2017	OK	US$390	US$58.50	2086414716
Ann Ross 4 guests	18 June 2017	20 June 2017	#4 One Room Cabin	10 June 2017	OK	US$290	US$43.50	1747041527
Scott Bonnel 1 guest	03 July 2017	08 July 2017	#7 Western Spa	09 June 2017	OK	US$875	US$131.25	1152594137
Duelberg 1 guest	09 July 2017	16 July 2017	Upper Skyline South	09 June 2017	OK	US$1085	US$162.75	1152517257
Thomas Hall 2 guests	15 July 2017	18 July 2017	#8 Western Unit	09 June 2017	OK	US$360	US$54	1285019793
Glenn Price 3 guests	16 June 2017	18 June 2017	Upper Skyline North	08 June 2017	OK	US$330	US$49.50	1881784832
Daryl Schwindt 4 guests	18 June 2017	21 June 2017	#8 Western Unit	08 June 2017	OK	US$360	US$54	1285995429
Andrew Impagliazzo 4 guests	23 June 2017	26 June 2017	#8 Western Unit	08 June 2017	OK	US$360	US$54	1055950974
Ritu Singh 4 guests	13 July 2017	17 July 2017	#8 Western Unit	08 June 2017	Canceled	US$0	US$0	1760649274
Thomas Sturrock 12 guests 3 guest messages to answer	14 July 2017	16 July 2017	#6 Large River Cabin	08 June 2017	OK	US$630	US$94.50	1335353110
Ryan Martin 4 guests	05 July 2017	08 July 2017	#8 Western Unit	07 June 2017	Canceled	US$0	US$0	1490387834
Patricia Curtis 4 guests	08 July 2017	11 July 2017	#4 One Room Cabin	07 June 2017	OK	US$435	US$65.25	2065156596
john peterson 4 guests	16 June 2017	18 June 2017	Upper Skyline South	06 June 2017	OK	US$310	US$46.50	2035897444
Kristi Stoll 2 guests	22 June 2017	24 June 2017	#8 Western Unit	06 June 2017	Canceled	US$0	US$0	1120838596
CHARLES FREEMAN 4 guests	26 June 2017	30 June 2017	#4 One Room Cabin	06 June 2017	OK	US$580	US$87	1525366564
Hari Nepal 4 guests	27 June 2017	29 June 2017	#8 Western Unit	06 June 2017	OK	US$260	US$39	1277611253
Teresa Kile 4 guests	03 July 2017	07 July 2017	Upper Skyline South	06 June 2017	OK	US$620	US$93	1529786552
Kelli Pachner 4 guests	29 June 2017	07 July 2017	#2 Mountain Spa	05 June 2017	OK	US$1480	US$222	1150950465
Debra Hakar 2 guests	09 July 2017	11 July 2017	#8 Western Unit	05 June 2017	OK	US$260	US$39	1529718572
Lance richardson 2 guests 1 guest message to answer	11 July 2017	13 July 2017	#8 Western Unit	05 June 2017	OK	US$260	US$39	1853235506
Desiree Schwalm 8 guests	16 June 2017	18 June 2017	#3 Southwest Spa	04 June 2017	Canceled	US$0	US$0	1516613627
Yessenia Chan;Che Yun Chan;So Sum Daphne Chan 8 guests 3 guest messages to answer	23 June 2017	25 June 2017	#3 Southwest Spa	04 June 2017	OK	US$630	US$94.50	1362060631
Taylor Robertson 3 guests	14 July 2017	16 July 2017	#4 One Room Cabin	04 June 2017	OK	US$290	US$43.50	1034229994
linda Nelsen 4 guests	16 June 2017	18 June 2017	#8 Western Unit	03 June 2017	OK	US$290	US$43.50	1346970369
Tanya Thomas 2 guests 3 guest messages to answer	23 June 2017	25 June 2017	Upper Skyline North	03 June 2017	OK	US$330	US$49.50	1584941695
Olga Diachuk 2 guests	01 July 2017	04 July 2017	Upper Skyline North	03 June 2017	OK	US$495	US$74.25	1276208822
Wanda Markotter 8 guests	02 July 2017	05 July 2017	#3 Southwest Spa	03 June 2017	OK	US$945	US$141.75	1480632756
Michael Villanueva 12 guests	20 July 2017	22 July 2017	#6 Large River Cabin	03 June 2017	OK	US$630	US$94.50	1197903266
Wanda Markotter 8 guests	02 July 2017	05 July 2017	#3 Southwest Spa	02 June 2017	Canceled	US$0	US$0	1936424490
Consuelo Chavarria 4 guests 2 guest messages to answer	03 July 2017	05 July 2017	#8 Western Unit	02 June 2017	OK	US$290	US$43.50	1289646030
Linda Kroeger 12 guests	05 July 2017	09 July 2017	#6 Large River Cabin	02 June 2017	OK	US$1260	US$189	1784265520
Eric Johnson 2 guests	10 July 2017	14 July 2017	Upper Skyline North	02 June 2017	OK	US$660	US$99	1159618525
Vanessa Garcia 4 guests	16 July 2017	19 July 2017	#4 One Room Cabin	02 June 2017	OK	US$435	US$65.25	2047390051
Cherry Lofstrom 1 guest	23 June 2017	25 June 2017	#1 One Room Cabin	01 June 2017	OK	US$290	US$43.50	1065507845
Encarnita Pascuzzi 4 guests	23 June 2017	26 June 2017	#8 Western Unit	01 June 2017	Canceled	US$0	US$0	1361910794
Joseph Shuck 4 guests	23 June 2017	25 June 2017	Upper Skyline South	01 June 2017	OK	US$310	US$46.50	1716314897
Jana Green 4 guests	25 June 2017	27 June 2017	#2 Mountain Spa	01 June 2017	OK	US$370	US$55.50	1065504281
Aman Hota 4 guests	30 June 2017	03 July 2017	Upper Skyline South	01 June 2017	OK	US$465	US$69.75	1540200140
Desiree Schwalm 12 guests 1 guest message to answer	01 July 2017	03 July 2017	#6 Large River Cabin	01 June 2017	Canceled	US$0	US$0	1724384266
Jeremy Goldsmith 1 guest	01 July 2017	04 July 2017	#7 Western Spa	01 June 2017	Canceled	US$0	US$0	1849068878
Karthikeyan Shanmugavadivel 4 guests	01 July 2017	03 July 2017	#8 Western Unit	01 June 2017	OK	US$290	US$43.50	1919159565
Jeffrey Sterup 2 guests	21 July 2017	23 July 2017	#4 One Room Cabin	01 June 2017	OK	US$290	US$43.50	1065585580
Jacen Roper 4 guests	23 June 2017	26 June 2017	#4 One Room Cabin	31 May 2017	OK	US$435	US$65.25	1771276433
Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Tiffany Keleher 8 guests	21 July 2017	23 July 2017	#3 Southwest Spa	07 June 2017	OK	US$630	US$94.50	1741695563
Nirmala Narasimhan 10 guests 1 guest message to answer	23 July 2017	26 July 2017	#6 Large River Cabin	05 June 2017	OK	US$945	US$141.75	1258789416
Allison Mann 4 guests	23 July 2017	27 July 2017	#8 Western Unit	08 June 2017	OK	US$480	US$72	1529537163
terrus huls 2 guests	24 July 2017	26 July 2017	Upper Skyline North	11 June 2017	OK	US$330	US$49.50	1747067222
Terri Richardson 4 guests	26 July 2017	28 July 2017	Upper Skyline South	07 June 2017	OK	US$310	US$46.50	1435907150
Debbie Young 4 guests	30 July 2017	05 August 2017	#8 Western Unit	08 June 2017	OK	US$720	US$108	1209962879
Gregory Church 4 guests	30 July 2017	01 August 2017	#8 Western Unit	03 June 2017	Canceled	US$0	US$0	1357716307
Stephanie Buel 4 guests	31 July 2017	03 August 2017	#8 Western Unit	07 June 2017	Canceled	US$0	US$0	1120884797
ARTURAS VINKEVICIUS 4 guests	01 August 2017	05 August 2017	#5 Cabin with a View	08 June 2017	OK	US$780	US$117	1335350823
vinay singh 4 guests	01 August 2017	03 August 2017	#4 One Room Cabin	07 June 2017	Canceled	US$0	US$0	1438534254
Sarah Troia 12 guests	04 August 2017	06 August 2017	#6 Large River Cabin	14 June 2017	OK	US$630	US$94.50	1175185436
Virginia Clark 4 guests 1 guest message to answer	10 August 2017	13 August 2017	#8 Western Unit	06 June 2017	OK	US$390	US$58.50	1853252311
Johnathan Koeltzow 2 guests	11 August 2017	13 August 2017	#8 Western Unit	02 June 2017	Canceled	US$0	US$0	1756807815
SHIU TAK LEUNG 2 guests	14 August 2017	17 August 2017	Upper Skyline South	12 June 2017	OK	US$465	US$69.75	1679266889
Carol Leech 4 guests	14 August 2017	16 August 2017	#8 Western Unit	07 June 2017	OK	US$260	US$39	1740250954
Mohamed Basiouny 4 guests	19 August 2017	21 August 2017	Upper Skyline South	13 June 2017	OK	US$310	US$46.50	2008176523
susannah mitchell 1 guest	31 August 2017	03 September 2017	#1 One Room Cabin	04 June 2017	Canceled	US$0	US$0	1034276945
karissa Wight 4 guests	07 September 2017	09 September 2017	#4 One Room Cabin	13 June 2017	OK	US$290	US$43.50	1779163724
Inez Cunningham 3 guests	07 September 2017	13 September 2017	#3 Southwest Spa	13 June 2017	OK	US$1890	US$283.50	1831513503
Tony Hajek 2 guests	08 September 2017	10 September 2017	#8 Western Unit	12 June 2017	OK	US$240	US$36	1420506143
Todd Featherstun 1 guest	08 September 2017	10 September 2017	#1 One Room Cabin	02 June 2017	OK	US$290	US$43.50	1489205592
Margaret Dreiling 1 guest	08 September 2017	10 September 2017	Upper Skyline South	15 June 2017	OK	US$310	US$46.50	1977820063
"""

  @oldBookingResvs2 = """Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Jacen Roper 4 guests	23 June 2017	26 June 2017	#4 One Room Cabin	31 May 2017	OK	US$435	US$65.25	1771276433
Cherry Lofstrom 1 guest	23 June 2017	25 June 2017	#1 One Room Cabin	01 June 2017	OK	US$290	US$43.50	1065507845
Encarnita Pascuzzi 4 guests	23 June 2017	26 June 2017	#8 Western Unit	01 June 2017	Canceled	US$0		1361910794
Joseph Shuck 4 guests	23 June 2017	25 June 2017	Upper Skyline South	01 June 2017	OK	US$310	US$46.50	1716314897
Jana Green 4 guests	25 June 2017	27 June 2017	#2 Mountain Spa	01 June 2017	OK	US$370	US$55.50	1065504281
Aman Hota 4 guests	30 June 2017	03 July 2017	Upper Skyline South	01 June 2017	OK	US$465	US$69.75	1540200140
linda Nelsen 4 guests	16 June 2017	18 June 2017	#8 Western Unit	03 June 2017	OK	US$290	US$43.50	1346970369
Tanya Thomas 2 guests	23 June 2017	25 June 2017	Upper Skyline North	03 June 2017	OK	US$330	US$49.50	1584941695
Desiree Schwalm 8 guests	16 June 2017	18 June 2017	#3 Southwest Spa	04 June 2017	Canceled	US$0		1516613627
Yessenia Chan;Che Yun Chan;So Sum Daphne Chan 8 guests	23 June 2017	25 June 2017	#3 Southwest Spa	04 June 2017	OK	US$630	US$94.50	1362060631
Kelli Pachner 4 guests	29 June 2017	07 July 2017	#2 Mountain Spa	05 June 2017	OK	US$1480	US$222	1150950465
john peterson 4 guests	16 June 2017	18 June 2017	Upper Skyline South	06 June 2017	OK	US$310	US$46.50	2035897444
Kristi Stoll 2 guests	22 June 2017	24 June 2017	#8 Western Unit	06 June 2017	Canceled	US$0		1120838596
CHARLES FREEMAN 4 guests	26 June 2017	30 June 2017	#4 One Room Cabin	06 June 2017	OK	US$580	US$87	1525366564
Hari Nepal 4 guests	27 June 2017	29 June 2017	#8 Western Unit	06 June 2017	OK	US$260	US$39	1277611253
Glenn Price 3 guests	16 June 2017	18 June 2017	Upper Skyline North	08 June 2017	OK	US$330	US$49.50	1881784832
Daryl Schwindt 4 guests	18 June 2017	21 June 2017	#8 Western Unit	08 June 2017	OK	US$360	US$54	1285995429
Andrew Impagliazzo 4 guests	23 June 2017	26 June 2017	#8 Western Unit	08 June 2017	OK	US$360	US$54	1055950974
Ann Ross 4 guests	18 June 2017	20 June 2017	#4 One Room Cabin	10 June 2017	OK	US$290	US$43.50	1747041527
Pauline Segura 4 guests	23 June 2017	25 June 2017	#5 Cabin with a View	11 June 2017	OK	US$390	US$58.50	2086414716
Susan Haynes 3 guests	28 June 2017	01 July 2017	#5 Cabin with a View	12 June 2017	OK	US$585	US$87.75	1315640448
Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Allison Mann 4 guests	23 July 2017	27 July 2017	#8 Western Unit	08 June 2017	OK	US$480	US$72	1529537163
Consuelo Chavarria 4 guests 2 guest messages to answer	03 July 2017	05 July 2017	#8 Western Unit	02 June 2017	OK	US$290	US$43.50	1289646030
Debbie Young 4 guests	30 July 2017	05 August 2017	#8 Western Unit	08 June 2017	OK	US$720	US$108	1209962879
Debra Hakar 2 guests	09 July 2017	11 July 2017	#8 Western Unit	05 June 2017	OK	US$260	US$39	1529718572
Desiree Schwalm 12 guests 1 guest message to answer	01 July 2017	03 July 2017	#6 Large River Cabin	01 June 2017	Canceled	US$0		1724384266
Duelberg 1 guest	09 July 2017	16 July 2017	Upper Skyline South	09 June 2017	OK	US$1085	US$162.75	1152517257
Eric Johnson 2 guests	10 July 2017	14 July 2017	Upper Skyline North	02 June 2017	OK	US$660	US$99	1159618525
Gregory Church 4 guests	30 July 2017	01 August 2017	#8 Western Unit	03 June 2017	Canceled	US$0		1357716307
Jeffrey Sterup 2 guests	21 July 2017	23 July 2017	#4 One Room Cabin	01 June 2017	OK	US$290	US$43.50	1065585580
Jeremy Goldsmith 1 guest	01 July 2017	04 July 2017	#7 Western Spa	01 June 2017	Canceled	US$0		1849068878
Karthikeyan Shanmugavadivel 4 guests	01 July 2017	03 July 2017	#8 Western Unit	01 June 2017	OK	US$290	US$43.50	1919159565
Lance richardson 2 guests 1 guest message to answer	11 July 2017	13 July 2017	#8 Western Unit	05 June 2017	OK	US$260	US$39	1853235506
Linda Kroeger 12 guests	05 July 2017	09 July 2017	#6 Large River Cabin	02 June 2017	OK	US$1260	US$189	1784265520
Michael Villanueva 12 guests	20 July 2017	22 July 2017	#6 Large River Cabin	03 June 2017	OK	US$630	US$94.50	1197903266
Nirmala Narasimhan 10 guests 1 guest message to answer	23 July 2017	26 July 2017	#6 Large River Cabin	05 June 2017	OK	US$945	US$141.75	1258789416
Olga Diachuk 2 guests	01 July 2017	04 July 2017	Upper Skyline North	03 June 2017	OK	US$495	US$74.25	1276208822
Patricia Curtis 4 guests	08 July 2017	11 July 2017	#4 One Room Cabin	07 June 2017	OK	US$435	US$65.25	2065156596
Ritu Singh 4 guests	13 July 2017	17 July 2017	#8 Western Unit	08 June 2017	Canceled	US$0		1760649274
Ryan Martin 4 guests	05 July 2017	08 July 2017	#8 Western Unit	07 June 2017	Canceled	US$0		1490387834
Scott Bonnel 1 guest	03 July 2017	08 July 2017	#7 Western Spa	09 June 2017	OK	US$875	US$131.25	1152594137
Stephanie Buel 4 guests	31 July 2017	03 August 2017	#8 Western Unit	07 June 2017	Canceled	US$0		1120884797
Taylor Robertson 3 guests	14 July 2017	16 July 2017	#4 One Room Cabin	04 June 2017	OK	US$290	US$43.50	1034229994
Teresa Kile 4 guests	03 July 2017	07 July 2017	Upper Skyline South	06 June 2017	OK	US$620	US$93	1529786552
Terri Richardson 4 guests	26 July 2017	28 July 2017	Upper Skyline South	07 June 2017	OK	US$310	US$46.50	1435907150
terrus huls 2 guests	24 July 2017	26 July 2017	Upper Skyline North	11 June 2017	OK	US$330	US$49.50	1747067222
Thomas Hall 2 guests	15 July 2017	18 July 2017	#8 Western Unit	09 June 2017	OK	US$360	US$54	1285019793
Thomas Sturrock 12 guests	14 July 2017	16 July 2017	#6 Large River Cabin	08 June 2017	OK	US$630	US$94.50	1335353110
Tiffany Keleher 8 guests	21 July 2017	23 July 2017	#3 Southwest Spa	07 June 2017	OK	US$630	US$94.50	1741695563
Vanessa Garcia 4 guests	16 July 2017	19 July 2017	#4 One Room Cabin	02 June 2017	OK	US$435	US$65.25	2047390051
Wanda Markotter 8 guests	02 July 2017	05 July 2017	#3 Southwest Spa	02 June 2017	Canceled	US$0		1936424490
Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
ARTURAS VINKEVICIUS 4 guests	01 August 2017	05 August 2017	#5 Cabin with a View	08 June 2017	OK	US$780	US$117	1335350823
Stephanie Buel 4 guests	31 July 2017	03 August 2017	#8 Western Unit	07 June 2017	Canceled	US$0		1120884797
vinay singh 4 guests	01 August 2017	03 August 2017	#4 One Room Cabin	07 June 2017	Canceled	US$0		1438534254
Guest name	Arrival	Departure	Room Name	Booked on	Status	Total Price	Commission	Reference Number
Todd Featherstun 1 guest	08 September 2017	10 September 2017	#1 One Room Cabin	02 June 2017	OK	US$290	US$43.50	1489205592
Tony Hajek 2 guests	08 September 2017	10 September 2017	#8 Western Unit	12 June 2017	OK	US$240	US$36	1420506143
"""
