
Store = require( 'js/store/Store' )
$     = require( 'jquery' )

class Rest extends Store

  module.exports = Rest # Util.Export( Rest, 'store/Rest' )

  constructor:( stream, uri ) ->
    super( stream, uri, 'Rest' )
    @W = Store.where

  # Rest
  add:( table, id, object, params="" )  -> @ajaxRest( 'add',  table, id, object, params )
  get:( table, id,         params="" )  -> @ajaxRest( 'get',  table, id,         params )
  put:( table, id, object, params="" )  -> @ajaxRest( 'put',  table, id, object, params )
  del:( table, id,         params="" )  -> @ajaxRest( 'del',  table, id,         params )

  # Sql
  insert:( table, objects,  params="" )  -> @ajaxSql( 'insert', table, @W,    objects, params )
  select:( table, where=@W, params="" )  -> @ajaxSql( 'select', table, where, null,    params )
  range:(  table, beg, end, params="" )  -> @ajaxSql( 'range',  table, beg,   end,     params )
  update:( table, objects,  params="" )  -> @ajaxSql( 'update', table, @W,    objects, params )
  remove:( table, where=@W, params="" )  -> @ajaxSql( 'remove', table, where, null,    params )

  # Table - only partially implemented
  make:( table ) -> @ajaxTable( 'open', table )
  show:( table ) -> @ajaxTable( 'show', table )
  drop:( table ) -> @ajaxTable( 'drop', table )

  # Subscribe to  a table or object with id
  on:(        t, op, id='none', onFunc=null ) ->
    super.on( t, op, id,        onFunc )
    return

  ajaxRest:( op, t, id, object=null, params="" ) ->
    tableName = @tableName(t)
    url       = @urlRest(op,t,'',params)
    dataType  = @dataType()
    settings  = { url:url, type:@restOp(op), dataType:dataType, processData:false, contentType:'application/json', accepts:'application/json' }
    settings.data = @toJSON(object) if object?
    settings.success = ( data,  status, jqXHR ) =>
      result = {}
      result = @toObject(data)  if op is 'get'
      result = object           if op is 'add' or op is 'put'
      extras = @toExtras( status, url, dataType, jqXHR.readyState )
      @publish( tableName, id, op, result, extras )
    settings.error   = ( jqXHR, status, error ) =>
      result = {}
      result = object if op is 'add' or op is 'put'
      extras = @toExtras( status, url, dataType, jqXHR.readyState, error )
      @onError( tableName, id, op, result, extras )
    $.ajax( settings )
    return

  ajaxSql:( op, t, where, objects=null, params="" ) ->
    beg       = if op is 'range' then where   else null
    end       = if op is 'range' then objects else null
    tableName = @tableName(t)
    url       = @urlRest(op,t,'',params)
    dataType  = @dataType()
    settings  = { url:url, type:@restOp(op), dataType:dataType, processData:false, contentType:'application/json', accepts:'application/json' }
    settings.data = objects if objects?
    settings.success = ( data,  status, jqXHR ) =>
      result = {}
      result = Util.toObjects(data,where,@key) if data?    and ( op is 'select' or op is 'remove' ) # Need to get toArray through
      result = objects                         if objects? and ( op is 'insert' or op is 'update' )
      result = Util.toRange( data, beg, end )  if op is 'range'
      extras = @toExtras( status, url, dataType, jqXHR.readyState )
      extras.where = 'all' if op is 'select' or op is 'delete'
      @publish( tableName, 'none', op, result, extras )
    settings.error = ( jqXHR, status, error ) =>
      result = {}
      result = objects if op is 'open' or op is 'update'
      extras = @toExtras( status, url, dataType, jqXHR.readyState, error )
      extras.where = 'all' if op is 'select' or op is 'delete'
      @onError( tableName, 'none', op, result, extras )
    $.ajax( settings )
    return

  ajaxTable:( op, t ) ->
    tableName = @tableName(t)
    url       = @urlRest(op,t,'')
    dataType  = @dataType()
    settings  = { url:url, type:@restOp(op), dataType:dataType, processData:false, contentType:'application/json', accepts:'application/json' }
    settings.success = ( data,  status, jqXHR ) =>
      result = if op is 'show' then @toKeysJson(data) else {}
      extras = @toExtras( status, url, dataType, jqXHR.readyState )
      @publish( tableName, 'none', op, result, extras )
    settings.error = ( jqXHR, status, error ) =>
      extras = @toExtras( status, url, dataType, jqXHR.readyState, error )
      @onError( tableName, 'none', op, {}, extras )
    $.ajax( settings )
    return

  urlRest:( op, table, id='', params='' ) ->
    # Util.log('Store.Rest.urlRest()', @uri, table,params, @uri + '/' + table + params )
    tableJson = table  + '.json'
    switch op
      when 'add',   'get',    'put',    'del'    then @uri + '/' + tableJson + '/' + id + params
      when 'insert','select', 'update', 'remove' then @uri + '/' + tableJson            + params
      when 'open',  'show',   'make',   'drop'   then @uri + '/' + tableJson  # No Params
      when 'onChange'
        if id is '' then @uri + '/' + table      else @uri + '/' + tableJson + '/' + id + params
      else
          Util.error( 'Store.Rest.urlRest() Unknown op', op )
          @uri + '/' + tableJson

  restOp:( op ) ->
    switch op
      when 'add', 'insert', 'open' then 'post'
      when 'get', 'select', 'show' then 'get'
      when 'put', 'update', 'make' then 'put'
      when 'del', 'remove', 'drop' then 'delete'
      when 'onChange'              then 'get'
      else
        Util.error( 'Store.Rest.restOp() Unknown op', op )
        'get'
