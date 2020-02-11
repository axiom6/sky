var Store,
  hasProp = {}.hasOwnProperty;

import Util from '../res/Util.js';

Store = (function() {
  var W;

  class Store {
    static isRestOp(op) {
      return Store.restOps.indexOf(op) !== -1;
    }

    static isSqlOp(op) {
      return Store.sqlOps.indexOf(op) !== -1;
    }

    static isTableOp(op) {
      return Store.tableOps.indexOf(op) !== -1;
    }

    // Dafaults for empty arguments
    static where() {
      return true; // Default where clause filter that returns true to access all records
    }

    // @uri     = REST URI where the file part is the database
    // @keyProp = The key id property = default is ['key']
    constructor(stream1, uri1, module1) {
      this.stream = stream1;
      this.uri = uri1;
      this.module = module1;
      this.keyProp = 'key';
      this.dbName = Store.nameDb(this.uri);
      this.tables = {};
      this.hasMemory = false;
      this.justMemory = false;
    }

    // REST Api  CRUD + Subscribe for objectect records
    add(table, id, object) {
      return Util.noop(table, id, object); // Post    Create   an object into table with id
    }

    get(table, id) {
      return Util.noop(table, id); // Get     Retrieve an object from table with id
    }

    put(table, id, object) {
      return Util.noop(table, id, object); // Put     Update   an object into table with id
    }

    del(table, id) {
      return Util.noop(table, id); // Delete  Delete   an object from table with id
    }

    
    // SQL Table DML (Data Manipulation Language) with multiple objects (rows)
    insert(table, objects) {
      return Util.noop(table, objects); // Insert objects into table with unique id
    }

    select(table, where = W) {
      return Util.noop(table, where); // Select objects from table with where clause
    }

    range(table, beg, end) {
      return Util.noop(table, beg, end); // Select objects from table with where clause
    }

    update(table, objects) {
      return Util.noop(table, objects); // Update objects into table mapped by id
    }

    remove(table, wheKeys) {
      return Util.noop(table, wheKeys); // Delete objects from table with keys array or where clause
    }

    
    // Table DDL (Data Definition Language) omitted schema update
    make(table) {
      return Util.noop(table); // Create a table
    }

    show(table = void 0) {
      return Util.noop(table); // Show a list of row keys or tables if table is undefined
    }

    drop(table) {
      return Util.noop(table); // Drop the entire table - good for testing
    }

    
    // Subscribe to CRUD changes on a table or a row with id
    on(t, op, id = 'none', onFunc = null) {
      var onNext, table;
      table = this.tableName(t);
      onNext = onFunc != null ? onFunc : (result) => {
        return Util.log('Store.on()', result);
      };
      this.subscribe(table, op, id, onNext);
    }

    createTable(t) {
      this.tables[t] = {};
      return this.tables[t];
    }

    table(t) {
      if (this.tables[t] != null) {
        return this.tables[t];
      } else {
        return this.createTable(t);
      }
    }

    tableName(t) {
      var name, table;
      name = Util.firstTok(t, '.'); // Strips off  .json .js .csv file extensions
      table = this.table(name);
      Util.noop(table);
      //Util.log( "Store.tableName()", { name:name, table:table, t:t } )
      return name;
    }

    memory(table, op, id) {
      var onNext;
      // Util.log( 'Store.memory()', @toSubject(table,op,id) )
      onNext = (data) => {
        return this.toMemory(op, table, id, data);
      };
      this.stream.subscribe(this.toSubject(table, op, id), onNext, this.onError, this.onComplete);
    }

    subscribe(table, op, id, onNext) {
      //Util.log( 'Store.subscribe()', @toSubject(table,id,op) )
      this.stream.subscribe(this.toSubject(table, id, op), onNext, this.onError, this.onComplete);
    }

    publish(table, op, id, data, extras = {}) {
      Util.noop(extras);
      //params = @toParams(table,id,op,extras)
      //@toMemory( op, table, id, data, params ) if @hasMemory
      this.stream.publish(this.toSubject(table, id, op), data);
    }

    onError(table, op, id, result = {}, error = {}) {
      console.log('Store.onError', {
        db: this.dbName,
        table: table,
        op: op,
        id: id,
        result: result,
        error: error
      });
    }

    // params=Store provides empty defaults
    //@stream.onerror( @toSubject(table,op,id), @toStoreObject( @toParams(table,id,op,extras),result ) )
    toMemory(op, table, id, data, params = Store) {
      var memory;
      memory = this.getMemory(this.dbName);
      switch (op) {
        case 'add':
          memory.add(table, id, data);
          break;
        case 'get':
          memory.add(table, id, data);
          break;
        case 'put':
          memory.put(table, id, data);
          break;
        case 'del':
          memory.del(table, id);
          break;
        case 'insert':
          memory.insert(table, data);
          break;
        case 'select':
          memory.select(table, params.where);
          break;
        case 'range':
          memory.range(table, params.beg, params.end);
          break;
        case 'update':
          memory.update(table, data);
          break;
        case 'remove':
          memory.remove(table, params.where);
          break;
        case 'make':
          memory.make(table);
          break;
        case 'show':
          memory.show(table);
          break;
        case 'drop':
          memory.drop(table);
          break;
        default:
          Util.error('Store.toMemory() unknown op', op);
      }
    }

    getMemory() {
      this.hasMemory = true;
      if ((Store.Memory != null) && (Store.memories[this.dbName] == null)) {
        Store.memories[this.dbName] = new Store.Memory(this.stream, this.dbName);
      }
      return Store.memories[this.dbName];
    }

    getMemoryTables() {
      return this.getMemory().tables;
    }

    remember() {
      Util.noop(this.getMemory(this.dbName));
    }

    toSubject(table = 'none', id = 'none', op = 'none') {
      var subject;
      subject = ""; // #{@dbName}"
      if (table !== 'none') {
        subject += `${table}`;
      }
      if (id !== 'none') {
        subject += `/${id}`;
      }
      if (op !== 'none') {
        subject += `?op=${op}`;
      }
      //ubject += "?module=#{@module}"
      // Util.log( 'Store.toSubject', subject )
      return subject;
    }

    toSubjectFromParams(params) {
      return this.toSubject(params.table, params.op, params.id);
    }

    toParams(table, id, op, extras, where = W) {
      var params;
      params = {
        db: this.dbName,
        table: table,
        id: id,
        op: op,
        module: this.module,
        where: where,
        beg: "",
        end: ""
      };
      return Util.copyProperties(params, extras);
    }

    // Combine params and result
    toStoreObject(params, result) {
      return {
        params: params,
        result: result
      };
    }

    fromStoreObject(object) {
      return [object.params, object.result];
    }

    // ops can be single value. ids can be an array for single record ops
    toSubjects(tables, ops, ids) {
      var array, elem, i, j, ref;
      array = [];
      for (i = j = 0, ref = tables.length; (0 <= ref ? j < ref : j > ref); i = 0 <= ref ? ++j : --j) {
        elem = {};
        elem.table = tables[i];
        elem.op = Util.isArray(ops) ? ops[i] : ops;
        elem.id = Util.isArray(ids) ? ids[i] : 'none';
        array.push(elem);
      }
      return array;
    }

    completeSubjects(array, completeOp, onComplete) {
      var callback, completeSubject, elem, id, j, len, op, sub, subjects;
      subjects = [];
      for (j = 0, len = array.length; j < len; j++) {
        elem = array[j];
        op = elem.op != null ? elem.op : 'none';
        id = elem.id != null ? elem.id : 'none';
        sub = this.toSubject(elem.table, op, id);
        subjects.push(sub);
      }
      completeSubject = `${this.dbName}?module=${this.module}&op=${completeOp}`;
      callback = typeof onComplete === 'function' ? () => {
        return onComplete();
      } : true;
      return this.stream.complete(completeSubject, subjects, callback);
    }

    // ops can be single value.  
    uponTablesComplete(tables, ops, completeOp, onComplete) {
      var subjects;
      subjects = this.toSubjects(tables, ops, 'none');
      this.completeSubjects(subjects, completeOp, onComplete);
    }

    toKeys(object) {
      var key, keys, obj;
      keys = [];
      for (key in object) {
        if (!hasProp.call(object, key)) continue;
        obj = object[key];
        keys.push(key);
      }
      return keys;
    }

    toJSON(obj) {
      if (obj != null) {
        return JSON.stringify(obj);
      } else {
        return '';
      }
    }

    toObject(json) {
      if (json) {
        return JSON.parse(json);
      } else {
        return {};
      }
    }

    toKeysJson(json) {
      return this.toKeys(JSON.parse(json));
    }

    toObjectsJson(json, where) {
      return Util.toObjects(JSON.parse(json), where, this.keyProp);
    }

    onComplete() {
      return Util.log('Store.onComplete()', 'Completed');
    }

    toExtras(status, url, datatype, readyState = null, error = null) {
      var extras;
      extras = {
        status: status,
        url: url,
        datatype: datatype,
        readyState: readyState,
        error: error
      };
      if (readyState != null) {
        extras['readyState'] = readyState;
      }
      if (error != null) {
        extras['error'] = error;
      }
      return extras;
    }

    dataType() {
      var parse;
      parse = Util.parseURI(this.uri);
      if (parse.hostname === 'localhost') {
        return 'json';
      } else {
        return 'jsonp';
      }
    }

    // ---- Class Methods ------
    static nameDb(uri) {
      return Util.parseURI(uri).dbName;
    }

    static requireStore(module) {
      var e;
      Store = null;
      try {
        Store = require('js/store/' + module);
      } catch (error1) {
        e = error1;
        Util.error('Store.requireStore( stream, uri, module) can not find Store module for', module);
      }
      return Store;
    }

    static createStore(stream, uri, module) {
      var Klazz, store;
      store = null;
      Klazz = Store.requireStore(module);
      if (Klazz != null) {
        store = new Klass(stream, uri, module);
      }
      return store;
    }

  };

  /*
  Store.Memory    = require( 'js/store/Memory'     )
  Store.IndexedDB = require( 'js/store/IndexedDB'  )
  Store.Rest      = require( 'js/store/Rest'       )
  Store.Fire      = require( 'js/store/Fire'       )
  */
  //Store.PouchDB  = require( 'js/store/PouchDB'    )
  Store.memories = {}; // Store.Memory instances create by getMemory() for in memory dbName

  Store.databases = {}; // Set by Store.Memory as Store.databases[dbName].tables for 

  
  // CRUD        Create    Retrieve  Update    Delete
  Store.restOps = ['add', 'get', 'put', 'del'];

  Store.sqlOps = ['insert', 'select', 'update', 'remove', 'range'];

  Store.tableOps = ['open', 'show', 'make', 'drop'];

  Store.methods = Store.restOps.concat(Store.sqlOps).concat(Store.tableOps).concat(['on']);

  W = Store.where;

  return Store;

}).call(this);

export default Store;
