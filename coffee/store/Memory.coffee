
import Util  from '../res/Util.js'
import Store from './Store.js'

class Memory extends Store

  constructor:( stream, uri ) ->
    super( stream, uri, 'Memory' )
    @justMemory = true
    Store.databases[@dbName] = @tables
    Util .databases[@dbName] = @tables

  add:( t, id, object  )    ->
    @table(t)[id] = object
    @publish( t, 'add', id,     object )
    @publish( t, 'add', 'none', object )
    return

  get:( t, id ) ->
    object  = @table(t)[id]
    if object?
      @publish( t, 'get', id, object )
    else
      @onError( t, 'get', id, object,  { msg:"Id #{id} not found"} )
    return

  put:( t, id,  object ) ->
    @table(t)[id] = object
    @publish( t, 'put', id,     object )
    @publish( t, 'put', 'none', object )
    return

  del:( t, id ) ->
    object  = @table(t)[id]
    if object?
      delete @table(t)[id]
      @publish( t, 'del', id, object )
    else
      @onError( t, 'del', id, object,  { msg:"Id #{id} not found"} )
    return

  insert:( t, objects ) ->
    table   = @table(t)
    for own key, object of objects
      table[key] = object
    @publish( t, 'insert', 'none', objects )
    return

  select:( t, where=Store.where ) ->
    objects =  {}
    table   = @table(t)
    for own key, object of table when where(object)
      objects[key] = object
    @publish( t, 'select', 'none', objects, { where:where.toString() } )
    return

  range:( t, beg, end ) ->
    rows    =  {}
    table   = @table(t)
    for key, row of table when beg <= key and key <= end
      rows[key] = row
    @publish( t, 'range', 'none', rows, { beg:beg.toString(), end:end.toString() } )

  update:( t, objects ) ->
    table = @table(t)
    for own key, object of objects
      table[key] = object
    @publish( t, 'update', 'none', objects )
    return

  remove:( t, where=Store.where ) ->
    table = @table(t)
    objects = {}
    for own key, object of table when where(object)
      objects[key] = object
      delete object[key]
    @publish( t, 'remove', 'none', objects, { where:where.toString() } )
    return

  make:( t ) ->
    @createTable(t)
    @publish( t, 'make', 'none', {}, {} )
    return

  show:( t ) ->
    if Util.isStr(t)
      keys = []
      for own key, val of @tables[t]
        keys.push(key)
      @publish( t, 'show', 'none', keys,  { showing:'keys' } )
    else
      tables = []
      for own key, val of @tables
        tables.push(key)
      @publish( t, 'show', 'none', tables, { showing:'tables' } )
    return

  drop:( t ) ->
    hasTable = @tables[t]?
    if hasTable
      delete  @tables[t]
      @publish( t, 'drop', 'none', {} )
    else
      @onError( t, 'drop', 'none', {}, { msg:"Table #{t} not found"} )
    return

  # Subscribe to  a table or object with id
  on:( t, op, id='none', onFunc=null ) ->
    table  = @tableName(t)
    onNext = if onFunc? then onFunc else (data) => Util.noop( 'Memory.on()', data )
    #Util.log( 'Memory.on()', table, op, id )
    @subscribe( table, op, id, onNext )
    return

  dbTableName:( tableName ) ->
    @dbName + '/' + tableName

  importLocalStorage:( tableNames ) ->
    for tableName in tableNames
      @tables[tableName] = JSON.parse(localStorage.getItem(@dbTableName(tableName)))
    return

  exportLocalStorage:() ->
    for own tableName, table of @tables
      dbTableName = @dbTableName(tableName)
      localStorage.removeItem( dbTableName  )
      localStorage.setItem(    dbTableName, JSON.stringify(table) )
      # Util.log( 'Store.Memory.exportLocalStorage()', dbTableName )
    return

  importIndexDb:( op ) ->
    idb = new Store.IndexedDB( @stream, @dbName )
    for table in idb.dbs.objectStoreNames
      onNext = (result) =>
         @tables[table] = result if op is 'select'
      @subscribe( table, 'select', 'none', onNext )
      idb.traverse( 'select', table, {}, Store.where(), false )
    return

  exportIndexedDb:() ->
    dbVersion = 1
    idb = new Store.IndexedDB( @stream, @dbName, dbVersion, @tables )
    onIdxOpen = (dbName) =>
      idb.deleteDatabase( dbName )
      for own name, table of @tables
        onNext = (result) =>
          Util.noop( dbName, result )
        @subscribe( name,    'insert', 'none', onNext )
        idb.insert( name, table  )
    @subscribe( 'IndexedDB', 'export', 'none', (dbName) => onIdxOpen(dbName) )
    idb.openDatabase()
    return

  tableNames:() ->
    names = []
    for own key, table of @tables
      names.push(key)
    names

  logRows:( name, table ) ->
    Util.log( name )
    for own key, row of table
      Util.log( '  ', key )
      Util.log( '  ', row )
      Util.log( '  ',  JSON.stringify( row ) )

export default Memory