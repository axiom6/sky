  // Static method utilities       - Util is a global without a functional wrapper
  // coffee -c -bare Util.coffee   - prevents function wrap to put Util in global namespace
  // Very important requires that Util.js be loaded first
var Util,
  hasProp = {}.hasOwnProperty;

Util = (function() {
  class Util {
    // ------ Modules ------
    static init(moduleCommonJS = void 0, moduleWebPack = void 0, root = Util.root, prj = "ui") {
      Util.root = root;
      Util.rootJS = Util.root + 'js/';
      Util.arg = prj;
      Util.prj = prj === 'skytest' ? 'skyline' : prj;
      Util.resetModuleExports(Util.prj);
      Util.fixTestGlobals();
      if (Util.isCommonJS && (moduleCommonJS != null)) {
        require(moduleCommonJS);
      } else if (Util.isWebPack && (moduleWebPack != null)) {
        Util.skipReady = true;
        Util.loadScript(moduleWebPack);
      } else {
        Util.error(`Bad arguments for Util.init() isCommonJS=${Util.isCommonJS},\nroot=${root}, moduleCommonJS=${(moduleCommonJS != null)}, moduleWebPack=${moduleWebPack}`);
      }
    }

    // Questionable but needed to support Electron + Webpack + Simple Browser which is not advised
    static requireModule(module, prj = null) {
      if (Util[module] != null) {
        //til.log('Util[module]?')
        return Util[module];
      } else if (Util.isCommonJS) {
        if ((Util.module == null) && (prj != null)) {
          Util.resetModuleExports(prj);
        }
        //Util.log('Util.isCommonJS' )
        return require(module);
      } else if (typeof require !== "undefined" && require !== null) {
        //Util.log('Util require', Util.isCommonJS )
        return require(module);
      } else if (module === 'jquery' && (window['jQuery'] != null)) {
        //Util.log('Util  window[jQuery]')
        return window['jQuery'];
      } else if (window[module] != null) {
        //Util.log('Util  window[module]?')
        return window[module] != null;
      } else {
        //msg = { $:window.$?, jquery:window.jquery?, jQuery:window.jQuery?, isCommonJS: Util.isCommonJS  }
        Util.error('Util.requireModule() module not found', module);
        return null;
      }
    }

    static initJasime(prj) {
      Util.resetModuleExports(prj);
      if (!Util.isCommonJS) {
        window.require = Util.loadScript;
      } else {
        Util.fixTestGlobals();
        window.exports = module.exports;
        window.jasmineRequire = window.exports;
      }
    }

    // Use to to prevent dynamic resolve in webpack where Util is not included
    // Need require for WebPath. For now can only warn
    static require(path) {
      if (Util.isCommonJS) {
        return require(path);
      } else if (Util.isWebPack) {
        Util.warn('Util.require may not work with WebPack', path);
        return require(path);
      } else {
        return Util.loadScript(path + '.js');
      }
    }

    static fixTestGlobals() {
      return window.Util = Util;
    }

    //window.xUtil = Util
    static loadScript(path, fn) {
      var head, script;
      head = document.getElementsByTagName('head')[0];
      script = document.createElement('script');
      script.src = path;
      script.async = false;
      if (Util.isFunc(fn)) {
        script.onload = fn;
      }
      head.appendChild(script);
    }

    static resetModuleExports(prj) {
      if (Util.isCommonJS) {
        Util.module = require('module');
        Util.module.globalPaths.push(`/Users/ax/Documents/prj/${prj}/`);
      }
    }

    //window.global = window
    //Util.log( "Node Module Paths", Util.module.globalPaths )
    static ready(fn) {
      if (!Util.isFunc(fn)) { // Sanity check
        return;
      } else if (Util.skipReady) {
        fn();
      } else if (document.readyState === 'complete') { // If document is already loaded, run method
        fn();
      } else {
        document.addEventListener('DOMContentLoaded', fn, false);
      }
    }

    // ---- Inquiry ----
    static hasMethod(obj, method, issue = false) {
      var has;
      has = typeof obj[method] === 'function';
      if (!has && issue) {
        Util.log('Util.hasMethod()', method, has);
      }
      return has;
    }

    static hasGlobal(global, issue = true) {
      var has;
      has = window[global] != null;
      if (!has && issue) {
        Util.error(`Util.hasGlobal() ${global} not present`);
      }
      return has;
    }

    static getGlobal(global, issue = true) {
      if (Util.hasGlobal(global, issue)) {
        return window[global];
      } else {
        return null;
      }
    }

    static hasPlugin(plugin, issue = true) {
      var glob, has, plug;
      glob = Util.firstTok(plugin, '.');
      plug = Util.lastTok(plugin, '.');
      has = (window[glob] != null) && (window[glob][plug] != null);
      if (!has && issue) {
        Util.error(`Util.hasPlugin()  $${glob + '.' + plug} not present`);
      }
      return has;
    }

    static hasModule(path, issue = true) {
      var has;
      has = Util.modules[path] != null;
      if (!has && issue) {
        Util.error(`Util.hasModule() ${path} not present`);
      }
      return has;
    }

    static dependsOn() {
      var arg, has, j, len1, ok;
      ok = true;
      for (j = 0, len1 = arguments.length; j < len1; j++) {
        arg = arguments[j];
        has = Util.hasGlobal(arg, false) || Util.hasModule(arg, false) || Util.hasPlugin(arg, false);
        if (!has) {
          Util.error('Missing Dependency', arg);
        }
        if (has === false) {
          ok = has;
        }
      }
      return ok;
    }

    // ---- Instances ----
    static setInstance(instance, path) {
      Util.log('Util.setInstance()', path);
      if ((instance == null) && (path != null)) {
        Util.error('Util.setInstance() instance not defined for path', path);
      } else if ((instance != null) && (path == null)) {
        Util.error('Util.setInstance() path not defined for instance', instance.toString());
      } else {
        Util.instances[path] = instance;
      }
    }

    static getInstance(path, dbg = false) {
      var instance;
      if (dbg) {
        Util.log('getInstance', path);
      }
      instance = Util.instances[path];
      if (instance == null) {
        Util.error('Util.getInstance() instance not defined for path', path);
      }
      return instance;
    }

    // ---- Logging -------

    // args should be the arguments passed by the original calling function
    // This method should not be called directly
    static toStrArgs(prefix, args) {
      var arg, j, len1, str;
      Util.logStackNum = 0;
      str = Util.isStr(prefix) ? prefix + " " : "";
      for (j = 0, len1 = args.length; j < len1; j++) {
        arg = args[j];
        str += Util.toStr(arg) + " ";
      }
      return str;
    }

    static toStr(arg) {
      Util.logStackNum++;
      if (Util.logStackNum > Util.logStackMax) {
        return '';
      }
      switch (typeof arg) {
        case 'null':
          return 'null';
        case 'string':
          return Util.toStrStr(arg);
        case 'number':
          return arg.toString();
        case 'object':
          return Util.toStrObj(arg);
        default:
          return arg;
      }
    }

    // Recusively stringify arrays and objects
    static toStrObj(arg) {
      var a, j, key, len1, str, val;
      str = "";
      if (arg == null) {
        str += "null";
      } else if (Util.isArray(arg)) {
        str += "[ ";
        for (j = 0, len1 = arg.length; j < len1; j++) {
          a = arg[j];
          str += Util.toStr(a) + ",";
        }
        str = str.substr(0, str.length - 1) + " ]";
      } else if (Util.isObjEmpty(arg)) {
        str += "{}";
      } else {
        str += "{ ";
        for (key in arg) {
          if (!hasProp.call(arg, key)) continue;
          val = arg[key];
          str += key + ":" + Util.toStr(val) + ", ";
        }
        str = str.substr(0, str.length - 2) + " }"; // Removes last comma
      }
      return str;
    }

    static toStrStr(arg) {
      if (arg.length > 0) {
        return arg;
      } else {
        return '""';
      }
    }

    // Consume unused but mandated variable to pass code inspections
    static noop() {
      if (false) {
        Util.log(arguments);
      }
    }

    // Conditional log arguments through console
    static dbg() {
      var str;
      if (!Util.debug) {
        return;
      }
      str = Util.toStrArgs('', arguments);
      Util.consoleLog(str);
    }

    //@gritter( { title:'Log', time:2000 }, str )
    static msg() {
      var str;
      if (!Util.message) {
        return;
      }
      str = Util.toStrArgs('', arguments);
      Util.consoleLog(str);
    }

    // Log Error and arguments through console and Gritter
    static error() {
      var str;
      str = Util.toStrArgs('Error:', arguments);
      Util.consoleLog(str);
    }

    // Log Warning and arguments through console and Gritter
    // Util.trace( 'Trace:' )
    static warn() {
      var str;
      str = Util.toStrArgs('Warning:', arguments);
      Util.consoleLog(str);
    }

    static toError() {
      var str;
      str = Util.toStrArgs('Error:', arguments);
      return new Error(str);
    }

    // Log arguments through console if it exists
    static log() {
      var str;
      str = Util.toStrArgs('', arguments);
      Util.consoleLog(str);
    }

    // Log arguments through gritter if it exists
    static called() {
      var str;
      str = Util.toStrArgs('', arguments);
      Util.consoleLog(str);
    }

    //@gritter( { title:'Called', time:2000 }, str )
    static gritter(opts, ...args) {
      var str;
      if (!(Util.hasGlobal('$', false) && ($['gritter'] != null))) {
        return;
      }
      str = Util.toStrArgs('', args);
      opts.title = opts.title != null ? opts.title : 'Gritter';
      opts.text = str;
    }

    static consoleLog(str) {
      if (typeof console !== "undefined" && console !== null) {
        console.log(str);
      }
    }

    static trace() {
      var error, str;
      str = Util.toStrArgs('Trace:', arguments);
      Util.consoleLog(str);
      try {
        throw new Error(str);
      } catch (error1) {
        error = error1;
        Util.log(error.stack);
      }
    }

    static alert() {
      var str;
      str = Util.toStrArgs('', arguments);
      Util.consoleLog(str);
      alert(str);
    }

    // Does not work
    static logJSON(json) {
      return Util.consoleLog(json);
    }

    // ------ Validators ------
    static keys(o) {
      if (Util.isObj(o)) {
        return Object.keys(o);
      } else {
        return [];
      }
    }

    static isDef(d) {
      return d != null;
    }

    static isNot(d) {
      return !Util.isDef(d);
    }

    static isStr(s) {
      return (s != null) && typeof s === "string" && s.length > 0;
    }

    static isNum(n) {
      return (n != null) && typeof n === "number" && !isNaN(n);
    }

    static isObj(o) {
      return (o != null) && typeof o === "object";
    }

    static isVal(v) {
      return typeof v === "number" || typeof v === "string" || typeof v === "boolean";
    }

    static isObjEmpty(o) {
      return Util.isObj(o) && Object.getOwnPropertyNames(o).length === 0;
    }

    static isFunc(f) {
      return (f != null) && typeof f === "function";
    }

    static isArray(a) {
      return (a != null) && Array.isArray(a) && (a.length != null) && a.length > 0;
    }

    static isEvent(e) {
      return (e != null) && (e.target != null);
    }

    static inIndex(a, i) {
      return Util.isArray(a) && 0 <= i && i < a.length;
    }

    static inArray(a, e) {
      return Util.isArray(a) && a.indexOf(e) > -1;
    }

    static inString(s, e) {
      return Util.isStr(s) && s.indexOf(e) > -1;
    }

    static atLength(a, n) {
      return Util.isArray(a) && a.length === n;
    }

    static head(a) {
      if (Util.isArray(a)) {
        return a[0];
      } else {
        return null;
      }
    }

    static tail(a) {
      if (Util.isArray(a)) {
        return a[a.length - 1];
      } else {
        return null;
      }
    }

    static time() {
      return new Date().getTime();
    }

    static isStrInteger(s) {
      return /^\s*(\+|-)?\d+\s*$/.test(s);
    }

    static isStrFloat(s) {
      return /^\s*(\+|-)?((\d+(\.\d+)?)|(\.\d+))\s*$/.test(s);
    }

    static isStrCurrency(s) {
      return /^\s*(\+|-)?((\d+(\.\d\d)?)|(\.\d\d))\s*$/.test(s);
    }

    //@isStrEmail:(s)   -> /^\s*[\w\-\+_]+(\.[\w\-\+_]+)*\@[\w\-\+_]+\.[\w\-\+_]+(\.[\w\-\+_]+)*\s*$/.test(s)
    static isEmpty($elem) {
      return ($elem != null) && ($elem.length != null) && $elem.length === 0; // For jQuery
    }

    static isDefs() {
      var arg, j, len1;
      for (j = 0, len1 = arguments.length; j < len1; j++) {
        arg = arguments[j];
        if (arg == null) {
          return false;
        }
      }
      return true;
    }

    static copyProperties(to, from) {
      var key, val;
      for (key in from) {
        if (!hasProp.call(from, key)) continue;
        val = from[key];
        to[key] = val;
      }
      return to;
    }

    static contains(array, value) {
      return Util.isArray(array) && array.indexOf(value) !== -1;
    }

    // Screen absolute (left top width height) percent positioning and scaling

    // Percent array to position mapping
    static toPosition(array) {
      return {
        left: array[0],
        top: array[1],
        width: array[2],
        height: array[3]
      };
    }

    // Adds Percent from array for CSS position mapping
    static toPositionPc(array) {
      return {
        position: 'absolute',
        left: array[0] + '%',
        top: array[1] + '%',
        width: array[2] + '%',
        height: array[3] + '%'
      };
    }

    static cssPosition($, screen, port, land) {
      var array;
      array = screen.orientation === 'Portrait' ? port : land;
      $.css(Util.toPositionPc(array));
    }

    static xyScale(prev, next, port, land) {
      var xn, xp, xs, yn, yp, ys;
      [xp, yp] = prev.orientation === 'Portrait' ? [port[2], port[3]] : [land[2], land[3]];
      [xn, yn] = next.orientation === 'Portrait' ? [port[2], port[3]] : [land[2], land[3]];
      xs = next.width * xn / (prev.width * xp);
      ys = next.height * yn / (prev.height * yp);
      return [xs, ys];
    }

    // ----------------- Guarded jQuery dependent calls -----------------
    static resize(callback) {
      window.onresize = function() {
        return setTimeout(callback, 100);
      };
    }

    static resizeTimeout(callback, timeout = null) {
      window.onresize = function() {
        if (timeout != null) {
          clearTimeout(timeout);
        }
        return timeout = setTimeout(callback, 100);
      };
    }

    // ------ Html ------------
    static getHtmlId(name, type = '', ext = '') {
      return name + type + ext;
    }

    static htmlId(name, type = '', ext = '') {
      var id;
      id = Util.getHtmlId(name, type, ext);
      if (Util.htmlIds[id] != null) {
        Util.error('Util.htmlId() duplicate html id', id);
      }
      Util.htmlIds[id] = id;
      return id;
    }

    static toPage(path) {
      return window.location = path;
    }

    // ------ Converters ------
    static extend(obj, mixin) {
      var method, name;
      for (name in mixin) {
        if (!hasProp.call(mixin, name)) continue;
        method = mixin[name];
        obj[name] = method;
      }
      return obj;
    }

    static include(klass, mixin) {
      return Util.extend(klass.prototype, mixin);
    }

    static eventErrorCode(e) {
      var errorCode;
      errorCode = (e.target != null) && e.target.errorCode ? e.target.errorCode : 'unknown';
      return {
        errorCode: errorCode
      };
    }

    static toName(s1) {
      var s2, s3, s4;
      s2 = s1.replace('_', ' ');
      s3 = s2.replace(/([A-Z][a-z])/g, ' $1');
      s4 = s3.replace(/([A-Z]+)/g, ' $1');
      return s4;
    }

    static toName1(s1) {
      var s2, s3;
      s2 = s1.replace('_', ' ');
      s3 = s2.replace(/([A-Z][a-z])/g, ' $1');
      return s3.substring(1);
    }

    static toSelect(name) {
      return name.replace(' ', '');
    }

    static indent(n) {
      var i, j, ref, str;
      str = '';
      for (i = j = 0, ref = n; (0 <= ref ? j < ref : j > ref); i = 0 <= ref ? ++j : --j) {
        str += ' ';
      }
      return str;
    }

    static hashCode(str) {
      var hash, i, j, ref;
      hash = 0;
      for (i = j = 0, ref = str.length; (0 <= ref ? j < ref : j > ref); i = 0 <= ref ? ++j : --j) {
        hash = (hash << 5) - hash + str.charCodeAt(i);
      }
      return hash;
    }

    static lastTok(str, delim) {
      return str.split(delim).pop();
    }

    static firstTok(str, delim) {
      if (Util.isStr(str) && (str.split != null)) {
        return str.split(delim)[0];
      } else {
        Util.error("Util.firstTok() str is not at string", str);
        return '';
      }
    }

    static padEnd(str, len, ch = ' ') {
      var j, pad, ref, ref1;
      pad = "";
      for (j = ref = str.length, ref1 = len; (ref <= ref1 ? j < ref1 : j > ref1); ref <= ref1 ? j++ : j--) {
        pad += ch;
      }
      return str + pad;
    }

    /*
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
    */
    static pdfCSS(href) {
      var link;
      if (!window.location.search.match(/pdf/gi)) {
        return;
      }
      link = document.createElement('link');
      link.rel = 'stylesheet';
      link.type = 'text/css';
      link.href = href;
      document.getElementsByTagName('head')[0].appendChild(link);
    }

    static parseURI(uri) {
      var a, j, len1, name, nameValue, nameValues, parse, value;
      parse = {};
      parse.params = {};
      a = document.createElement('a');
      a.href = uri;
      parse.href = a.href;
      parse.protocol = a.protocol;
      parse.hostname = a.hostname;
      parse.port = a.port;
      parse.segments = a.pathname.split('/');
      parse.fileExt = parse.segments.pop().split('.');
      parse.file = parse.fileExt[0];
      parse.ext = parse.fileExt.length === 2 ? parse.fileExt[1] : '';
      parse.dbName = parse.file;
      parse.fragment = a.hash;
      parse.query = Util.isStr(a.search) ? a.search.substring(1) : '';
      nameValues = parse.query.split('&');
      if (Util.isArray(nameValues)) {
        for (j = 0, len1 = nameValues.length; j < len1; j++) {
          nameValue = nameValues[j];
          [name, value] = nameValue.split('=');
          parse.params[name] = value;
        }
      }
      return parse;
    }

    static quicksort(array, prop, order) {
      var a, head, large, small;
      if (array.length === 0) {
        return [];
      }
      head = array.pop();
      if (order === 'Ascend') {
        small = (function() {
          var j, len1, results;
          results = [];
          for (j = 0, len1 = array.length; j < len1; j++) {
            a = array[j];
            if (a[prop] <= head[prop]) {
              results.push(a);
            }
          }
          return results;
        })();
        large = (function() {
          var j, len1, results;
          results = [];
          for (j = 0, len1 = array.length; j < len1; j++) {
            a = array[j];
            if (a[prop] > head[prop]) {
              results.push(a);
            }
          }
          return results;
        })();
        return (Util.quicksort(small, prop, order)).concat([head]).concat(Util.quicksort(large, prop, order));
      } else {
        small = (function() {
          var j, len1, results;
          results = [];
          for (j = 0, len1 = array.length; j < len1; j++) {
            a = array[j];
            if (a[prop] >= head[prop]) {
              results.push(a);
            }
          }
          return results;
        })();
        large = (function() {
          var j, len1, results;
          results = [];
          for (j = 0, len1 = array.length; j < len1; j++) {
            a = array[j];
            if (a[prop] < head[prop]) {
              results.push(a);
            }
          }
          return results;
        })();
        return (Util.quicksort(small, prop, order)).concat([head]).concat(Util.quicksort(large, prop, order));
      }
    }

    static quicksortArray(array) {
      var a, head, large, small;
      if (array.length === 0) {
        return [];
      }
      head = array.pop();
      small = (function() {
        var j, len1, results;
        results = [];
        for (j = 0, len1 = array.length; j < len1; j++) {
          a = array[j];
          if (a <= head) {
            results.push(a);
          }
        }
        return results;
      })();
      large = (function() {
        var j, len1, results;
        results = [];
        for (j = 0, len1 = array.length; j < len1; j++) {
          a = array[j];
          if (a > head) {
            results.push(a);
          }
        }
        return results;
      })();
      return (Util.quicksort(small)).concat([head]).concat(Util.quicksort(large));
    }

    // Sort with array.val using the internal JavaScript array sort
    // This did not work in the Skyline Master class
    static sortArray(array, prop, type, order) {
      var compare;
      compare = function(a, b) {
        if (a[prop] === b[prop]) {
          return 0;
        } else if (a[prop] < b[prop]) {
          return -1;
        } else {
          return 1;
        }
      };
      compare = function(a, b) {
        if (type === 'string' && order === 'Decend') {
          if (a[prop] === b[prop]) {
            return 0;
          } else if (a[prop] < b[prop]) {
            return 1;
          } else {
            return -1;
          }
        }
      };
      compare = function(a, b) {
        if (type === 'number' && order === 'Ascend') {
          return a[prop] - b[prop];
        }
      };
      compare = function(a, b) {
        if (type === 'number' && order === 'Decend') {
          return b[prop] - a[prop];
        }
      };
      return array.sort(compare);
    }

    static pad(m) {
      var n;
      n = Util.toInt(m);
      if (n < 10) {
        return '0' + n.toString();
      } else {
        return n.toString();
      }
    }

    static padStr(n) {
      if (n < 10) {
        return '0' + n.toString();
      } else {
        return n.toString();
      }
    }

    // Return and ISO formated data string
    static isoDateTime(dateIn) {
      var date, pad;
      date = dateIn != null ? dateIn : new Date();
      Util.log('Util.isoDatetime()', date);
      Util.log('Util.isoDatetime()', date.getUTCMonth(), date.getUTCDate(), date.getUTCHours(), date.getUTCMinutes, date.getUTCSeconds);
      pad = function(n) {
        return Util.pad(n);
      };
      return date.getFullYear()(+'-' + pad(date.getUTCMonth() + 1) + '-' + pad(date.getUTCDate()) + 'T' + pad(date.getUTCHours()) + ':' + pad(date.getUTCMinutes()) + ':' + pad(date.getUTCSeconds()) + 'Z');
    }

    static toHMS(unixTime) {
      var ampm, date, hour, min, sec, time;
      date = new Date();
      if (Util.isNum(unixTime)) {
        date.setTime(unixTime * 1000);
      }
      hour = date.getHours();
      ampm = 'AM';
      if (hour > 12) {
        hour = hour - 12;
        ampm = 'PM';
      }
      min = ('0' + date.getMinutes()).slice(-2);
      sec = ('0' + date.getSeconds()).slice(-2);
      time = `${hour}:${min}:${sec} ${ampm}`;
      return time;
    }

    // Generate four random hex digits
    static hex4() {
      return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
    }

    // Generate a 32 bits hex
    static hex32() {
      var hex, i, j;
      hex = this.hex4();
      for (i = j = 1; j <= 4; i = ++j) {
        Util.noop(i);
        hex += this.hex4();
      }
      return hex;
    }

    // Return a number with fixed decimal places
    static toFixed(arg, dec = 2) {
      var num;
      num = (function() {
        switch (typeof arg) {
          case 'number':
            return arg;
          case 'string':
            return parseFloat(arg);
          default:
            return 0;
        }
      })();
      return num.toFixed(dec);
    }

    static toInt(arg) {
      switch (typeof arg) {
        case 'number':
          return Math.floor(arg);
        case 'string':
          return parseInt(arg);
        default:
          return 0;
      }
    }

    static toFloat(arg) {
      switch (typeof arg) {
        case 'number':
          return arg;
        case 'string':
          return parseFloat(arg);
        default:
          return 0;
      }
    }

    static toCap(str) {
      return str.charAt(0).toUpperCase() + str.substring(1);
    }

    static unCap(str) {
      return str.charAt(0).toLowerCase() + str.substring(1);
    }

    // Review
    static toArray(objects, whereIn = null, keyField = 'id') {
      var array, j, key, len1, object, where;
      where = whereIn != null ? whereIn : function() {
        return true;
      };
      array = [];
      if (Util.isArray(objects)) {
        for (j = 0, len1 = array.length; j < len1; j++) {
          object = array[j];
          if (!(where(object))) {
            continue;
          }
          if ((object['id'] != null) && keyField !== 'id') {
            object[keyField] = object['id'];
          }
          array.push(object);
        }
      } else {
        for (key in objects) {
          if (!hasProp.call(objects, key)) continue;
          object = objects[key];
          if (!(where(object))) {
            continue;
          }
          object[keyField] = key;
          array.push(object);
        }
      }
      return array;
    }

    // keyProp only needed if rows is away
    static toObjects(rows, whereIn = null, key = 'key') {
      var ckey, j, len1, objects, row, where;
      where = whereIn != null ? whereIn : function() {
        return true;
      };
      objects = {};
      if (Util.isArray(rows)) {
        for (j = 0, len1 = rows.length; j < len1; j++) {
          row = rows[j];
          if (where(row)) {
            if ((row != null) && (row[key] != null)) {
              ckey = Util.childKey(row[key]);
              objects[row[ckey]] = row;
            } else {
              Util.error("Util.toObjects() row array element requires key property", key, row);
            }
          }
        }
      } else {
        for (key in rows) {
          if (!hasProp.call(rows, key)) continue;
          row = rows[key];
          if (where(row)) {
            objects[key] = row;
          }
        }
      }
      return objects;
    }

    static childKey(key) {
      return key.split('/')[0];
    }

    static toRange(rows, beg, end, keyProp = 'key') {
      var j, key, len1, objects, row;
      objects = {};
      if (Util.isArray(rows)) {
        for (j = 0, len1 = rows.length; j < len1; j++) {
          row = rows[j];
          if (beg <= row[keyProp] && row[keyProp] <= end) {
            objects[row[keyProp]] = row;
          }
        }
      } else {
        for (key in rows) {
          if (!hasProp.call(rows, key)) continue;
          row = rows[key];
          if (beg <= key && key <= end) {
            objects[key] = row;
          }
        }
      }
      return objects;
    }

    // keyProp only needed if rows is away
    static toKeys(rows, whereIn = null, keyProp = 'key') {
      var j, key, keys, len1, row, where;
      where = whereIn != null ? whereIn : function() {
        return true;
      };
      keys = [];
      if (Util.isArray(rows)) {
        for (j = 0, len1 = rows.length; j < len1; j++) {
          row = rows[j];
          if (where(row)) {
            if (row[keyProp] != null) {
              keys.push(row[keyProp]);
            } else {
              Util.error("Util.toKeys() row array element requires key property", keyProp, row);
            }
          }
        }
      } else {
        for (key in rows) {
          if (!hasProp.call(rows, key)) continue;
          row = rows[key];
          if (where(row)) {
            keys.push(key);
          }
        }
      }
      return keys;
    }

    static logObjs(msg, objects) {
      var key, row;
      Util.log(msg);
      for (key in objects) {
        if (!hasProp.call(objects, key)) continue;
        row = objects[key];
        Util.log('  ', {
          key: key,
          row: row
        });
      }
    }

    // Beautiful Code, Chapter 1.
    // Implements a regular expression matcher that supports character matches,
    // '.', '^', '$', and '*'.

    // Search for the regexp anywhere in the text.
    static match(regexp, text) {
      if (regexp[0] === '^') {
        return Util.match_here(regexp.slice(1), text);
      }
      while (text) {
        if (Util.match_here(regexp, text)) {
          return true;
        }
        text = text.slice(1);
      }
      return false;
    }

    // Search for the regexp at the beginning of the text.
    static match_here(regexp, text) {
      var cur, next;
      [cur, next] = [regexp[0], regexp[1]];
      if (regexp.length === 0) {
        return true;
      }
      if (next === '*') {
        return Util.match_star(cur, regexp.slice(2), text);
      }
      if (cur === '$' && !next) {
        return text.length === 0;
      }
      if (text && (cur === '.' || cur === text[0])) {
        return Util.match_here(regexp.slice(1), text.slice(1));
      }
      return false;
    }

    // Search for a kleene star match at the beginning of the text.
    static match_star(c, regexp, text) {
      while (true) {
        if (Util.match_here(regexp, text)) {
          return true;
        }
        if (!(text && (text[0] === c || c === '.'))) {
          return false;
        }
        text = text.slice(1);
      }
    }

    static match_test() {
      Util.log(Util.match_args("ex", "some text"));
      Util.log(Util.match_args("s..t", "spit"));
      Util.log(Util.match_args("^..t", "buttercup"));
      Util.log(Util.match_args("i..$", "cherries"));
      Util.log(Util.match_args("o*m", "vrooooommm!"));
      return Util.log(Util.match_args("^hel*o$", "hellllllo"));
    }

    static match_args(regexp, text) {
      return Util.log(regexp, text, Util.match(regexp, text));
    }

    static svgId(name, type, svgType, check = false) {
      if (check) {
        return this.id(name, type, svgType);
      } else {
        return name + type + svgType;
      }
    }

    static css(name, type = '') {
      return name + type;
    }

    static icon(name, type, fa) {
      return name + type + ' fa fa-' + fa;
    }

    // json - "application/json;charset=utf-8"
    // svg
    static mineType(fileType) {
      var mine;
      mine = (function() {
        switch (fileType) {
          case 'json':
            return "application/json";
          case 'adoc':
            return "text/plain";
          case 'html':
            return "text/html";
          case 'svg':
            return "image/svg+xml";
          default:
            return "text/plain";
        }
      })();
      mine += ";charset=utf-8";
      return mine;
    }

    // Need find URL
    static saveFile(stuff, fileName, fileType) {
      var blob, downloadLink, url;
      blob = new Blob([stuff], {
        type: this.mineType(fileType)
      });
      Util.noop(blob);
      url = ""; // URL.createObjectURL(blob)
      downloadLink = document.createElement("a");
      downloadLink.href = url;
      downloadLink.download = fileName;
      document.body.appendChild(downloadLink);
      downloadLink.click();
      document.body.removeChild(downloadLink);
    }

  };

  Util.myVar = 'myVar';

  Util.skipReady = false;

  Util.isCommonJS = false;

  Util.isWebPack = false;

  if (typeof module === "object" && typeof module.exports === "object") {
    Util.isCommonJS = true;
  } else {
    Util.isWebPack = true;
  }

  Util.Load = null;

  Util.ModuleGlobals = [];

  Util.app = {};

  Util.testTrue = true;

  Util.debug = false;

  Util.message = false;

  Util.count = 0;

  Util.modules = [];

  Util.instances = [];

  Util.globalPaths = [];

  Util.root = '../'; // Used internally

  Util.rootJS = Util.root + 'js/';

  Util.databases = {}; // Provides global access to databases in Store

  Util.htmlIds = {}; // Object of unique Html Ids

  Util.logStackNum = 0;

  Util.logStackMax = 100;

  Util.fills = {};

  return Util;

}).call(this);

export default Util;
