var Memory,
  hasProp = {}.hasOwnProperty;

import Util from '../res/Util.js';

import Store from './Store.js';

Memory = class Memory extends Store {
  constructor(stream, uri) {
    super(stream, uri, 'Memory');
    this.justMemory = true;
    Store.databases[this.dbName] = this.tables;
    Util.databases[this.dbName] = this.tables;
  }

  add(t, id, object) {
    this.table(t)[id] = object;
    this.publish(t, 'add', id, object);
    this.publish(t, 'add', 'none', object);
  }

  get(t, id) {
    var object;
    object = this.table(t)[id];
    if (object != null) {
      this.publish(t, 'get', id, object);
    } else {
      this.onError(t, 'get', id, object, {
        msg: `Id ${id} not found`
      });
    }
  }

  put(t, id, object) {
    this.table(t)[id] = object;
    this.publish(t, 'put', id, object);
    this.publish(t, 'put', 'none', object);
  }

  del(t, id) {
    var object;
    object = this.table(t)[id];
    if (object != null) {
      delete this.table(t)[id];
      this.publish(t, 'del', id, object);
    } else {
      this.onError(t, 'del', id, object, {
        msg: `Id ${id} not found`
      });
    }
  }

  insert(t, objects) {
    var key, object, table;
    table = this.table(t);
    for (key in objects) {
      if (!hasProp.call(objects, key)) continue;
      object = objects[key];
      table[key] = object;
    }
    this.publish(t, 'insert', 'none', objects);
  }

  select(t, where = Store.where) {
    var key, object, objects, table;
    objects = {};
    table = this.table(t);
    for (key in table) {
      if (!hasProp.call(table, key)) continue;
      object = table[key];
      if (where(object)) {
        objects[key] = object;
      }
    }
    this.publish(t, 'select', 'none', objects, {
      where: where.toString()
    });
  }

  range(t, beg, end) {
    var key, row, rows, table;
    rows = {};
    table = this.table(t);
    for (key in table) {
      row = table[key];
      if (beg <= key && key <= end) {
        rows[key] = row;
      }
    }
    return this.publish(t, 'range', 'none', rows, {
      beg: beg.toString(),
      end: end.toString()
    });
  }

  update(t, objects) {
    var key, object, table;
    table = this.table(t);
    for (key in objects) {
      if (!hasProp.call(objects, key)) continue;
      object = objects[key];
      table[key] = object;
    }
    this.publish(t, 'update', 'none', objects);
  }

  remove(t, where = Store.where) {
    var key, object, objects, table;
    table = this.table(t);
    objects = {};
    for (key in table) {
      if (!hasProp.call(table, key)) continue;
      object = table[key];
      if (!(where(object))) {
        continue;
      }
      objects[key] = object;
      delete object[key];
    }
    this.publish(t, 'remove', 'none', objects, {
      where: where.toString()
    });
  }

  make(t) {
    this.createTable(t);
    this.publish(t, 'make', 'none', {}, {});
  }

  show(t) {
    var key, keys, ref, ref1, tables, val;
    if (Util.isStr(t)) {
      keys = [];
      ref = this.tables[t];
      for (key in ref) {
        if (!hasProp.call(ref, key)) continue;
        val = ref[key];
        keys.push(key);
      }
      this.publish(t, 'show', 'none', keys, {
        showing: 'keys'
      });
    } else {
      tables = [];
      ref1 = this.tables;
      for (key in ref1) {
        if (!hasProp.call(ref1, key)) continue;
        val = ref1[key];
        tables.push(key);
      }
      this.publish(t, 'show', 'none', tables, {
        showing: 'tables'
      });
    }
  }

  drop(t) {
    var hasTable;
    hasTable = this.tables[t] != null;
    if (hasTable) {
      delete this.tables[t];
      this.publish(t, 'drop', 'none', {});
    } else {
      this.onError(t, 'drop', 'none', {}, {
        msg: `Table ${t} not found`
      });
    }
  }

  // Subscribe to  a table or object with id
  on(t, op, id = 'none', onFunc = null) {
    var onNext, table;
    table = this.tableName(t);
    onNext = onFunc != null ? onFunc : (data) => {
      return Util.noop('Memory.on()', data);
    };
    //Util.log( 'Memory.on()', table, op, id )
    this.subscribe(table, op, id, onNext);
  }

  dbTableName(tableName) {
    return this.dbName + '/' + tableName;
  }

  importLocalStorage(tableNames) {
    var i, len, tableName;
    for (i = 0, len = tableNames.length; i < len; i++) {
      tableName = tableNames[i];
      this.tables[tableName] = JSON.parse(localStorage.getItem(this.dbTableName(tableName)));
    }
  }

  exportLocalStorage() {
    var dbTableName, ref, table, tableName;
    ref = this.tables;
    for (tableName in ref) {
      if (!hasProp.call(ref, tableName)) continue;
      table = ref[tableName];
      dbTableName = this.dbTableName(tableName);
      localStorage.removeItem(dbTableName);
      localStorage.setItem(dbTableName, JSON.stringify(table));
    }
  }

  // Util.log( 'Store.Memory.exportLocalStorage()', dbTableName )
  importIndexDb(op) {
    var i, idb, len, onNext, ref, table;
    idb = new Store.IndexedDB(this.stream, this.dbName);
    ref = idb.dbs.objectStoreNames;
    for (i = 0, len = ref.length; i < len; i++) {
      table = ref[i];
      onNext = (result) => {
        if (op === 'select') {
          return this.tables[table] = result;
        }
      };
      this.subscribe(table, 'select', 'none', onNext);
      idb.traverse('select', table, {}, Store.where(), false);
    }
  }

  exportIndexedDb() {
    var dbVersion, idb, onIdxOpen;
    dbVersion = 1;
    idb = new Store.IndexedDB(this.stream, this.dbName, dbVersion, this.tables);
    onIdxOpen = (dbName) => {
      var name, onNext, ref, results, table;
      idb.deleteDatabase(dbName);
      ref = this.tables;
      results = [];
      for (name in ref) {
        if (!hasProp.call(ref, name)) continue;
        table = ref[name];
        onNext = (result) => {
          return Util.noop(dbName, result);
        };
        this.subscribe(name, 'insert', 'none', onNext);
        results.push(idb.insert(name, table));
      }
      return results;
    };
    this.subscribe('IndexedDB', 'export', 'none', (dbName) => {
      return onIdxOpen(dbName);
    });
    idb.openDatabase();
  }

  tableNames() {
    var key, names, ref, table;
    names = [];
    ref = this.tables;
    for (key in ref) {
      if (!hasProp.call(ref, key)) continue;
      table = ref[key];
      names.push(key);
    }
    return names;
  }

  logRows(name, table) {
    var key, results, row;
    Util.log(name);
    results = [];
    for (key in table) {
      if (!hasProp.call(table, key)) continue;
      row = table[key];
      Util.log('  ', key);
      Util.log('  ', row);
      results.push(Util.log('  ', JSON.stringify(row)));
    }
    return results;
  }

};

export default Memory;
