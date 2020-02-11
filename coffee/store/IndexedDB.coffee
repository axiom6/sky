
Store = require( 'js/store/Store' )

class IndexedDB extends Store

  module.exports = IndexedDB

  constructor:( stream, uri, @dbVersion=1, @tableNames=[] ) ->
    super( stream, uri, 'IndexedDB' )
    @indexedDB = window['indexedDB'] # or window.mozIndexedDB or window.webkitIndexedDB or window.msIndexedDB
    Util.error( 'Store.IndexedDB.constructor indexedDB not found' ) if not @indexedDB
    @dbs = null
    @objectStoreNames = null
    @openDatabase()  # Set @dbs and @objectStoreNames

  add:( t, id, object ) ->
    tableName = @tableName(t)
    txo = @txnObjectStore( tableName, "readwrite" )
    req = txo.add( obj, id )
    req.onsuccess = () => @publish( tableName, 'add', id, object )
    req.onerror   = () => @onError( tableName, 'add', id, object, { error:req.error } )
    return

  get:( t, id ) ->
    tableName = @tableName(t)
    txo = @txnObjectStore( tableName, "readonly" )
    req = txo.get(id) # Check to be sre that indexDB understands id
    req.onsuccess = () => @publish( tableName, 'get', id, req.result )
    req.onerror   = () => @onError( tableName, 'get', id, req.result, { error:req.error } )
    return

  put:( t, id, object ) ->
    tableName = @tableName(t)
    txo = @txnObjectStore( tableName, "readwrite" )
    req = txo.put(object) # Check to be sre that indexDB understands id
    req.onsuccess = () => @publish( tableName, 'put', id, object )
    req.onerror   = () => @onError( tableName, 'put', id, object, { error:req.error } )
    return

  del:( t, id ) ->
    tableName = @tableName(t)
    txo = @txnObjectStore( tableName, "readwrite" )
    req = txo['delete'](id) # Check to be sre that indexDB understands id
    req.onsuccess = () => @publish( tableName, 'del', id, req.result )
    req.onerror   = () => @onError( tableName, 'del', id, req.result, { error:req.error } )
    return

  insert:( t, objects ) ->
    tableName = @tableName(t)
    txo = @txnObjectStore( t, "readwrite" )
    for own key, object of objects
      object = @idProp( key, object, @key )
      txo.put(object)
    @publish( tableName, 'insert', 'none', objects )
    return

  select:( t, where=Store.where ) ->
    tableName = @tableName(t)
    @traverse( 'select', tableName, where )
    return

  range:( t, beg, end ) ->
    tableName = @tableName(t)
    @traverse( 'range', tableName, beg, end )
    return

  update:( t, objects ) ->
    tableName = @tableName(t)
    txo = @txnObjectStore( t, "readwrite" )
    for own key, object of objects
      object = @idProp( key, object, @key )
      txo.put(object)
    @publish( tableName, 'update', 'none', objects )
    return

  remove:( t, where=Store.where ) ->
    tableName = @tableName(t)
    @traverse( 'remove', tableName, where )
    return

  make:( t ) ->
    tableName = @tableName(t)
    # No real create table in IndexedDB so publish success
    @publish( tableName, 'open', 'none', {}, {} )
    return

  show:( t ) ->
    tableName = @tableName(t)
    @traverse( 'show', tableName )
    return

  drop:( t ) ->
    tableName = @tableName(t)
    @dbs.deleteObjectStore(t)
    @publish( tableName, 'drop', 'none' )
    return

  # Subscribe to  a table or object with id
  on:(        t, op, id='none', onFunc=null ) ->
    super.on( t, op, id,        onFunc )
    return

  # IndexedDB Specifics

  idProp:( id, object, key ) ->
    object[key] = id if not object[key]?
    object

  txnObjectStore:( t, mode, key=@key ) ->
    txo = null
    if not @dbs?
      Util.trace( 'Store.IndexedDb.txnObjectStore() @dbs null' )
    else if @objectStoreNames.contains(t)
      txn = @dbs.transaction( t, mode )
      txo = txn.objectStore(  t, { keyPath:key } )
    else
      Util.error( 'Store.IndexedDb.txnObjectStore() missing objectStore for', t )
    txo

  traverse:( op, t, where=Store.where, end=null ) ->
    mode = if op is 'select' then 'readonly' else 'readwrite'
    beg  = if op is 'range'  then where else null
    txo  = @txnObjectStore( t, mode )
    req  = txo.openCursor()
    req.onsuccess = ( event ) =>
      objects = {}
      cursor = event.target.result
      if cursor?
        objects[cursor.key] = cursor.value if op is 'select' and where(cursor.value)
        objects[cursor.key] = cursor.value if op is 'range ' and beg <= cursor.key and cursor.key <= end
        cursor.delete()                    if op is 'remove' and where(cursor.value)
        cursor.continue()
      @publish( t, op, 'none', objects,   { where:'all' } )
    req.onerror   = () =>
      @onError( t, op, 'none', {}, { where:'all', error:req.error } )
    return

  createObjectStores:() ->
    if @tableNames?
      for t in @tableNames when not @objectStoreNames.contains(t)
        @dbs.createObjectStore( t, { keyPath:@key } )
    else
      Util.error( 'Store.IndexedDB.createTables() missing @tableNames' )
    return

  openDatabase:() ->
    request = @indexedDB.open( @dbName, @dbVersion ) # request = @indexedDB.IDBFactory.open( database, @dbVersion )
    request.onupgradeneeded = ( event ) =>
      @dbs = event.target.result
      @objectStoreNames = @dbs['objectStoreNames']
      @createObjectStores()
      Util.log( 'Store.IndexedDB', 'upgrade', @dbName, @objectStoreNames )
    request.onsuccess = ( event ) =>
      @dbs = event.target.result
      Util.log( 'Store.IndexedDB', 'open',    @dbName, @objectStoreNames )
      @publish( 'none', 'open', 'none', @dbs.objectStoreNames )
    request.onerror   = () =>
      Util.error( 'Store.IndexedDB.openDatabase() unable to open', { database:@dbName, error:request.error } )
      @onError( 'none', 'open', 'none', @dbName, { error:request.error } )

  deleteDatabase:( dbName ) ->
    request = @indexedDB.deleteDatabase(dbName)
    request.onsuccess = () =>
      Util.log(   'Store.IndexedDB.deleteDatabase() deleted',          { database:dbName } )
    request.onerror   = () =>
      Util.error( 'Store.IndexedDB.deleteDatabase() unable to delete', { database:dbName, error:request.error } )
    request.onblocked = () =>
      Util.error( 'Store.IndexedDB.deleteDatabase() database blocked', { database:dbName, error:request.error } )

  close:() ->
    @dbs.close() if @dbs?