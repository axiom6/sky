var Test,
  hasProp = {}.hasOwnProperty;

import Util from './Util.js';

//import Data from './Data'
//import UI   from './UI'
Test = class Test {
  constructor(stream, store, res1, pay, pict, book, resData) {
    this.stream = stream;
    this.store = store;
    this.res = res1;
    this.pay = pay;
    this.pict = pict;
    this.book = book;
    this.resData = resData;
  }

  doTest() {
    var $cell, cust, day, dayId, fn, ref, ref1, res, resId, room, roomId;
    ref = this.resData;
    for (resId in ref) {
      if (!hasProp.call(ref, resId)) continue;
      res = ref[resId];
      for (roomId in res) {
        if (!hasProp.call(res, roomId)) continue;
        room = res[roomId];
        ref1 = res.days['full'];
        for (dayId in ref1) {
          if (!hasProp.call(ref1, dayId)) continue;
          day = ref1[dayId];
          $cell = $('#R' + roomId + dayId);
          this.book.cellBook($cell);
        }
      }
      cust = res.cust;
      this.getNamePhoneEmail(cust.first, cust.last, cust.phone, cust.email);
      fn = () => {
        return this.doGoToPay(res);
      };
      setTimeout(fn, 4000);
    }
  }

  doGoToPay(res) {
    var fn, payment;
    this.book.onGoToPay(null);
    payment = Util.keys(res.payments).sort()[0];
    this.popCC(payment.cc, payment.exp, payment.cvc);
    fn = () => {
      return this.pay.submit(null);
    };
    setTimeout(fn, 4000);
  }

  getNamesPhoneEmail(first, last, phone, email) {
    var ev, fv, lv, pv;
    [this.pay.first, fv] = this.pay.isValid('First', first, true);
    [this.pay.last, lv] = this.pay.isValid('Last', last, true);
    [this.pay.phone, pv] = this.pay.isValid('Phone', phone, true);
    return [this.pay.email, ev] = this.pay.isValid('EMail', email, true);
  }

  popCC(cc, exp, cvc) {
    $('#cc-num').val(cc);
    $('#cc-exp').val(exp);
    $('#cc-cvc').val(cvc);
  }

};

export default Test;
