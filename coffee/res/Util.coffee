
# Static method utilities       - Util is a global without a functional wrapper
# coffee -c -bare Util.coffee   - prevents function wrap to put Util in global namespace
# Very important requires that Util.js be loaded first

class Util

  Util.myVar      =  'myVar'
  Util.skipReady  =  false
  Util.isCommonJS =  false
  Util.isWebPack  =  false
  if typeof module is "object" && typeof module.exports  is "object"
    Util.isCommonJS = true
  else
    Util.isWebPack  = true

  Util.Load          = null
  Util.ModuleGlobals = []
  Util.app           = {}
  Util.testTrue      = true
  Util.debug         = false
  Util.message       = false
  Util.count         = 0
  Util.modules       = []
  Util.instances     = []
  Util.globalPaths   = []
  Util.root          = '../' # Used internally
  Util.rootJS        = Util.root + 'js/'
  Util.databases     = {} # Provides global access to databases in Store
  Util.htmlIds       = {} # Object of unique Html Ids
  Util.logStackNum   = 0
  Util.logStackMax   = 100
  Util.fills         = {}

  # ------ Modules ------

  @init:( moduleCommonJS=undefined, moduleWebPack=undefined, root=Util.root, prj="ui" ) ->
    Util.root   = root
    Util.rootJS = Util.root + 'js/'
    Util.arg = prj
    Util.prj = if prj is 'skytest' then 'skyline' else prj
    Util.resetModuleExports( Util.prj )
    Util.fixTestGlobals()
    if     Util.isCommonJS and moduleCommonJS?
      require( moduleCommonJS )
    else if Util.isWebPack and moduleWebPack?
      Util.skipReady = true
      Util.loadScript( moduleWebPack )
    else
      Util.error( """Bad arguments for Util.init() isCommonJS=#{Util.isCommonJS},
        root=#{root}, moduleCommonJS=#{moduleCommonJS?}, moduleWebPack=#{moduleWebPack}""" )
    return

  # Questionable but needed to support Electron + Webpack + Simple Browser which is not advised
  @requireModule:( module, prj=null ) ->
    if Util[module]?
       #til.log('Util[module]?')
       Util[module]
    else if Util.isCommonJS
      Util.resetModuleExports( prj ) if not Util.module? and prj?
      #Util.log('Util.isCommonJS' )
      require(module)
    else if require?
      #Util.log('Util require', Util.isCommonJS )
      require(module)
    else if module is 'jquery' and window['jQuery']?
      #Util.log('Util  window[jQuery]')
      window['jQuery']
    else if window[module]?
      #Util.log('Util  window[module]?')
      window[module]?
    else
      #msg = { $:window.$?, jquery:window.jquery?, jQuery:window.jQuery?, isCommonJS: Util.isCommonJS  }
      Util.error( 'Util.requireModule() module not found', module )
      null

  @initJasime:( prj ) ->
    Util.resetModuleExports( prj )
    if not Util.isCommonJS
      window.require = Util.loadScript
    else
      Util.fixTestGlobals()
      window.exports        = module.exports
      window.jasmineRequire = window.exports
    return

  # Use to to prevent dynamic resolve in webpack where Util is not included
  # Need require for WebPath. For now can only warn
  @require:( path ) ->
    if Util.isCommonJS
      require( path )
    else if Util.isWebPack
      Util.warn( 'Util.require may not work with WebPack', path )
      require( path )
    else
      Util.loadScript( path+'.js' )

  @fixTestGlobals:() ->
    window.Util  = Util
    #window.xUtil = Util

  @loadScript:( path, fn ) ->
    head          = document.getElementsByTagName('head')[0];
    script        = document.createElement('script')
    script.src    = path
    script.async  = false
    script.onload = fn if Util.isFunc( fn )
    head.appendChild( script )
    return

  @resetModuleExports:( prj ) ->
    if Util.isCommonJS
       Util.module = require('module')
       Util.module.globalPaths.push("/Users/ax/Documents/prj/#{prj}/")
       #window.global = window
       #Util.log( "Node Module Paths", Util.module.globalPaths )
    return

  @ready:( fn ) ->
    if not Util.isFunc( fn )                  # Sanity check
      return
    else if Util.skipReady
      fn()
    else if document.readyState is 'complete' # If document is already loaded, run method
      fn()
    else
      document.addEventListener( 'DOMContentLoaded', fn, false )
    return

  # ---- Inquiry ----

  @hasMethod:( obj, method, issue=false ) ->
    has = typeof obj[method] is 'function'
    Util.log( 'Util.hasMethod()', method, has )  if not has and issue
    has

  @hasGlobal:( global, issue=true ) ->
    has = window[global]?
    Util.error( "Util.hasGlobal() #{global} not present" )  if not has and issue
    has

  @getGlobal:( global, issue=true ) ->
    if Util.hasGlobal( global, issue ) then window[global] else null

  @hasPlugin:( plugin, issue=true ) ->
    glob = Util.firstTok(plugin,'.')
    plug = Util.lastTok( plugin,'.')
    has  = window[glob]? and window[glob][plug]?
    Util.error( "Util.hasPlugin()  $#{glob+'.'+plug} not present" )  if not has and issue
    has

  @hasModule:( path, issue=true ) ->
    has = Util.modules[path]?
    Util.error( "Util.hasModule() #{path} not present" )  if not has and issue
    has

  @dependsOn:() ->
    ok = true
    for arg in arguments
      has = Util.hasGlobal(arg,false) or Util.hasModule(arg,false) or Util.hasPlugin(arg,false)
      Util.error( 'Missing Dependency', arg ) if not has
      ok = has if has is false
    ok

  # ---- Instances ----

  @setInstance:( instance, path ) ->
    Util.log( 'Util.setInstance()', path )
    if not instance? and path?
      Util.error('Util.setInstance() instance not defined for path', path )
    else if instance? and not path?
      Util.error('Util.setInstance() path not defined for instance', instance.toString() )
    else
      Util.instances[path] = instance
    return

  @getInstance:( path, dbg=false ) ->
    Util.log( 'getInstance', path ) if dbg
    instance = Util.instances[path]
    if not instance?
      Util.error('Util.getInstance() instance not defined for path', path )
    instance

  # ---- Logging -------

  # args should be the arguments passed by the original calling function
  # This method should not be called directly
  @toStrArgs:( prefix, args ) ->
    Util.logStackNum = 0
    str = if Util.isStr(prefix) then prefix + " "  else ""
    for arg in args
      str += Util.toStr(arg) + " "
    str

  @toStr:( arg ) ->
    Util.logStackNum++
    return '' if Util.logStackNum > Util.logStackMax
    switch typeof(arg)
      when 'null'   then 'null'
      when 'string' then Util.toStrStr(arg)
      when 'number' then arg.toString()
      when 'object' then Util.toStrObj(arg)
      else arg

  # Recusively stringify arrays and objects
  @toStrObj:( arg ) ->
    str = ""
    if not arg?
      str += "null"
    else if Util.isArray(arg)
      str += "[ "
      for a in arg
        str += Util.toStr(a) + ","
      str = str.substr(0, str.length - 1) + " ]"
    else if Util.isObjEmpty(arg)
      str += "{}"
    else
      str += "{ "
      for own key, val of arg
        str += key + ":" + Util.toStr(val) + ", "
      str = str.substr(0, str.length - 2) + " }" # Removes last comma
    str

  @toStrStr:( arg ) ->
    if arg.length > 0 then arg
    else '""'

  # Consume unused but mandated variable to pass code inspections
  @noop:() ->
    Util.log( arguments ) if false
    return

  # Conditional log arguments through console
  @dbg:() ->
    return if not Util.debug
    str = Util.toStrArgs( '', arguments )
    Util.consoleLog( str )
    #@gritter( { title:'Log', time:2000 }, str )
    return

  @msg:() ->
    return if not Util.message
    str = Util.toStrArgs( '', arguments )
    Util.consoleLog( str )
    return

  # Log Error and arguments through console and Gritter
  @error:() ->
    str  = Util.toStrArgs( 'Error:', arguments )
    Util.consoleLog( str )
    # Util.trace( 'Trace:' )
    return

  # Log Warning and arguments through console and Gritter
  @warn:() ->
    str  = Util.toStrArgs( 'Warning:', arguments )
    Util.consoleLog( str )
    return

  @toError:() ->
    str = Util.toStrArgs( 'Error:', arguments )
    new Error( str )

  # Log arguments through console if it exists
  @log:() ->
    str = Util.toStrArgs( '', arguments )
    Util.consoleLog( str )
    return

  # Log arguments through gritter if it exists
  @called:() ->
    str = Util.toStrArgs( '', arguments )
    Util.consoleLog( str )
    #@gritter( { title:'Called', time:2000 }, str )
    return

  @gritter:( opts, args... ) ->
    return if not ( Util.hasGlobal('$',false)  and $['gritter']? )
    str = Util.toStrArgs( '', args )
    opts.title = if opts.title? then opts.title else 'Gritter'
    opts.text  = str
    return

  @consoleLog:( str ) ->
    console.log(str) if console?
    return

  @trace:(  ) ->
    str = Util.toStrArgs( 'Trace:', arguments )
    Util.consoleLog( str )
    try
      throw new Error( str )
    catch error
      Util.log( error.stack )
    return

  @alert:(  ) ->
    str = Util.toStrArgs( '', arguments )
    Util.consoleLog( str )
    alert( str )
    return

  # Does not work
  @logJSON:(json) ->
    Util.consoleLog(json)

  # ------ Validators ------

  @keys:(o)          ->  if Util.isObj(o) then Object.keys(o) else []
  @isDef:(d)         ->  d?
  @isNot:(d)         ->  not Util.isDef(d)
  @isStr:(s)         ->  s? and typeof(s)=="string" and s.length > 0
  @isNum:(n)         ->  n? and typeof(n)=="number" and not isNaN(n)
  @isObj:(o)         ->  o? and typeof(o)=="object"
  @isVal:(v)         ->  typeof(v)=="number" or typeof(v)=="string" or typeof(v)=="boolean"
  @isObjEmpty:(o)    ->  Util.isObj(o) and Object.getOwnPropertyNames(o).length is 0
  @isFunc:(f)        ->  f? and typeof(f)=="function"
  @isArray:(a)       ->  a? and Array.isArray(a) and a.length? and a.length > 0
  @isEvent:(e)       ->  e? and e.target?
  @inIndex:(a,i)     ->  Util.isArray(a) and 0 <= i and i < a.length
  @inArray:(a,e)     ->  Util.isArray(a) and a.indexOf(e) > -1
  @inString:(s,e)    ->  Util.isStr(s)   and s.indexOf(e) > -1
  @atLength:(a,n)    ->  Util.isArray(a) and a.length==n
  @head:(a)          ->  if Util.isArray(a) then a[0]          else null
  @tail:(a)          ->  if Util.isArray(a) then a[a.length-1] else null
  @time:()           ->  new Date().getTime()
  @isStrInteger:(s)  -> /^\s*(\+|-)?\d+\s*$/.test(s)
  @isStrFloat:(s)    -> /^\s*(\+|-)?((\d+(\.\d+)?)|(\.\d+))\s*$/.test(s)
  @isStrCurrency:(s) -> /^\s*(\+|-)?((\d+(\.\d\d)?)|(\.\d\d))\s*$/.test(s)
  #@isStrEmail:(s)   -> /^\s*[\w\-\+_]+(\.[\w\-\+_]+)*\@[\w\-\+_]+\.[\w\-\+_]+(\.[\w\-\+_]+)*\s*$/.test(s)
  @isEmpty:( $elem ) -> $elem? and $elem.length? and $elem.length is 0 # For jQuery

  @isDefs:() ->
    for arg in arguments
      if not arg?
        return false
    true

  @copyProperties:( to, from ) ->
    for own key, val of from
      to[key] = val
    to

  @contains:( array, value ) ->
    Util.isArray(array) and array.indexOf(value) isnt -1

  # Screen absolute (left top width height) percent positioning and scaling

  # Percent array to position mapping
  @toPosition:( array ) ->
    { left:array[0], top:array[1], width:array[2], height:array[3] }

  # Adds Percent from array for CSS position mapping
  @toPositionPc:( array ) ->
    { position:'absolute', left:array[0]+'%', top:array[1]+'%', width:array[2]+'%', height:array[3]+'%' }

  @cssPosition:( $, screen, port, land ) ->
    array = if screen.orientation is 'Portrait' then port else land
    $.css( Util.toPositionPc(array) )
    return

  @xyScale:( prev, next, port, land ) ->
    [xp,yp] = if prev.orientation is 'Portrait' then [port[2],port[3]] else [land[2],land[3]]
    [xn,yn] = if next.orientation is 'Portrait' then [port[2],port[3]] else [land[2],land[3]]
    xs = next.width  * xn  / ( prev.width  * xp )
    ys = next.height * yn  / ( prev.height * yp )
    [xs,ys]

  # ----------------- Guarded jQuery dependent calls -----------------

  @resize:( callback ) ->
    window.onresize = () ->
      setTimeout( callback, 100 )
    return

  @resizeTimeout:( callback, timeout = null ) ->
    window.onresize = () ->
      clearTimeout( timeout ) if timeout?
      timeout = setTimeout( callback, 100 )
    return

  # ------ Html ------------

  @getHtmlId:( name, type='', ext='' ) ->
    name + type + ext

  @htmlId:( name, type='', ext='' ) ->
    id = Util.getHtmlId( name, type, ext )
    Util.error( 'Util.htmlId() duplicate html id', id ) if Util.htmlIds[id]?
    Util.htmlIds[id] = id
    id

  @toPage:( path ) ->
    window.location = path

  # ------ Converters ------

  @extend:( obj, mixin ) ->
    for own name, method of mixin
      obj[name] = method
    obj

  @include:( klass, mixin ) ->
    Util.extend( klass.prototype, mixin )

  @eventErrorCode:( e ) ->
    errorCode = if e.target? and e.target.errorCode then e.target.errorCode else 'unknown'
    { errorCode:errorCode }

  @toName:( s1 ) ->
    s2 =  s1.replace('_',' ')
    s3 =  s2.replace(/([A-Z][a-z])/g, ' $1' )
    s4 =  s3.replace(/([A-Z]+)/g,     ' $1' )
    s4

  @toName1:( s1 ) ->
    s2 =  s1.replace('_',' ')
    s3 =  s2.replace(/([A-Z][a-z])/g, ' $1' )
    s3.substring(1)

  @toSelect:( name ) ->
    name.replace(' ','')

  @indent:(n) ->
    str = ''
    for i in [0...n]
      str += ' '
    str

  @hashCode:( str ) ->
    hash = 0
    for i in [0...str.length]
      hash = (hash<<5) - hash + str.charCodeAt(i)
    hash

  @lastTok:( str, delim ) ->
    str.split(delim).pop()

  @firstTok:( str, delim ) ->
    if Util.isStr(str) and str.split?
      str.split(delim)[0]
    else
      Util.error( "Util.firstTok() str is not at string", str )
      ''

  @padEnd:( str, len, ch=' ' ) ->
    pad = ""
    for [str.length...len]
      pad += ch
    str + pad

  ###
    parse = document.createElement('a')
    parse.href =  "http://example.com:3000/dir1/dir2/file.ext?search=test#hash"
    parse.protocol  "http:"
    parse.hostname  "example.com"
    parse.port      "3000"
    parse.pathname  "/dir1/dir2/file.ext"
    parse.segments  ['dir1','dir2','file.ext']
    parse.fileExt   ['file','ext']
    parse.file       'file'
    parse.ext        'ext'
    parse.search    "?search=test"
    parse.hash      "#hash"
    parse.host      "example.com:3000"
  ###

  @pdfCSS:( href ) ->
    return if not window.location.search.match(/pdf/gi)
    link      = document.createElement('link')
    link.rel  = 'stylesheet'
    link.type = 'text/css'
    link.href =  href
    document.getElementsByTagName('head')[0].appendChild link
    return

  @parseURI:( uri ) ->
    parse          = {}
    parse.params   = {}
    a              = document.createElement('a')
    a.href         = uri
    parse.href     = a.href
    parse.protocol = a.protocol
    parse.hostname = a.hostname
    parse.port     = a.port
    parse.segments = a.pathname.split('/')
    parse.fileExt  = parse.segments.pop().split('.')
    parse.file     = parse.fileExt[0]
    parse.ext      = if parse.fileExt.length==2 then parse.fileExt[1] else ''
    parse.dbName   = parse.file
    parse.fragment = a.hash
    parse.query    = if Util.isStr(a.search) then a.search.substring(1) else ''
    nameValues     = parse.query.split('&')
    if Util.isArray(nameValues)
      for nameValue in nameValues
        [name,value] = nameValue.split('=')
        parse.params[name] = value
    parse

  @quicksort:( array, prop, order ) ->
    return [] if array.length == 0
    head = array.pop()
    if order is 'Ascend'
      small = ( a for a in array when a[prop]  <= head[prop] )
      large = ( a for a in array when a[prop]  >  head[prop]  )
      (Util.quicksort(small,prop,order)).concat([head]).concat( Util.quicksort(large,prop,order) )
    else
      small = ( a for a in array when a[prop]  >= head[prop] )
      large = ( a for a in array when a[prop]  <  head[prop]  )
      (Util.quicksort(small,prop,order)).concat([head]).concat( Util.quicksort(large,prop,order) )

  @quicksortArray:( array ) ->
    return [] if array.length == 0
    head = array.pop()
    small = ( a for a in array when a <= head )
    large = ( a for a in array when a >  head )
    (Util.quicksort(small)).concat([head]).concat( Util.quicksort(large) )

  # Sort with array.val using the internal JavaScript array sort
  # This did not work in the Skyline Master class
  @sortArray:( array, prop, type, order ) ->
    compare = (a,b) -> ( if a[prop] is b[prop] then 0 else if a[prop] < b[prop] then -1 else  1 )
    compare = (a,b) -> ( if a[prop] is b[prop] then 0 else if a[prop] < b[prop] then  1 else -1 ) if type is 'string' and order is 'Decend'
    compare = (a,b) -> (    a[prop] -  b[prop]                                                  ) if type is 'number' and order is 'Ascend'
    compare = (a,b) -> (    b[prop] -  a[prop]                                                  ) if type is 'number' and order is 'Decend'
    array.sort( compare )

  @pad:( m ) ->
    n = Util.toInt(m)
    if n < 10 then '0'+n.toString() else n.toString()

  @padStr:( n ) ->
    if n < 10 then '0'+n.toString() else n.toString()

  # Return and ISO formated data string
  @isoDateTime:( dateIn ) ->
    date = if dateIn? then dateIn else new Date()
    Util.log( 'Util.isoDatetime()', date )
    Util.log( 'Util.isoDatetime()', date.getUTCMonth(), date.getUTCDate(), date.getUTCHours(), date.getUTCMinutes, date.getUTCSeconds )
    pad = (n) -> Util.pad(n)
    date.getFullYear()     +'-'+pad(date.getUTCMonth()+1)+'-'+pad(date.getUTCDate())+'T'+
    pad(date.getUTCHours())+':'+pad(date.getUTCMinutes())+':'+pad(date.getUTCSeconds())+'Z'

  @toHMS:( unixTime ) ->
    date = new Date()
    date.setTime( unixTime * 1000 ) if Util.isNum(unixTime)
    hour = date.getHours()
    ampm = 'AM'
    if hour > 12
      hour = hour - 12
      ampm = 'PM'
    min  = ('0' + date.getMinutes()).slice(-2)
    sec  = ('0' + date.getSeconds()).slice(-2)
    time = "#{hour}:#{min}:#{sec} #{ampm}"
    time

  # Generate four random hex digits
  @hex4:() ->
    (((1+Math.random())*0x10000)|0).toString(16).substring(1)

  # Generate a 32 bits hex
  @hex32:() ->
    hex = @hex4()
    for i in [1..4]
      Util.noop(i)
      hex += @hex4()
    hex

  # Return a number with fixed decimal places
  @toFixed:( arg, dec=2 ) ->
    num = switch typeof(arg)
      when 'number' then arg
      when 'string' then parseFloat(arg)
      else 0
    num.toFixed(dec)

  @toInt:( arg ) ->
    switch typeof(arg)
      when 'number' then Math.floor(arg)
      when 'string' then  parseInt(arg)
      else 0

  @toFloat:( arg ) ->
    switch typeof(arg)
      when 'number' then arg
      when 'string' then parseFloat(arg)
      else 0

  @toCap:( str ) ->
    str.charAt(0).toUpperCase() + str.substring(1)

  @unCap:( str ) ->
    str.charAt(0).toLowerCase() + str.substring(1)

  # Review
  @toArray:( objects, whereIn=null, keyField='id' ) ->
    where = if whereIn? then whereIn else () -> true
    array = []
    if Util.isArray(objects)
      for object in array  when where(object)
        object[keyField] = object['id'] if object['id']? and keyField isnt 'id'
        array.push( object )
    else
      for own key, object of objects when where(object)
        object[keyField] = key
        array.push(object)
    array

  # keyProp only needed if rows is away
  @toObjects:( rows, whereIn=null, key='key' ) ->
    where = if whereIn? then whereIn else () -> true
    objects = {}
    if Util.isArray(rows)
      for row in rows when where(row)
        if row? and row[key]?
          ckey =  Util.childKey(row[key])
          objects[row[ckey]] = row
        else
          Util.error( "Util.toObjects() row array element requires key property", key, row )
    else
      for own key, row of rows when where(row)
        objects[key] = row
    objects

  @childKey:( key ) ->
    key.split('/')[0]

  @toRange:( rows, beg, end, keyProp='key' ) ->
    objects = {}
    if Util.isArray(rows)
      for row in rows when beg <= row[keyProp] and row[keyProp] <= end
        objects[row[keyProp]] = row
    else
      for own key, row of rows when beg <= key and key <= end
        objects[key] = row
    objects

  # keyProp only needed if rows is away
  @toKeys:( rows, whereIn=null, keyProp='key' ) ->
    where = if whereIn? then whereIn else () -> true
    keys  = []
    if Util.isArray(rows)
      for row in rows when where(row)
        if row[keyProp]?
          keys.push( row[keyProp] )
        else
          Util.error( "Util.toKeys() row array element requires key property", keyProp, row )
    else
      for own key, row of rows when where(row)
        keys.push( key )
    keys

  @logObjs:( msg, objects ) =>
    Util.log( msg )
    Util.log( '  ', { key:key, row:row } ) for own key, row of objects
    return

  # Beautiful Code, Chapter 1.
  # Implements a regular expression matcher that supports character matches,
  # '.', '^', '$', and '*'.

  # Search for the regexp anywhere in the text.
  @match:(regexp, text) ->
    return Util.match_here(regexp.slice(1), text) if regexp[0] is '^'
    while text
      return true if Util.match_here(regexp, text)
      text = text.slice(1)
    false

  # Search for the regexp at the beginning of the text.
  @match_here:(regexp, text) ->
    [cur, next] = [regexp[0], regexp[1]]
    if regexp.length is 0 then return true
    if next is '*' then return Util.match_star(cur, regexp.slice(2), text)
    if cur is '$' and not next then return text.length is 0
    if text and (cur is '.' or cur is text[0]) then return Util.match_here(regexp.slice(1), text.slice(1))
    false

  # Search for a kleene star match at the beginning of the text.
  @match_star:(c, regexp, text) ->
    loop
      return true if Util.match_here(regexp, text)
      return false unless text and (text[0] is c or c is '.')
      text = text.slice(1)

  @match_test:() ->
    Util.log( Util.match_args("ex", "some text") )
    Util.log( Util.match_args("s..t", "spit") )
    Util.log( Util.match_args("^..t", "buttercup") )
    Util.log( Util.match_args("i..$", "cherries") )
    Util.log( Util.match_args("o*m", "vrooooommm!") )
    Util.log( Util.match_args("^hel*o$", "hellllllo") )

  @match_args:( regexp, text ) ->
    Util.log( regexp, text, Util.match(regexp,text) )

  @svgId:( name, type, svgType, check=false ) ->
    if check then @id( name, type, svgType ) else name + type + svgType
  @css:(   name, type=''       ) -> name + type
  @icon:(  name, type, fa      ) -> name + type + ' fa fa-' + fa

  # json - "application/json;charset=utf-8"
  # svg

  @mineType:( fileType ) ->
    mine = switch fileType
      when 'json' then "application/json"
      when 'adoc' then "text/plain"
      when 'html' then "text/html"
      when 'svg'  then "image/svg+xml"
      else             "text/plain"
    mine += ";charset=utf-8"
    mine

  # Need find URL
  @saveFile:( stuff, fileName, fileType ) ->
    blob = new Blob( [stuff], { type:@mineType(fileType) } )
    Util.noop(blob)
    url  = "" # URL.createObjectURL(blob)
    downloadLink      = document.createElement("a")
    downloadLink.href = url;
    downloadLink.download = fileName
    document.body.appendChild(downloadLink)
    downloadLink.click()
    document.body.removeChild(downloadLink)
    return

export default Util