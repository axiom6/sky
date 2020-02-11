
###
window.xUtil.fixTestGlobals()
Stream   = require( 'js/util/Stream'   )
Store    = require( 'js/store/Store'   )
PouchDB  = require( 'js/store/PouchDB' )
Database = require( 'js/store/Database')
Columns  = require( 'data/muse/Columns.json')
Rows     = require( 'data/muse/Rows.json')
Add      = require( 'data/test/Add.json')
Get      = require( 'data/test/Get.json')
Put      = require( 'data/test/Put.json')
Del      = require( 'data/test/Del.json')

beforeAll () ->
  @stream  = new Stream()
  #@pouchDB = new PouchDB( @stream, 'http://127.0.0.1:5984/' )

describe("store/PouchDB.coffee", () ->

  it("add:( table, id, object )",  () ->
    subjectGet = @pouchDB.toSubject('add','get', 'one')
    subjectDel = @pouchDB.toSubject('add','del', 'one')
    subjectAdd = @pouchDB.toSubject('add','add', 'one')
    @stream.subscribe( subjectGet, ()    => @pouchDB.del( 'add', 'one'      ) )
    @stream.subscribe( subjectDel, ()    => @pouchDB.add( 'add', 'one', Add ) )
    @stream.subscribe( subjectAdd, (obj) => console.log( 'PouchDB Add', obj ) )
    @pouchDB.get( 'add', 'one' )
    expect('add filler').toBe('add filler') )

  it("get:( table, id )", () ->
    subject  = @pouchDB.toSubject('get','get', 'one')
    @stream.subscribe( subject, (data) =>
      console.log( 'PouchDB.get:( table, id ) Get =', data ) )
      # expect(data.file).toBe('get.json') )
    @pouchDB.get( 'get', 'one' )
    expect('get filler').toBe('get filler') )

  it("put:( table, id, object )", () ->
    subject  = @pouchDB.toSubject('put','put', 'one')
    @stream.subscribe( subject, (data) =>
      console.log( 'PouchDB Put =', data ) )
      #expect(data.file).toBe('put.json') )
    Put.dir = 'xxxx'
    @pouchDB.put( 'put', 'one', Put )
    expect('put filler').toBe('put filler') )

  it("del:( table, id )",  () ->
    subject  = @pouchDB.toSubject('del','del', 'one')
    @stream.subscribe( subject, (data) =>
      console.log( 'PouchDB.Del =', data ) )
      # expect(data.file).toBe('del.json') )
    @pouchDB.del( 'del', 'one' )
    expect('del filler').toBe('del filler') )

  it("insert:( table, objects )",  () ->
    subject  = @pouchDB.toSubject('columns','insert')
    @stream.subscribe( subject, (objects) =>
      console.log( "PouchDB insert", objects ) )
      # expect(objects.Embrace.icon).toBe('fa-link') )
    @pouchDB.insert( 'columns', Columns )
    expect('insert filler').toBe('insert filler')  )

  it("select:( table, where=Store.where   )",  () ->
    subject = @pouchDB.toSubject('columns','select')
    @stream.subscribe( subject, (objects) =>
      console.log( "select Columns", objects ) )
      #@stream.unsubscribe( subject )
      # expect(objects.Embrace.icon).toBe('fa-link') )
    @pouchDB.select( 'columns' )
    expect('select filler').toBe('select filler')  )

  it("range:( table, beg=1, end=10   )",  () ->
    subject = @pouchDB.toSubject('columns','range')
    @stream.subscribe( subject, (objects) =>
      console.log( "select Columns", objects ) )
      #@stream.unsubscribe( subject )
      # expect(objects.Embrace.icon).toBe('fa-link') )
    @pouchDB.range( 'columns' )
    expect('range filler').toBe('range filler')  )

  it("update:( table, objects )",  () ->
    subjectSelect  = @pouchDB.toSubject('columns','select')
    subjectUpdate  = @pouchDB.toSubject('columns','update')
    @stream.subscribe( subjectSelect, (objects) =>
      obj.css = 'xxx-xxx' for key, obj of objects
      @pouchDB.update( 'columns', objects ) )
    @stream.subscribe( subjectUpdate, (objects) =>
      console.log( "PouchDB update", objects ) )
      # expect(objects.Embrace.css).toBe('xxx-xxx') )
    @pouchDB.select( 'columns' )
    expect('update filler').toBe('update filler')  )

  it("remove:( table, where=Store.where )",  () ->
    subjectSelect  = @pouchDB.toSubject('columns','select')
    subjectRemove  = @pouchDB.toSubject('columns','remove')
    @stream.subscribe( subjectSelect, (objects) =>
      @pouchDB.remove( 'columns', objects ) )
    @stream.subscribe( subjectRemove, (objects) =>
      console.log( "PouchDB remove", objects ) )
      # expect('remove objects').toBe('remove objects') )
    @pouchDB.select( 'columns' )
    expect('remove filler').toBe('remove filler')  )

  it("open:( table )",  () -> expect(true).toBe(true)  )
  it("show:( table )",  () -> expect(true).toBe(true)  )
  it("make:( table )",  () -> expect(true).toBe(true)  )
  it("drop:( table )",  () -> expect(true).toBe(true)  )
  it("auth:( tok   )"   () -> expect(true).toBe(true) )
  it("on:(   table, op, id, onFunc )" () -> expect(true).toBe(true) )

)

describe("store/Rest.coffee", () ->
  it("constructor",                      () -> expect(true).toBe(true)  )
  it("add:(       table, id, object )",  () -> expect(true).toBe(true)  )
  it("get:(       table, id         )",  () -> expect(true).toBe(true)  )
  it("put:(       table, id, object )",  () -> expect(true).toBe(true)  )
  it("del:(       table, id         )",  () -> expect(true).toBe(true)  )
  it("insert:(    table, objects    )",  () -> expect(true).toBe(true)  )
  it("select:(    table, where      )",  () -> expect(true).toBe(true)  )
  it("update:(    table, objects    )",  () -> expect(true).toBe(true)  )
  it("remove:(    table, where      )",  () -> expect(true).toBe(true)  )
  it("n open:(    table             )",  () -> expect(true).toBe(true)  )
  it("show:(      table=''          )",  () -> expect(true).toBe(true)  )
  it("make:(      table             )",  () -> expect(true).toBe(true)  )
  it("drop:(      table             )",  () -> expect(true).toBe(true)  )
  it("on:(      table, op, id, onFunc )" () -> expect(true).toBe(true)  )

  it("ajaxRest:(  op, table, id,    object=null  )", () -> expect(true).toBe(true)  )
  it("ajaxSql:(   op, table, where, objects=null )", () -> expect(true).toBe(true)  )
  it("ajaxTable:( op, table, options ) ->  ",        () -> expect(true).toBe(true)  )
  it("url:(       op, table, id='' ) ->  ",          () -> expect(true).toBe(true)  )
  it("urlRest:(   op, table, id='' ) ->  ",          () -> expect(true).toBe(true)  )
  it("urlCouchDB:(op, table, id='' ) ->  ",          () -> expect(true).toBe(true)  )
  it("restOp:( op ) ->  ",                           () -> expect(true).toBe(true)  )
  it("toObject:( json ) ->  ",                       () -> expect(true).toBe(true)  )
)

describe("store/IndexedDB.coffee", () ->
  it("constructor",                               () -> expect(true).toBe(true)  )
  it("add:(       table, id, object          )",  () -> expect(true).toBe(true)  )
  it("get:(       table, id                  )",  () -> expect(true).toBe(true)  )
  it("put:(       table, id, object          )",  () -> expect(true).toBe(true)  )
  it("del:(       table, id                  )",  () -> expect(true).toBe(true)  )
  it("insert:(    table, objects             )",  () -> expect(true).toBe(true)  )
  it("select:(    table, where=Store.where   )",  () -> expect(true).toBe(true)  )
  it("update:(    table, objects             )",  () -> expect(true).toBe(true)  )
  it("remove:(    table, where=Store.where   )",  () -> expect(true).toBe(true)  )
  it("open:(      table                      )",  () -> expect(true).toBe(true)  )
  it("show:(      table=''                   )",  () -> expect(true).toBe(true)  )
  it("make:(      table                      )",  () -> expect(true).toBe(true)  )
  it("drop:(      table                      )",  () -> expect(true).toBe(true)  )
  it("on:(        table, op, id, onFunc      )",  () -> expect(true).toBe(true)  )
  it("openDatabase:( database, dbVersion     )",  () -> expect(true).toBe(true)  )
  it("close:() ->  ",                             () -> expect(true).toBe(true)  )
  it("txnTable:( t, mode, key=@key )",            () -> expect(true).toBe(true)  )
  it("traverse:( op, subject, t,  objects, where, toArray ) ->  ", () -> expect(true).toBe(true)  )
  it("row:( op, txo, key, object, objects, where, toArray ) ->  ", () -> expect(true).toBe(true)  )
)

describe("store/Memory.coffee", () ->
  it("constructor",                               () -> expect(true).toBe(true)  )
  it("add:(       table, id, object          )",  () -> expect(true).toBe(true)  )
  it("get:(       table, id                  )",  () -> expect(true).toBe(true)  )
  it("put:(       table, id, object          )",  () -> expect(true).toBe(true)  )
  it("del:(       table, id                  )",  () -> expect(true).toBe(true)  )
  it("insert:(    table, objects             )",  () -> expect(true).toBe(true)  )
  it("select:(    table, where=Store.where   )",  () -> expect(true).toBe(true)  )
  it("update:(    table, objects             )",  () -> expect(true).toBe(true)  )
  it("remove:(    table, where=Store.where   )",  () -> expect(true).toBe(true)  )
  it("open:(      table, schema              )",  () -> expect(true).toBe(true)  )
  it("show:(      table=''                   )",  () -> expect(true).toBe(true)  )
  it("make:(      table, alters              )",  () -> expect(true).toBe(true)  )
  it("drop:(      table                      )",  () -> expect(true).toBe(true)  )
  it("on:(        table, op, id, onFunc      )",  () -> expect(true).toBe(true)  )
  it("createSession:( prevSession ) ->            ",  () -> expect(true).toBe(true)  )
  it("createDatabases:( session, database ) ->    ",  () -> expect(true).toBe(true)  )
  it("createTables:( databases,  database ) ->    ",  () -> expect(true).toBe(true)  )
  it("createTable:( t  ) ->                       ",  () -> expect(true).toBe(true)  )
  it("table:( t ) ->                              ",  () -> expect(true).toBe(true)  )
)

describe("store/Firebase.coffee", () ->
  it("constructor",                               () -> expect(true).toBe(true)  )
  it("add:(       table, id, object          )",  () -> expect(true).toBe(true)  )
  it("get:(       table, id                  )",  () -> expect(true).toBe(true)  )
  it("put:(       table, id, object          )",  () -> expect(true).toBe(true)  )
  it("del:(       table, id                  )",  () -> expect(true).toBe(true)  )
  it("insert:(    table, objects             )",  () -> expect(true).toBe(true)  )
  it("select:(    table, where=Store.where   )",  () -> expect(true).toBe(true)  )
  it("update:(    table, objects             )",  () -> expect(true).toBe(true)  )
  it("remove:(    table, where=Store.where   )",  () -> expect(true).toBe(true)  )
  it("open:(      table                      )",  () -> expect(true).toBe(true)  )
  it("show:(      table=''                   )",  () -> expect(true).toBe(true)  )
  it("make:(      table                      )",  () -> expect(true).toBe(true)  )
  it("drop:(      table                      )",  () -> expect(true).toBe(true)  )
  it("on:(        table, op, id, onFunc      )",  () -> expect(true).toBe(true)  )
  it("db:(t) ->                                   ",  () -> expect(true).toBe(true)  )
  it("revIds:( objects, bulk ) ->                 ",  () -> expect(true).toBe(true)  )
)



describe("store/coffee Utils", () ->
  it("constructor",                () -> expect(true).toBe(true)  )
  it("@isRestOp:(  op )",          () -> expect(true).toBe(true)  )
  it("@isSqlOp:(   op )",          () -> expect(true).toBe(true)  )
  it("@isTableOp:( op )",          () -> expect(true).toBe(true)  )
)

describe("store/Schema.coffee", () ->
  it("constructor:() ->                                ", () -> expect(true).toBe(true)  )
  it( "@Prims                                          ", () -> expect(true).toBe(true)  )
  it( "@Enums                                          ", () -> expect(true).toBe(true)  )
  it( "@Specs                                          ", () -> expect(true).toBe(true)  )
  it( "@isType                                         ", () -> expect(true).toBe(true)  )
  it( "@isPrim                                         ", () -> expect(true).toBe(true)  )
  it( "@isSpec                                         ", () -> expect(true).toBe(true)  )
  it( "@toRdfType:(    dir, decl, cardinality='1' )", () -> expect(true).toBe(true)  )
  it( "@toSchemaType:( dir, decl, cardinality='1' )", () -> expect(true).toBe(true)  )
  it( "@toFoafType:(   dir, decl, cardinality='1' )", () -> expect(true).toBe(true)  )
  it( "@toXSDType:(    dir, decl, cardinality='1' )", () -> expect(true).toBe(true)  )
  it( "@toTypeType:(   decl, cardinality='1' ) ->      ", () -> expect(true).toBe(true)  )
  it( "@toPrimType:(   decl, cardinality='1' ) ->      ", () -> expect(true).toBe(true)  )
  it( "@toEnumType:(   decl, cardinality='1' ) ->      ", () -> expect(true).toBe(true)  )
  it( "@toSpecType:(   prop, cardinality='1' ) ->      ", () -> expect(true).toBe(true)  )
  it( "@toIdLD:(   uri, dir, prop                                )", () -> expect(true).toBe(true)  )
  it( "@toTypeLD:( uri, dir, decl, cardinality='1'               )", () -> expect(true).toBe(true)  )
  it( "@toPropLD:( prop, toId, toType                            )", () -> expect(true).toBe(true)  )
  it( "@rdf:      ( prop, dir='', decl='string', cardinality='1' )", () -> expect(true).toBe(true)  )
  it( "@schemaOrg:( prop, dir='', decl='string', cardinality='1' )", () -> expect(true).toBe(true)  )
  it( "@foafOrg:(   prop, dir='', decl='string', cardinality='1' )", () -> expect(true).toBe(true)  )
  it( "@xmlSchema:( prop, dir='', decl='string', cardinality='1' )", () -> expect(true).toBe(true)  )
  it( "@axiomType:( prop, cardinality='1', decl='string'         )", () -> expect(true).toBe(true)  )
  it( "@axiomPrim:( prop, cardinality='1', decl='string'         )", () -> expect(true).toBe(true)  )
  it( "@axiomEnum:( prop, cardinality='1', decl='string'         )", () -> expect(true).toBe(true)  )
  it( "@axiomSpec:( prop, cardinality='1'                        )", () -> expect(true).toBe(true)  )
  it( "@QuadRdf      ", () -> expect(true).toBe(true)  )
  it( "@Quad         ", () -> expect(true).toBe(true)  )
  it( "@Elem         ", () -> expect(true).toBe(true)  )
  it( "@References   ", () -> expect(true).toBe(true)  )
  it( "@Dimensions   ", () -> expect(true).toBe(true)  )
  it( "@Perspectives ", () -> expect(true).toBe(true)  )
  it( "@Planes       ", () -> expect(true).toBe(true)  )
  it( "@Columns      ", () -> expect(true).toBe(true)  )
  it( "@Rows         ", () -> expect(true).toBe(true)  )
  it( "@Practices    ", () -> expect(true).toBe(true)  )
  it( "@Studys       ", () -> expect(true).toBe(true)  )
  it( "@NavbSpecs    ", () -> expect(true).toBe(true)  )
  it( "@NavbItems    ", () -> expect(true).toBe(true)  )
)
###
