var UI;

import Util from './Util.js';

import Data from './Data.js';

UI = class UI {
  static isEmpty($elem) {
    return ($elem != null) && ($elem.length != null) && $elem.length === 0;
  }

  static isElem($elem) {
    return !UI.isEmpty($elem);
  }

  static htmlSelect(htmlId, array, choice, klass = "", max = void 0) {
    var elem, htm, i, len, selected, style, where;
    style = Util.isStr(klass) ? klass : htmlId;
    htm = `<select name="${htmlId}" id="${htmlId}" class="${style}">`;
    where = max != null ? function(elem) {
      return elem <= max;
    } : function() {
      return true;
    };
    for (i = 0, len = array.length; i < len; i++) {
      elem = array[i];
      if (!(where(elem))) {
        continue;
      }
      selected = elem === Util.toStr(choice) ? "selected" : "";
      htm += `<option${' ' + selected}>${elem}</option>`;
    }
    return htm += "</select>";
  }

  static htmlInput(htmlId, value = "", klass = "", label = "", type = "text") {
    var htm, style;
    style = Util.isStr(klass) ? klass : htmlId;
    htm = "";
    if (Util.isStr(label)) {
      htm += `<label for="${htmlId}" class="${style + 'Label'}">${label}</label>`;
    }
    htm += `<input id= "${htmlId}" class="${style}" value="${value}" type="${type}">`;
    return htm;
  }

  static htmlButton(htmlId, klass, title) {
    return `<button id="${htmlId}" class="btn btn-primary ${klass}">${title}</button>`;
  }

  static htmlArrows(htmlId, klass) {
    return `<span id="${htmlId}L">&#9664;</span>\n<span id="${htmlId}" class="${klass}"></span>\n<span id="${htmlId}R">&#9654;</span>`;
  }

  static onArrowsMMDD(htmlId, onMMDD = null) {
    var decMMDD, incMMDD;
    decMMDD = function() {
      var $mmdd, mmdd0, mmdd1;
      $mmdd = $('#' + htmlId);
      mmdd0 = $mmdd.text();
      mmdd1 = Data.advanceMMDD(mmdd0, -1);
      $mmdd.text(mmdd1);
      if (onMMDD != null) {
        onMMDD(htmlId, mmdd0, mmdd1);
      }
    };
    incMMDD = function() {
      var $mmdd, mmdd0, mmdd1;
      $mmdd = $('#' + htmlId);
      mmdd0 = $mmdd.text();
      mmdd1 = Data.advanceMMDD(mmdd0, 1);
      $mmdd.text(mmdd1);
      if (onMMDD != null) {
        onMMDD(htmlId, mmdd0, mmdd1);
      }
    };
    $('#' + htmlId + 'L').click(decMMDD);
    $('#' + htmlId + 'R').click(incMMDD);
  }

  // Sets htmlId property on obj
  static makeSelect(htmlId, obj) {
    var onSelect;
    onSelect = (event) => {
      obj[htmlId] = event.target.value;
      return Util.log(htmlId, obj[htmlId]);
    };
    $('#' + htmlId).change(onSelect);
  }

  // Sets htmlId property on obj
  static makeInput(htmlId, obj) {
    var onInput;
    onInput = (event) => {
      obj[htmlId] = event.target.value; // $('#'+htmlId).val()
      return Util.log(htmlId, obj[htmlId]);
    };
    $('#' + htmlId).change(onInput);
  }

  // This is a hack for unreliable storage in jQuery.attr - found other formating error so not needed
  static attr($elem, name) {
    var value;
    value = $elem.attr(name.toLowerCase());
    Util.log('Res.attr one', name, value);
    value = Util.isStr(value) && value.charAt(0) === ' ' ? value.substr(1) : value;
    value = Util.isStr(value) ? Util.toCap(value) : value;
    Util.log('Res.attr two', name, value);
    return value;
  }

};

export default UI;
