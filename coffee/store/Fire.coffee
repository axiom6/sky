
Store          = require( 'js/store/Store' )
Store.Firebase = firebase #require( 'firebase' )

class Fire extends Store

  module.exports   = Fire

  @OnFire  = { get:"value", add:"child_added", put:"child_changed", del:"child_removed" }

  constructor:( stream, uri, @config ) ->
    super( stream, uri, 'Fire' ) # @dbName set by Store in super constructor
    @fb = @init( @config )
    @auth() # Anonomous logins have to enabled
    @fd = Store.Firebase.database()

  init:( config ) ->
    Store.Firebase.initializeApp(config)
    #Util.log( 'Fires.init', config )
    Store.Firebase

  add:( t, id, object  ) ->
    table = @tableName(t)
    object[@keyProp] = id
    onComplete = (error) =>
      if not error?
        @publish( table, 'add', id, object )
      else
        @onError( table, 'add', id, object, { error:error } )
    @fd.ref(table+'/'+id).set( object, onComplete )
    return

  get:( t, id ) ->
    table = @tableName(t)
    onComplete = (snapshot) =>
      if snapshot? and snapshot.val()?
        @publish( table, 'get', id, snapshot.val() )
      else
        @onError( table, 'get', id, { msg:'Fire get error' } )
    @fd.ref(table+'/'+id).once('value', onComplete )
    return

  # Same as add
  put:( t, id,  object ) ->
    table = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( table, 'put', id, object )
      else
        @onError( table, 'put', id, object, { error:error } )
    @fd.ref(table+'/'+id).set( object, onComplete )
    return

  del:( t, id ) ->
    table = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( table, 'del', id, {} )
      else
        @onError( table, 'del', id, {}, { error:error } )
    @fd.ref(table+'/'+id).remove( onComplete )
    return

  insert:( t, objects ) ->
    table  = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( table, 'insert', 'none', objects )
      else
        @onError( table, 'insert', 'none', { error:error } )
    @fd.ref(table).set( objects, onComplete )
    return

  select:( t, where=Store.where ) ->
    Util.noop( where )
    table = @tableName(t)
    onComplete = (snapshot) =>
      if snapshot? and snapshot.val()?
        #val = @toObjects( snapshot.val() )
        @publish( table, 'select', 'none', snapshot.val() )
      else
        @publish( table, 'select', 'none', {} ) # Publish empty results
    @fd.ref(table).once('value', onComplete )
    return

  range:( t, beg, end ) ->
    table = @tableName(t)
    #Util.log( 'Fire.range  beg', t, beg, end )
    onComplete = (snapshot) =>
      if snapshot? and snapshot.val()?
        val = @toObjects( snapshot.val() )
        @publish( table, 'range', 'none', val )
      else
        @publish( table, 'range', 'none', {}  )  # Publish empty results
    @fd.ref(table).orderByKey().startAt(beg).endAt(end).once('value', onComplete )
    return

  update:( t, objects ) ->
    table  = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( table, 'update', 'none', objects )
      else
        @onError( table, 'update', 'none', { error:error } )
    @fd.ref(table).update( objects, onComplete )
    return

  remove:( t, keys ) ->
    table = @tableName(t)
    ref       = @fd.ref(table)
    ref.child(key).remove() for key in keys
    @publish( table, 'remove', 'none', keys )
    return

  make:( t ) ->
    table = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( table, 'make', 'none', {}, {} )
      else
        @onError(  table, 'make', 'none', {}, { error:error } )
    @fd.ref().set( table, onComplete )
    return

  show:( t, where=Store.where ) ->
    table  = if t? then @tableName(t) else @dbName
    onComplete = (snapshot) =>
      if snapshot? and snapshot.val()?
        keys = Util.toKeys( snapshot.val(), where, @keyProp )
        @publish( table, 'show', 'none', keys, { where:where.toString() } )
      else
        @onError( table, 'show', 'none', {},   { where:where.toString() } )
    if t?
      @fd.ref(table).once('value', onComplete )
    else
      @fd.ref(     ).once('value', onComplete )
    return

  # ref.remove( onComplete ) is Dangerous and has removed all tables in Firebase
  drop:( t ) ->
    table = @tableName(t)
    @onError( table, 'drop', 'none', {}, { error:'Fire.drop(t) not implemented'  } )
    return

  # ref.remove( onComplete ) is Dangerous and has removed all tables in Firebase
  dropDanger:( t ) ->
    table = @tableName(t)
    onComplete = (error) =>
      if not error?
        @publish( table, 'drop', 'none', {} )
      else
        @onError( table, 'drop', 'none', {}, { error:error } )
    ref = @fd.ref(table)
    ref.remove( onComplete )  # Dangerous
    return

  # Have too clarify id with snapshot.key
  on:( t, onEvt, id='none', onFunc=null ) ->
    table  = @tableName(t)
    onComplete = (snapshot) =>
      if snapshot?
        key = snapshot.key
        val = snapshot.val() # @toObjects( snapshot.val() )
        if onFunc?
           onFunc( key, val )
        else
           @publish( table, onEvt, key, val )
      else
        @onError( table, onEvt, id, {}, { error:'error' } )
    path  = if id is 'none' then table else table + '/' + id
    @fd.ref(path).on( Fire.OnFire[onEvt], onComplete )
    return

  # keyProp only needed if rows is array
  toObjects:( rows ) ->
    objects = {}
    if Util.isArray(rows)
      for row in rows
        if row? and row['key']?
          ckey = row['key'].split('/')[0]
          objects[row[ckey]] = @toObjects(row)
          Util.log( 'Fire.toObjects', { rkowKey:row['key'], ckey:ckey, row:row } )
        else
          Util.error( "Fire.toObjects() row array element requires key property", row )
    else
      objects = rows
    objects

  # Sign Anonymously
  auth:( ) ->
   onerror = (error) =>
     @onError( 'none', 'none', 'anon', {}, { error:error } )
   @fb.auth().signInAnonymously().catch( onerror )
   return

