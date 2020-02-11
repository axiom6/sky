var Credit,
  indexOf = [].indexOf;

import Util from './Util.js';

Credit = (function() {
  class Credit {
    constructor() {
      //sub.addEventListener('click', validate )
      /*
      validateF = (e) =>
        Util.noop( e )
        valid     = []
        expiryObj = @parseCardExpiry( exp.value )
        valid.push( @fieldStatus( num, @validateCardNumber( num.value ) ) )
        valid.push( @fieldStatus( exp, @validateCardExpiry( expiryObj ) ) )
        valid.push( @fieldStatus( cvc, @validateCardCVC( cvc.value, typ.innerHTML ) ) )
        msg = if valid.every(Boolean) then 'valid' else  'invalid'
        res.innerHTML = msg
        Util.log( 'Credit.init() validate', num.value, exp.value, cvc.value, msg )
        return
      #sub.addEventListener('click', validate )
      Util.noop( validateF )
       */
      this.fieldStatus = this.fieldStatus.bind(this);
      this.eventNormalize = this.eventNormalize.bind(this);
      // Private

      // Replace Full-Width Chars
      this.replaceFullWidthChars = this.replaceFullWidthChars.bind(this);
      // Format Card Number
      this.reFormatCardNumberIp = this.reFormatCardNumberIp.bind(this);
      this.formatCardNumberIp = this.formatCardNumberIp.bind(this);
      this.formatBackCardNumberIp = this.formatBackCardNumberIp.bind(this);
      // Format Expiry
      this.reFormatExpiryIp = this.reFormatExpiryIp.bind(this);
      this.formatCardExpiryIp = this.formatCardExpiryIp.bind(this);
      this.formatForwardExpiryIp = this.formatForwardExpiryIp.bind(this);
      this.formatForwardSlashAndSpaceIp = this.formatForwardSlashAndSpaceIp.bind(this);
      this.formatBackExpiryIp = this.formatBackExpiryIp.bind(this);
      // Format CVC
      this.reFormatCVCIp = this.reFormatCVCIp.bind(this);
      // Restrictions
      this.restrictNumericIp = this.restrictNumericIp.bind(this);
      this.restrictCardNumberIp = this.restrictCardNumberIp.bind(this);
      this.restrictExpiryIp = this.restrictExpiryIp.bind(this);
      this.restrictCVCIp = this.restrictCVCIp.bind(this);
      this.cvcInput = this.cvcInput.bind(this);
      this.expiryInput = this.expiryInput.bind(this);
      this.cardNumberInput = this.cardNumberInput.bind(this);
      this.numericInput = this.numericInput.bind(this);
      // Validations
      this.parseCardExpiry = this.parseCardExpiry.bind(this);
      this.validateCardNumber = this.validateCardNumber.bind(this);
      this.validateCardExpiry = this.validateCardExpiry.bind(this);
      this.validateCardCVC = this.validateCardCVC.bind(this);
      this.parseCardType = this.parseCardType.bind(this);
      this.formatCardNumber = this.formatCardNumber.bind(this);
      this.formatCardExpiry = this.formatCardExpiry.bind(this);
      this.delay = 0;
    }

    init(numId, expId, cvcId, typId) {
      var cvc, exp, num, typ, updateType, validate;
      num = document.getElementById(numId);
      exp = document.getElementById(expId);
      cvc = document.getElementById(cvcId);
      //ub = document.getElementById(subId)
      typ = document.getElementById(typId);
      this.cardNumberInput(num);
      this.expiryInput(exp);
      this.cvcInput(cvc);
      //Util.log( 'Credit.init() start', numId, expId, cvcId, subId, typId, resId )
      updateType = (e) => {
        var cardType, msg;
        cardType = this.parseCardType(e.target.value);
        msg = (cardType != null) && cardType !== '' ? cardType : '';
        typ.innerHTML = msg + ' Card Number';
      };
      //Util.log( 'Credit.init() updateType', num.value, exp.value, cvc.value, msg )
      num.addEventListener('input', updateType);
      validate = (e) => {
        var card, expiryObj;
        Util.noop(e);
        card = this.cardFromNumber(num.value);
        expiryObj = this.parseCardExpiry(exp.value);
        if (!this.validateCardNumber(num.value)) {
          $('#er-num').show();
        }
        if (!this.validateCardExpiry(expiryObj)) {
          $('#er-exp').show();
        }
        if (!this.validateCardCVC(cvc.value, card.type)) {
          $('#er-exp').show();
        }
      };
      return Util.noop(validate);
    }

    fieldStatus(input, valid) {
      if (valid) {
        this.removeClass(input.parentNode, 'error');
      } else {
        this.addClass(input.parentNode, 'error');
      }
      return valid;
    }

    addClass(elem, klass) {
      if (elem.className.indexOf(klass) === -1) {
        elem.className += ' ' + klass;
      }
    }

    removeClass(elem, klass) {
      if (elem.className.indexOf(klass) !== -1) {
        elem.className = elem.className.replace(klass, '');
      }
    }

    cardFromNumber(num) {
      var card, i, len, ref;
      num = (num + '').replace(/\D/g, '');
      ref = Credit.cards;
      for (i = 0, len = ref.length; i < len; i++) {
        card = ref[i];
        if (card.pattern.test(num)) {
          return card;
        }
      }
      //console.log( 'Credit.cardFromNumber()', num, ven.type )
      return Credit.UnknownCard;
    }

    cardFromType(type) {
      var card, i, len, ref;
      ref = Credit.cards;
      for (i = 0, len = ref.length; i < len; i++) {
        card = ref[i];
        if (card.type === type) {
          return card;
        }
      }
      //console.log( 'Credit.cardFromType()', type, ven.type )
      return Credit.UnknownCard;
    }

    isCard(card) {
      return (card != null) && card.type !== 'Unknown';
    }

    getCaretPos(ele) {
      if (ele.selectionStart != null) {
        return ele.selectionStart;
      }
    }

    eventNormalize(listener) {
      return function(e = window.event) {
        e.target = e.target || e.srcElement;
        e.which = e.which || e.keyCode;
        if (e.preventDefault == null) {
          e.preventDefault = function() {
            return this.returnValue = false;
          };
        }
        return listener(e);
      };
    }

    doListen(ele, event, listener) {
      listener = this.eventNormalize(listener);
      if (ele.addEventListener != null) {
        return ele.addEventListener(event, listener, false);
      } else {
        return ele.attachEvent(`on${event}`, listener);
      }
    }

    luhnCheck(num) {
      var digit, digits, i, len, odd, sum;
      odd = true;
      sum = 0;
      digits = (num + '').split('').reverse();
      for (i = 0, len = digits.length; i < len; i++) {
        digit = digits[i];
        digit = parseInt(digit, 10);
        if ((odd = !odd)) {
          digit *= 2;
        }
        if (digit > 9) {
          digit -= 9;
        }
        sum += digit;
      }
      return sum % 10 === 0;
    }

    hasTextSelected(target) {
      // If some text is selected in IE
      return (target.selectionStart != null) && target.selectionStart !== target.selectionEnd;
    }

    replaceFullWidthChars(str = '') {
      var char, chars, fullWidth, halfWidth, i, idx, len, value;
      if (!Util.isStr(str) || str === 'keypress') {
        Util.trace('replaceKeypress', str);
        return '';
      }
      fullWidth = '\uff10\uff11\uff12\uff13\uff14\uff15\uff16\uff17\uff18\uff19';
      halfWidth = '0123456789';
      value = '';
      chars = str.split('');
      for (i = 0, len = chars.length; i < len; i++) {
        char = chars[i];
        idx = fullWidth.indexOf(char);
        if (idx > -1) {
          char = halfWidth[idx];
        }
        value += char;
      }
      //console.log( 'replaceFullTwo', { str:str, value:value, chars:chars } )
      return value;
    }

    reFormatCardNumberIp(e) {
      var cursor;
      cursor = this.getCaretPos(e.target);
      e.target.value = this.formatCardNumber(e.target.value);
      if ((cursor != null) && e.type !== 'change') {
        return e.target.setSelectionRange(cursor, cursor);
      }
    }

    formatCardNumberIp(e) {
      var card, cursor, digit, fn, length, re, upperLength, value;
      // Only format if input is a number
      digit = String.fromCharCode(e.which);
      if (!/^\d+$/.test(digit)) {
        return;
      }
      value = e.target.value;
      card = this.cardFromNumber(value + digit);
      //console.log('Credit.formatCardNumber()', value, card )
      length = (value.replace(/\D/g, '') + digit).length;
      upperLength = 16;
      if (this.isCard(card)) {
        upperLength = card.length[card.length.length - 1];
      }
      if (length >= upperLength) {
        return;
      }
      // Return if focus isn't at the end of the text
      cursor = this.getCaretPos(e.target);
      //console.log( 'Cursor', { value:value, len:value.length, cursor:cursor } )
      if (cursor && cursor !== value.length) {
        return;
      }
      if (this.isCard(card) && card.type === 'amex') {
        // AMEX cards are formatted differently
        re = /^(\d{4}|\d{4}\s\d{6})$/;
      } else {
        re = /(?:^|\s)(\d{4})$/;
      }
      // If '4242' + 4
      if (re.test(value)) {
        e.preventDefault();
        fn = function() {
          return e.target.value = `${value} ${digit}`;
        };
        return setTimeout(fn, this.delay);
      // If '424' + 2
      } else if (re.test(value + digit)) {
        e.preventDefault();
        fn = function() {
          return e.target.value = `${value + digit} `;
        };
        return setTimeout(fn, this.delay);
      }
    }

    formatBackCardNumberIp(e) {
      var cursor, fn, value;
      value = e.target.value;
      // Return unless backspacing
      if (e.which !== 8) {
        return;
      }
      // Return if focus isn't at the end of the text
      cursor = this.getCaretPos(e.target);
      if (cursor && cursor !== value.length) {
        return;
      }
      // Remove the digit + trailing space
      if (/\d\s$/.test(value)) {
        e.preventDefault();
        fn = function() {
          return e.target.value = value.replace(/\d\s$/, '');
        };
        return setTimeout(fn, this.delay);
      // Remove digit if ends in space + digit
      } else if (/\s\d?$/.test(value)) {
        e.preventDefault();
        fn = function() {
          return e.target.value = value.replace(/\d$/, '');
        };
        return setTimeout(fn, this.delay);
      }
    }

    reFormatExpiryIp(e) {
      var cursor;
      cursor = this.getCaretPos(e.target);
      e.target.value = this.formatCardExpiry(e.target.value);
      if ((cursor != null) && e.type !== 'change') {
        return e.target.setSelectionRange(cursor, cursor);
      }
    }

    formatCardExpiryIp(e) {
      var digit, fn, val;
      // Only format if input is a number
      digit = String.fromCharCode(e.which);
      if (!/^\d+$/.test(digit)) {
        return;
      }
      val = e.target.value + digit;
      if (/^\d$/.test(val) && (val !== '0' && val !== '1')) {
        e.preventDefault();
        fn = function() {
          return e.target.value = `0${val} / `;
        };
        return setTimeout(fn, this.delay);
      } else if (/^\d\d$/.test(val)) {
        e.preventDefault();
        fn = function() {
          return e.target.value = `${val} / `;
        };
        return setTimeout(fn, this.delay);
      }
    }

    formatForwardExpiryIp(e) {
      var digit, val;
      digit = String.fromCharCode(e.which);
      if (!/^\d+$/.test(digit)) {
        return;
      }
      val = e.target.value;
      if (/^\d\d$/.test(val)) {
        return e.target.value = `${val} / `;
      }
    }

    formatForwardSlashAndSpaceIp(e) {
      var val, which;
      which = String.fromCharCode(e.which);
      if (!(which === '/' || which === ' ')) {
        return;
      }
      val = e.target.value;
      if (/^\d$/.test(val) && val !== '0') {
        return e.target.value = `0${val} / `;
      }
    }

    formatBackExpiryIp(e) {
      var cursor, fn, value;
      value = e.target.value;
      // Return unless backspacing
      if (e.which !== 8) {
        return;
      }
      // Return if focus isn't at the end of the text
      cursor = this.getCaretPos(e.target);
      if (cursor && cursor !== value.length) {
        return;
      }
      // Remove the trailing space + last digit
      if (/\d\s\/\s$/.test(value)) {
        e.preventDefault();
        fn = function() {
          return e.target.value = value.replace(/\d\s\/\s$/, '');
        };
        return setTimeout(fn, this.delay);
      }
    }

    reFormatCVCIp(e) {
      var cursor;
      cursor = this.getCaretPos(e.target);
      e.target.value = this.replaceFullWidthChars(e.target.value).replace(/\D/g, '').slice(0, 4);
      if ((cursor != null) && e.type !== 'change') {
        return e.target.setSelectionRange(cursor, cursor);
      }
    }

    restrictNumericIp(e) {
      var input;
      // Key event is for a browser shortcut
      if (e.metaKey || e.ctrlKey) {
        return;
      }
      // If keycode is a special char (WebKit)
      if (e.which === 0) {
        return;
      }
      // If char is a special char (Firefox)
      if (e.which < 33) {
        return;
      }
      input = String.fromCharCode(e.which);
      // Char is a number
      if (!/^\d+$/.test(input)) {
        return e.preventDefault();
      }
    }

    restrictCardNumberIp(e) {
      var card, digit, value;
      digit = String.fromCharCode(e.which);
      if (!/^\d+$/.test(digit)) {
        return;
      }
      if (this.hasTextSelected(e.target)) {
        return;
      }
      // Restrict number of digits
      value = (e.target.value + digit).replace(/\D/g, '');
      card = this.cardFromNumber(value);
      if (this.isCard(card) && value.length > card.length[card.length.length - 1]) {
        return e.preventDefault();
      } else if (value.length > 16) {
        return e.preventDefault();
      }
    }

    restrictExpiryIp(e) {
      var digit, value;
      digit = String.fromCharCode(e.which);
      if (!/^\d+$/.test(digit)) {
        return;
      }
      if (this.hasTextSelected(e.target)) {
        return;
      }
      value = e.target.value + digit;
      value = value.replace(/\D/g, '');
      if (value.length > 6) {
        return e.preventDefault();
      }
    }

    restrictCVCIp(e) {
      var digit, val;
      digit = String.fromCharCode(e.which);
      if (!/^\d+$/.test(digit)) {
        return;
      }
      if (this.hasTextSelected(e.target)) {
        return;
      }
      val = e.target.value + digit;
      if (val.length > 4) {
        return e.preventDefault();
      }
    }

    cvcInput(input) {
      this.doListen(input, 'keypress', this.restrictNumericIp);
      this.doListen(input, 'keypress', this.restrictCVCIp);
      this.doListen(input, 'paste', this.reFormatCVCIp);
      this.doListen(input, 'change', this.reFormatCVCIp);
      return this.doListen(input, 'input', this.reFormatCVCIp);
    }

    expiryInput(input) {
      this.doListen(input, 'keypress', this.restrictNumericIp);
      this.doListen(input, 'keypress', this.restrictExpiryIp);
      this.doListen(input, 'keypress', this.formatCardExpiryIp);
      this.doListen(input, 'keypress', this.formatForwardSlashAndSpaceIp);
      this.doListen(input, 'keypress', this.formatForwardExpiryIp);
      this.doListen(input, 'keydown', this.formatBackExpiryIp);
      this.doListen(input, 'change', this.reFormatExpiryIp);
      return this.doListen(input, 'input', this.reFormatExpiryIp);
    }

    cardNumberInput(input) {
      this.doListen(input, 'keypress', this.restrictNumericIp);
      this.doListen(input, 'keypress', this.restrictCardNumberIp);
      this.doListen(input, 'keypress', this.formatCardNumberIp);
      this.doListen(input, 'keydown', this.formatBackCardNumberIp);
      this.doListen(input, 'paste', this.reFormatCardNumberIp);
      this.doListen(input, 'change', this.reFormatCardNumberIp);
      return this.doListen(input, 'input', this.reFormatCardNumberIp);
    }

    numericInput(input) {
      this.doListen(input, 'keypress', this.restrictNumericIp);
      this.doListen(input, 'paste', this.restrictNumericIp);
      this.doListen(input, 'change', this.restrictNumericIp);
      return this.doListen(input, 'input', this.restrictNumericIp);
    }

    parseCardExpiry(value) {
      var month, prefix, year;
      value = value.replace(/\s/g, '');
      [month, year] = value.split('/', 2);
      // Allow for year shortcut
      if ((year != null ? year.length : void 0) === 2 && /^\d+$/.test(year)) {
        prefix = (new Date).getFullYear();
        prefix = prefix.toString().slice(0, 2);
        year = prefix + year;
      }
      month = parseInt(month, 10);
      year = parseInt(year, 10);
      return {
        month: month,
        year: year
      };
    }

    validateCardNumber(num) {
      var card, ref;
      num = (num + '').replace(/\s+|-/g, '');
      if (!/^\d+$/.test(num)) {
        return false;
      }
      card = this.cardFromNumber(num);
      if (!this.isCard(card)) {
        return false;
      }
      return (ref = num.length, indexOf.call(card.length, ref) >= 0) && (card.luhn === false || this.luhnCheck(num));
    }

    validateCardExpiry(month, year) {
      var currentTime, expiry;
      // Allow passing an object
      if (typeof month === 'object' && 'month' in month) {
        ({month, year} = month);
      }
      if (!(month && year)) {
        return false;
      }
      month = String(month).trim();
      year = String(year).trim();
      if (!/^\d+$/.test(month)) {
        return false;
      }
      if (!/^\d+$/.test(year)) {
        return false;
      }
      if (!((1 <= month && month <= 12))) {
        return false;
      }
      if (year.length === 2) {
        if (year < 70) {
          year = `20${year}`;
        } else {
          year = `19${year}`;
        }
      }
      if (year.length !== 4) {
        return false;
      }
      expiry = new Date();
      expiry.setYear(year);
      expiry.setMonth(month);
      currentTime = new Date;
      // Months start from 0 in JavaScript
      expiry.setMonth(expiry.getMonth() - 1);
      // The cc expires at the end of the month,
      // so we need to make the expiry the first day
      // of the month after
      expiry.setMonth(expiry.getMonth() + 1, 1);
      return expiry > currentTime;
    }

    validateCardCVC(cvc, type) {
      var card, ref;
      cvc = String(cvc).trim();
      if (!/^\d+$/.test(cvc)) {
        return false;
      }
      card = this.cardFromType(type);
      if (this.isCard(card)) {
        // Check against a explicit card type
        return ref = cvc.length, indexOf.call(card.cvcLength, ref) >= 0;
      } else {
        // Check against all types
        return cvc.length >= 3 && cvc.length <= 4;
      }
    }

    parseCardType(num) {
      var card;
      if (!num) {
        return '';
      }
      card = this.cardFromNumber(num);
      if (this.isCard(card)) {
        return card.type;
      } else {
        return '';
      }
    }

    formatCardNumber(num) {
      var card, groups, ref, upperLength;
      if (!Util.isStr(num)) {
        return '';
      }
      num = this.replaceFullWidthChars(num);
      num = num.replace(/\D/g, '');
      card = this.cardFromNumber(num);
      if (!this.isCard(card)) {
        //console.log( 'Credit.formatCardNumber()', num, card  )
        return num;
      }
      upperLength = card.length[card.length.length - 1];
      num = num.slice(0, upperLength);
      if (card.format.global) {
        return (ref = num.match(card.format)) != null ? ref.join(' ') : void 0;
      } else {
        groups = card.format.exec(num);
        if (groups == null) {
          return;
        }
        groups.shift();
        groups = groups.filter(Boolean);
        return groups.join(' ');
      }
    }

    formatCardExpiry(expiry) {
      var mon, parts, sep, year;
      expiry = this.replaceFullWidthChars(expiry);
      parts = expiry.match(/^\D*(\d{1,2})(\D+)?(\d{1,4})?/);
      if (!parts) {
        return '';
      }
      mon = parts[1] || '';
      sep = parts[2] || '';
      year = parts[3] || '';
      if (year.length > 0) {
        sep = ' / ';
      } else if (sep === ' /') {
        mon = mon.substring(0, 1);
        sep = '';
      } else if (mon.length === 2 || sep.length > 0) {
        sep = ' / ';
      } else if (mon.length === 1 && (mon !== '0' && mon !== '1')) {
        mon = `0${mon}`;
        sep = ' / ';
      }
      return mon + sep + year;
    }

  };

  window.Credit = Credit;

  Credit.defaultFormat = /(\d{1,4})/g;

  Credit.UnknownCard = {
    type: 'Unknown',
    pattern: /^U/,
    format: Credit.defaultFormat,
    length: [16],
    cvcLength: [3],
    luhn: true
  };

  Credit.cards = [
    {
      // Debit cards must come first, since they have more
      // specific patterns than their credit-card equivalents.
      type: 'VisaElectron',
      pattern: /^4(026|17500|405|508|844|91[37])/,
      format: Credit.defaultFormat,
      length: [16],
      cvcLength: [3],
      luhn: true
    },
    {
      type: 'Maestro',
      pattern: /^(5(018|0[23]|[68])|6(39|7))/,
      format: Credit.defaultFormat,
      length: [12, 13, 14, 15, 16, 17, 18, 19],
      cvcLength: [3],
      luhn: true
    },
    {
      type: 'Forbrugsforeningen',
      pattern: /^600/,
      format: Credit.defaultFormat,
      length: [16],
      cvcLength: [3],
      luhn: true
    },
    {
      type: 'Dankort',
      pattern: /^5019/,
      format: Credit.defaultFormat,
      length: [16],
      cvcLength: [3],
      luhn: true
    },
    {
      // Credit cards
      type: 'Visa',
      pattern: /^4/,
      format: Credit.defaultFormat,
      length: [13,
    16],
      cvcLength: [3],
      luhn: true
    },
    {
      type: 'Mastercard',
      pattern: /^(5[1-5]|2[2-7])/,
      format: Credit.defaultFormat,
      length: [16],
      cvcLength: [3],
      luhn: true
    },
    {
      type: 'Amex',
      pattern: /^3[47]/,
      format: /(\d{1,4})(\d{1,6})?(\d{1,5})?/,
      length: [15],
      cvcLength: [3, 4],
      luhn: true
    },
    {
      type: 'DinersClub',
      pattern: /^3[0689]/,
      format: /(\d{1,4})(\d{1,4})?(\d{1,4})?(\d{1,2})?/,
      length: [14],
      cvcLength: [3],
      luhn: true
    },
    {
      type: 'Discover',
      pattern: /^6([045]|22)/,
      format: Credit.defaultFormat,
      length: [16],
      cvcLength: [3],
      luhn: true
    },
    {
      type: 'UnionPay',
      pattern: /^(62|88)/,
      format: Credit.defaultFormat,
      length: [16, 17, 18, 19],
      cvcLength: [3],
      luhn: false
    },
    {
      type: 'JCB',
      pattern: /^35/,
      format: Credit.defaultFormat,
      length: [16],
      cvcLength: [3],
      luhn: true
    }
  ];

  return Credit;

}).call(this);

export default Credit;
