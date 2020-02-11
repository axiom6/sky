
import Util  from '../res/Util.js'

class Store

  ###
  Store.Memory    = require( 'js/store/Memory'     )
  Store.IndexedDB = require( 'js/store/IndexedDB'  )
  Store.Rest      = require( 'js/store/Rest'       )
  Store.Fire      = require( 'js/store/Fire'       )
  ###
  #Store.PouchDB  = require( 'js/store/PouchDB'    )

  @memories  = {} # Store.Memory instances create by getMemory() for in memory dbName
  @databases = {} # Set by Store.Memory as Store.databases[dbName].tables for 

  # CRUD        Create    Retrieve  Update    Delete
  @restOps  = [ 'add',    'get',    'put',    'del'    ]
  @sqlOps   = [ 'insert', 'select', 'update', 'remove', 'range' ]
  @tableOps = [ 'open',   'show',   'make',   'drop'   ]

  @isRestOp:(  op ) -> Store. restOps.indexOf(op) isnt -1
  @isSqlOp:(   op ) -> Store.  sqlOps.indexOf(op) isnt -1
  @isTableOp:( op ) -> Store.tableOps.indexOf(op) isnt -1

  @methods = Store.restOps.concat( Store.sqlOps ).concat( Store.tableOps ).concat(['on'])

  # Dafaults for empty arguments
  @where  = () -> true # Default where clause filter that returns true to access all records
  W       = Store.where

  # @uri     = REST URI where the file part is the database
  # @keyProp = The key id property = default is ['key']
  constructor:( @stream, @uri, @module ) ->
    @keyProp    = 'key'
    @dbName     = Store.nameDb( @uri )
    @tables     = {}
    @hasMemory  = false
    @justMemory = false

  # REST Api  CRUD + Subscribe for objectect records
  add:( table, id, object )  -> Util.noop(  table, id, object )  # Post    Create   an object into table with id
  get:( table, id )          -> Util.noop(  table, id         )  # Get     Retrieve an object from table with id
  put:( table, id, object )  -> Util.noop(  table, id, object )  # Put     Update   an object into table with id
  del:( table, id )          -> Util.noop(  table, id         )  # Delete  Delete   an object from table with id

  # SQL Table DML (Data Manipulation Language) with multiple objects (rows)
  insert:( table, objects  ) -> Util.noop( table, objects  )  # Insert objects into table with unique id
  select:( table, where=W  ) -> Util.noop( table, where    )  # Select objects from table with where clause
  range:(  table, beg, end ) -> Util.noop( table, beg, end )  # Select objects from table with where clause
  update:( table, objects  ) -> Util.noop( table, objects  )  # Update objects into table mapped by id
  remove:( table, wheKeys  ) -> Util.noop( table, wheKeys  )  # Delete objects from table with keys array or where clause

  # Table DDL (Data Definition Language) omitted schema update
  make:( table           ) -> Util.noop( table ) # Create a table
  show:( table=undefined ) -> Util.noop( table ) # Show a list of row keys or tables if table is undefined
  drop:( table           ) -> Util.noop( table ) # Drop the entire table - good for testing

  # Subscribe to CRUD changes on a table or a row with id
  on:( t, op, id='none', onFunc=null ) ->
    table  = @tableName(t)
    onNext = if onFunc? then onFunc else (result) => Util.log( 'Store.on()', result )
    @subscribe( table, op, id, onNext )
    return

  createTable:( t ) ->
    @tables[t] = {}
    @tables[t]

  table:( t ) ->
    if @tables[t]? then @tables[t] else @createTable(t)

  tableName:( t ) ->
     name  = Util.firstTok(t,'.') # Strips off  .json .js .csv file extensions
     table = @table( name )
     Util.noop( table )
     #Util.log( "Store.tableName()", { name:name, table:table, t:t } )
     name

  memory:( table, op, id ) ->
    # Util.log( 'Store.memory()', @toSubject(table,op,id) )
    onNext = (data) => @toMemory(  op, table, id, data )
    @stream.subscribe( @toSubject(table,op,id), onNext, @onError, @onComplete )
    return

  subscribe:( table, op, id, onNext  ) ->
    #Util.log( 'Store.subscribe()', @toSubject(table,id,op) )
    @stream.subscribe( @toSubject(table,id,op), onNext, @onError, @onComplete )
    return

  publish:( table, op, id, data, extras={} ) ->
    Util.noop( extras )
    #params = @toParams(table,id,op,extras)
    #@toMemory( op, table, id, data, params ) if @hasMemory
    @stream.publish( @toSubject(table,id,op), data )
    return

  onError:( table, op, id, result={}, error={} ) ->
    console.log( 'Store.onError', { db:@dbName, table:table, op:op, id:id, result:result, error:error } )
    #@stream.onerror( @toSubject(table,op,id), @toStoreObject( @toParams(table,id,op,extras),result ) )
    return

  # params=Store provides empty defaults
  toMemory:( op, table, id, data, params=Store ) ->
    memory = @getMemory( @dbName )
    switch op
      when 'add'    then memory.add(    table, id, data )
      when 'get'    then memory.add(    table, id, data )
      when 'put'    then memory.put(    table, id, data )
      when 'del'    then memory.del(    table, id )
      when 'insert' then memory.insert( table, data )
      when 'select' then memory.select( table, params.where )
      when 'range'  then memory.range(  table, params.beg, params.end )
      when 'update' then memory.update( table, data )
      when 'remove' then memory.remove( table, params.where  )
      when 'make'   then memory.make(   table )
      when 'show'   then memory.show(   table )
      when 'drop'   then memory.drop(   table )
      else Util.error( 'Store.toMemory() unknown op', op )
    return

  getMemory:() ->
    @hasMemory = true
    Store.memories[@dbName] = new Store.Memory( @stream, @dbName ) if Store.Memory? and not Store.memories[@dbName]?
    Store.memories[@dbName]

  getMemoryTables:() ->
    @getMemory().tables
    
  remember:() ->
    Util.noop( @getMemory(@dbName) )
    return

  toSubject:( table='none', id='none', op='none' ) ->
    subject  = "" # #{@dbName}"
    subject += "#{table}"      if table isnt 'none'
    subject += "/#{id}"        if id    isnt 'none'
    subject += "?op=#{op}"     if op    isnt 'none'
    #ubject += "?module=#{@module}"
    # Util.log( 'Store.toSubject', subject )
    subject

  toSubjectFromParams:( params ) ->
    @toSubject( params.table, params.op, params.id )

  toParams:( table, id, op, extras, where=W ) ->
    params = { db:@dbName, table:table, id:id, op:op, module:@module, where:where, beg:"", end:"" }
    Util.copyProperties( params, extras )

  # Combine params and result
  toStoreObject:( params, result ) ->
    { params:params, result:result }

  fromStoreObject:( object ) ->
    [object.params,object.result]

  # ops can be single value. ids can be an array for single record ops
  toSubjects:( tables, ops, ids ) ->
    array = []
    for i in [0...tables.length]
      elem = {}
      elem.table = tables[i]
      elem.op    = if Util.isArray(ops) then ops[i] else ops
      elem.id    = if Util.isArray(ids) then ids[i] else 'none'
      array.push( elem )
    array

  completeSubjects:( array, completeOp, onComplete ) ->
    subjects = []
    for elem in array
      op  = if elem.op? then elem.op else 'none'
      id  = if elem.id? then elem.id else 'none'
      sub = @toSubject( elem.table, op, id )
      subjects.push( sub )
    completeSubject = "#{@dbName}?module=#{@module}&op=#{completeOp}"
    callback = if typeof onComplete is 'function' then () => onComplete() else true  
    @stream.complete( completeSubject, subjects, callback )

  # ops can be single value.  
  uponTablesComplete:( tables, ops, completeOp, onComplete ) ->
    subjects = @toSubjects( tables, ops, 'none' )
    @completeSubjects( subjects, completeOp, onComplete )
    return

  toKeys:( object ) ->
    keys = []
    for own key, obj of object
      keys.push(key)
    keys

  toJSON:(     obj  ) -> if obj? then JSON.stringify(obj) else ''

  toObject:(   json ) -> if json then JSON.parse(json) else {}

  toKeysJson:( json ) -> @toKeys( JSON.parse(json) )

  toObjectsJson:( json, where ) -> Util.toObjects( JSON.parse(json), where, @keyProp )

  onComplete:()      -> Util.log(   'Store.onComplete()', 'Completed' )

  toExtras:( status, url, datatype, readyState=null, error=null ) ->
    extras = { status:status, url:url, datatype:datatype, readyState:readyState, error:error }
    extras['readyState'] = readyState if readyState?
    extras['error']      = error      if error?
    extras

  dataType:() ->
    parse = Util.parseURI( @uri )
    if parse.hostname is 'localhost' then 'json' else 'jsonp'

  # ---- Class Methods ------

  @nameDb:( uri ) -> Util.parseURI( uri ).dbName

  @requireStore:( module ) ->
    Store = null
    try
      Store = require( 'js/store/'+module )
    catch e
      Util.error( 'Store.requireStore( stream, uri, module) can not find Store module for', module )
    Store

  @createStore:( stream, uri, module ) ->
    store = null
    Klazz = Store.requireStore( module )
    store = new Klass( stream, uri, module ) if Klazz?
    store

export default Store