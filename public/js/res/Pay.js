var Pay,
  hasProp = {}.hasOwnProperty;

import Credit from './Credit.js';

import Util from './Util.js';

import Data from './Data.js';

//mport UI     from './UI'
Pay = class Pay {
  constructor(stream, store, res, home = null) {
    //doPut = (onPut) -> Util.log('Res.subscribeToDays onPut', onPut )
    //@res.onDays( doPut )
    this.initPayResv = this.initPayResv.bind(this);
    this.initCCPayment = this.initCCPayment.bind(this);
    this.onChangeReser = this.onChangeReser.bind(this);
    this.onCancel = this.onCancel.bind(this);
    this.onMakeDeposit = this.onMakeDeposit.bind(this);
    this.onMakePayment = this.onMakePayment.bind(this);
    this.confirmEmailBody = this.confirmEmailBody.bind(this);
    this.submitPayment = this.submitPayment.bind(this);
    this.onTokenError = this.onTokenError.bind(this);
    this.onChargeError = this.onChargeError.bind(this);
    this.onToken = this.onToken.bind(this);
    this.onCharge = this.onCharge.bind(this);
    this.onError = this.onError.bind(this);
    this.stream = stream;
    this.store = store;
    this.res = res;
    this.home = home;
    this.credit = new Credit();
    this.uri = "https://api.stripe.com/v1/";
    this.subscribe();
    $.ajaxSetup({
      headers: {
        "Authorization": Data.stripeCurlKey
      }
    });
    this.resv = null;
    this.amount = 0;
    this.purpose = 'PayInFull'; // 'Deposit' 'PayBalance'
    this.testing = false;
    this.errored = false;
  }

  initPayResv(totals, cust, rooms) {
    this.resv = this.res.createRoomResv('Mine', 'card', totals, cust, rooms);
    this.amount = totals - this.resv.paid;
    $('#Pays').empty();
    $('#Pays').append(this.confirmHead(this.resv));
    $('#ConfirmBlock').append(this.confirmTable(this.resv, 'Guest'));
    $('#Pays').append(this.confirmBtns(this.resv));
    $('#PayDiv').append(this.payHtml());
    $('#Pays').append(this.termsHtml());
    this.initCCPayment(this.resv, this.amount);
    this.credit.init('cc-num', 'cc-exp', 'cc-cvc', 'cc-com');
    $('#Pays').show();
    if (this.testing) {
      this.testPop();
    }
  }

  initCCPayment(resv, amount) {
    this.hideCCErrors();
    $('#cc-amt').text('$' + amount);
    $('#ChangeReser').click((e) => {
      return this.onChangeReser(e);
    });
    $('#MakeDeposit').click((e) => {
      return this.onMakeDeposit(e);
    });
    $('#MakePayment').click((e) => {
      return this.onMakePayment(e);
    });
    $('#cc-sub').click((e) => {
      return this.submitPayment(e);
    });
    $('#cc-can').click((e) => {
      return this.onCancel(e);
    });
  }

  hideCCErrors() {
    $('#er-num').text('Invalid Number');
    $('#er-num').hide();
    $('#er-exp').hide();
    $('#er-cvc').hide();
    $('#er-sub').hide();
  }

  testPop() {
    $('#cc-num').val('4242424242424242');
    $('#cc-exp').val('10/19');
    $('#cc-cvc').val('555');
  }

  onChangeReser(e) {
    e.preventDefault();
    $('#Make').text('Change Reservation');
    $('#Pays').hide();
    $('#Book').show();
  }

  onCancel(e) {
    e.preventDefault();
    if (this.home != null) {
      this.home.onHome();
    }
  }

  calcDeposit() {
    return Math.round(this.resv.totals * 50) / 100;
  }

  onMakeDeposit(e) {
    e.preventDefault();
    this.amount = this.ccAmt('Deposit');
    return $('#MakePay').text('Make 50% Deposit');
  }

  onMakePayment(e) {
    e.preventDefault();
    this.amount = this.ccAmt('PayInFull');
    return $('#MakePay').text('Make Payment with Visa Mastercard or Discover');
  }

  ccAmt(purpose = this.purpose) {
    var amount;
    this.purpose = purpose;
    amount = this.purpose === 'Deposit' ? this.calcDeposit() : this.resv.totals;
    $("#cc-amt").text('$' + amount);
    return amount;
  }

  confirmHead(resv) {
    var htm;
    console.log('Pay.confirmHead', resv);
    htm = `<div id="ConfirmTitle" class= "Title"><span>Confirmation # ${resv.resId}</span><span>  For: ${resv.cust.first} </span><span>${resv.cust.last} </span></div>`;
    //tm  += """<div><div id="ConfirmName"></div></div>"""
    htm += "<div id=\"ConfirmBlock\" class=\"DivCenter\"></div>";
    return htm;
  }

  confirmTable(resv, appName) {
    var htm;
    htm = "";
    htm += this.confirmRooms(resv, appName);
    htm += this.confirmPayments(resv);
    return htm;
  }

  confirmRooms(resv, appName) {
    var arrive, arriveTimes, days, depart, departTimes, htm, r, ref, roomId;
    htm = "<table id=\"ConfirmTable\"><thead>";
    htm += "<tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>Spa</th><th>Price</th><th class=\"arrive\">Arrive</th><th class=\"depart\">Depart</th><th>Nights</th><th>Total</th></tr>";
    htm += "</thead><tbody>";
    arriveTimes = appName === 'Guest' ? "Arrival is from 3:00-8:00PM" : "";
    departTimes = appName === 'Guest' ? "Checkout is before 10:00AM" : "";
    ref = resv.rooms;
    for (roomId in ref) {
      if (!hasProp.call(ref, roomId)) continue;
      r = ref[roomId];
      days = Util.keys(r.days).sort();
      arrive = this.confirmDate(days[0], "", false);
      depart = this.confirmDate(days[days.length - 1], "", true);
      htm += `<tr><td class="td-left">${r.name}</td><td class="guests">${r.guests}</td><td class="pets">${r.pets}</td><td>${this.spa(resv, roomId)}</td><td class="room-price">$${r.price}</td><td>${arrive}</td><td>${depart}</td><td class="nights">${r.nights}</td><td id="${roomId}TR" class="room-total">$${r.total}</td></tr>`;
    }
    htm;
    htm += `<tr><td></td><td></td><td></td><td></td><td></td><td class="arrive-times">${arriveTimes}</td><td class="depart-times">${departTimes}</td><td></td><td  id="TT" class="room-total">$${resv.totals}</td></tr>`;
    return htm += "</tbody></table>";
  }

  confirmPayments(resv) {
    var date, htm, pay, payId, ref;
    htm = "<table id=\"ConfirmPayment\"><thead>";
    htm += "<tr><th>Amount</th><th>Purpose</th><th>Date</th><th>With</th><th>Last 4</th></tr>";
    htm += "</thead><tbody>";
    ref = resv.payments;
    for (payId in ref) {
      if (!hasProp.call(ref, payId)) continue;
      pay = ref[payId];
      date = this.confirmDate(pay.date, "", false);
      htm += `<tr><td>$${pay.amount}</td><td>${pay.purpose}</td><td>${date}</td><td>${pay.with}</td><td>${pay.num}</td></tr>`;
    }
    htm += "</tbody></table>";
    htm += "<table id=\"ConfirmBalance\" style=\"margin-top:20px;\"><thead>";
    htm += "<tr><th>Total</th><th>Paid</th><th>Balance</th></tr>";
    htm += "</thead><tbody>";
    htm += `<tr><td>$${resv.totals}</td><td>$${resv.paid}</td><td>$${resv.balance}</td></tr>`;
    htm += "</tbody></table>";
    return htm;
  }

  // Call after @res.postResv(...)
  confirmEmail(resv) {
    var win;
    win = window.open(`mailto:${resv.cust.email}?subject=Skyline Cottages Confirmation&body=${this.confirmEmailBody(resv)}`, "EMail");
    //win.close() if win? and not win.closed
    Util.noop(win);
  }

  confirmEmailBody(resv) {
    var body;
    body = `\n      Confirmation #${resv.resId}\nFor: ${resv.cust.first} ${resv.cust.last}\nPhone: ${resv.cust.phone}\n\n`;
    body += this.confirmEmailRooms(resv);
    body += `\n Totals:$${resv.totals} Paid:$${resv.paid} Balance:$${resv.balance} `;
    body = escape(body);
    return body;
  }

  confirmEmailRooms(resv) {
    var arrive, days, depart, name, r, ref, roomId, text;
    text = "";
    ref = resv.rooms;
    for (roomId in ref) {
      if (!hasProp.call(ref, roomId)) continue;
      r = ref[roomId];
      name = Util.padEnd(r.name + ' ', 26, '-');
      days = Util.keys(r.days).sort();
      arrive = this.confirmDate(days[0], "", false);
      depart = this.confirmDate(days[days.length - 1], "", true);
      text += `${name} $${r.price}  ${r.guests}-Guests ${r.pets}-Pets Arrive:${arrive} Depart:${depart} ${r.nights}-Nights $${r.total}\n`;
    }
    return text;
  }

  confirmContent2(resv, stuff) {
    var arrive, bday, content, days, depart, eday, i, name, r, ref, roomId;
    content = "";
    Util.log('Pay.confirmContent rooms', resv.rooms);
    ref = resv.rooms;
    for (roomId in ref) {
      if (!hasProp.call(ref, roomId)) continue;
      r = ref[roomId];
      name = Util.padEnd(r.name + ' ', 26, '-');
      days = Util.keys(r.days).sort();
      bday = days[0];
      i = 0;
      while (i < r.nights) {
        eday = days[i];
        if (i === r.nights - 1 || days[i + 1] !== Data.advanceDate(eday, 1)) {
          arrive = this.confirmDate(bday, "", false);
          depart = this.confirmDate(eday, "", true);
          if (stuff === 'html') {
            content += `<tr><td class="td-left">${r.name}</td><td class="guests">${r.guests}</td><td class="pets">${r.pets}</td><td>${this.spa(resv, roomId)}</td><td class="room-price">$${r.price}</td><td>${arrive}</td><td>${depart}</td><td class="nights">${r.nights}</td><td id="${roomId}TR" class="room-total">$${r.total}</td></tr>`;
          } else if (stuff === 'body') {
            content += `${name} $${r.price}  ${r.guests}-Guests ${r.pets}-Pets Arrive:${arrive} Depart:${depart} ${r.nights}-Nights $${r.total}\n`;
          }
          bday = days[i + 1];
        }
        i++;
      }
    }
    return content;
  }

  spa(resv, roomId) {
    var change, has;
    change = resv.rooms[roomId].change;
    has = this.res.hasSpa(roomId);
    if (!has) {
      return '';
    } else if (change === -20) {
      return 'N';
    } else {
      return 'Y';
    }
  }

  confirmBtns(resv) {
    var canDeposit, htm;
    canDeposit = this.canMakeDeposit(resv);
    htm = "<div class=\"PayBtns\">";
    htm += "  <button class=\"btn btn-primary\" id=\"ChangeReser\">Change Reservation</button>";
    if (canDeposit) {
      htm += "  <button class=\"btn btn-primary\" id=\"MakeDeposit\">Make 50% Deposit</button>";
    }
    if (canDeposit) {
      htm += "  <button class=\"btn btn-primary\" id=\"MakePayment\">Make Payment</button>";
    }
    htm += "</div>";
    htm += "<div id=\"MakePay\" class=\"Title\">Make Payment</div>";
    htm += "<div id=\"PayDiv\"></div>";
    htm += "<div id=\"Approval\"></div>";
    return htm;
  }

  canMakeDeposit(resv) {
    var advance, arrive;
    arrive = parseInt(resv.arrive);
    advance = parseInt(Data.advanceDate(resv.booked, 7));
    //Util.log('Pay.canMakeDeposit()', { booked:resv.booked, arrive:arrive, advance:advance, can:arrive >= advance } )
    return arrive >= advance;
  }

  departDate(monthI, dayI, weekdayI) {
    var dayO, monthO, weekdayO;
    dayO = dayI + 1;
    monthO = monthI;
    weekdayO = (weekdayI + 1) % 7;
    if (dayI >= Data.numDayMonth[monthI]) {
      dayO = 1;
      monthO = monthI + 1;
    }
    return [monthO, dayO, weekdayO];
  }

  confirmDate(dayStr, msg, isDepart) {
    var day, monthIdx, weekday, weekdayIdx, year;
    year = parseInt(dayStr.substr(0, 2)) + 2000;
    monthIdx = parseInt(dayStr.substr(2, 2)) - 1;
    day = parseInt(dayStr.substr(4, 2));
    weekday = new Date();
    weekday.setYear(year);
    weekday.setMonth(monthIdx);
    weekday.setDay(day);
    weekdayIdx = weekday.getDay();
    if (isDepart) {
      [monthIdx, day, weekdayIdx] = this.departDate(monthIdx, day, weekdayIdx);
    }
    return `${Data.weekdays[weekdayIdx]} ${Data.months[monthIdx]} ${day}, ${year}  ${msg}`;
  }

  payHtml() {
    var cvcPtn, expPtn, numPtn;
    numPtn = "\d{4} \d{4} \d{4} \d{4}";
    expPtn = "(1[0-2]|0[1-9])\/\d\d";
    cvcPtn = "\d{3}";
    return `<div id="form-pay">\n  <span class="form-group">\n    <label for="cc-num" class="control-label" id="cc-com">Card Number</label>\n    <input id= "cc-num" type="tel" class="input-lg form-control cc-num masked" placeholder="•••• •••• •••• ••••" pattern="${numPtn}" required>\n    <div   id= "er-num" class="cc-msg">Invalid Number</div>\n  </span>\n\n  <span class="form-group">\n    <label for="cc-exp" class="control-label">MM/YY Expiration</label>\n    <input id= "cc-exp" type="tel" class="input-lg form-control cc-exp masked" placeholder="MM/YY" pattern="${expPtn}" required>\n    <div   id= "er-exp" class="cc-msg">Invalid MM/YY</div>\n  </span>\n\n  <span class="form-group">\n    <label for="cc-cvc" class="control-label">CVC</label>\n    <input id= "cc-cvc" type="tel" class="input-lg form-control cc-cvc masked" placeholder="•••" pattern="${cvcPtn}"  required>\n    <div   id= "er-cvc" class="cc-msg">Invalid CVC</div>\n  </span>\n\n  <span class="form-group">\n    <label for="cc-amt"   class="control-label">Amount</label>\n    <div   id= "cc-amt" class="input-lg form-control cc-amt"></div>\n    <div   id= "er-amt" class="cc-msg"></div>\n  </span>\n\n  <span class="form-group">\n    <label  for="cc-sub" class="control-label">&nbsp;</label>\n    <button id= "cc-sub" class="btn btn-lg btn-primary">Pay</button>\n    <div    id= "er-sub" class="cc-msg"></div>\n  </span>\n\n  <span class="form-group">\n    <label  for="cc-can" class="control-label">&nbsp;</label>\n    <button id= "cc-can" class="btn btn-lg btn-primary">Cancel</button>\n    <div    id= "er-can" class="cc-msg"></div>\n  </span>\n</div>`;
  }

  submitPayment(e) {
    var accept, ae, card, ce, cvc, ee, exp, iry, mon, ne, num, yer;
    if (e != null) {
      e.preventDefault();
    }
    this.hideCCErrors();
    num = $('#cc-num').val().toString();
    exp = $('#cc-exp').val().toString();
    cvc = $('#cc-cvc').val().toString();
    this.last4 = num.substr(11, 4);
    card = this.credit.cardFromNumber(num);
    iry = this.credit.parseCardExpiry(exp);
    accept = this.cardAccept(card.type);
    ne = this.credit.validateCardNumber(num);
    ee = this.credit.validateCardExpiry(iry);
    ce = this.credit.validateCardCVC(cvc, card.type);
    mon = exp.substr(0, 2);
    yer = '20' + exp.substr(5, 2);
    if (ne && ee && ce && accept) {
      this.hidePay();
      $('#Approval').text("Waiting For Approval...").show();
      this.token(num, mon, yer, cvc); // Call Stripe
    } else {
      ae = card.type + ' not accepted';
      if (!accept) {
        $('#er-num').text(ae);
      }
      if (!ne || !accept) {
        $('#er-num').show();
      }
      if (!ee) {
        $('#er-exp').show();
      }
      if (!ce) {
        $('#er-cvc').show();
      }
    }
  }

  //Util.log( 'Pay.submitPayment()', { num:num, ne:ne, exp:exp, ee:ee, cvc:cvc, ce:ce, mon:mon, yer:yer } )
  hidePay() {
    $('#MakePay').hide();
    $('#PayDiv').hide();
    return $('.PayBtns').hide();
  }

  showPay() {
    $('#MakePay').show();
    $('#PayDiv').show();
    return $('.PayBtns').show();
  }

  isValid(name, test, testing = false) {
    var valid, value;
    value = $('#' + name).val();
    valid = Util.isStr(value);
    if (testing) {
      $('#' + name).val(test);
      value = test;
      valid = true;
    }
    return [value, valid];
  }

  cardAccept(cardType) {
    return cardType === 'Visa' || cardType === 'Mastercard' || cardType === 'Discover';
  }

  subscribe() {
    this.stream.subscribe('tokens', this.onToken, this.onError);
    return this.stream.subscribe('charges', this.onCharge, this.onError);
  }

  token(number, exp_month, exp_year, cvc) {
    var input;
    input = {
      "card[number]": number,
      "card[exp_month]": exp_month,
      "card[exp_year]": exp_year,
      "card[cvc]": cvc
    };
    //ajaxRest( "tokens", 'post', input, @onTokenError )
    this.memToken("tokens", 'post', input, this.onTokenError);
  }

  charge(token, amount, currency, description) {
    var input;
    input = {
      source: token,
      amount: amount,
      currency: currency,
      description: description
    };
    //ajaxRest(  "charges", 'post', input, @onChargeError )
    this.memCharge("charges", 'post', input, this.onChargeError);
  }

  onTokenError(error, status) {
    Util.noop(error, status);
    this.showPay();
    $('#Approval').text("Unable to Verify Card").show();
  }

  onChargeError(error, status) {
    Util.noop(error, status);
    this.showPay();
    $('#Approval').text("Payment Denied").show();
  }

  onToken(obj) {
    //Util.log( 'StoreRest.onToken()', obj )
    this.tokenId = obj.id;
    this.cardId = obj.card.id;
    return this.charge(this.tokenId, this.amount, 'usd', this.resv.cust.first + " " + this.resv.cust.last);
  }

  memToken(table, op, input, onError) {
    var result;
    if (input === false) {
      ({});
    }
    if (onError === false) {
      ({});
    }
    result = {
      id: "tokenId",
      card: {
        id: "cardId"
      }
    };
    this.stream.publish(table, result);
  }

  memCharge(table, op, input, onError) {
    var result;
    if (input === false) {
      ({});
    }
    if (onError === false) {
      ({});
    }
    result = {
      outcome: {
        type: "authorized"
      }
    };
    this.stream.publish(table, result);
  }

  onCharge(obj) {
    //Util.log( 'Pay.onCharge()', obj )
    if (obj['outcome'].type === 'authorized') {
      this.doPost(this.resv);
      return this.res.postResv(this.resv, 'post', this.amount, 'Credit', this.last4, this.purpose);
    } else {
      //confirmEmail( @resv )
      this.amount = 0;
      this.doDeny(this.resv);
      return this.res.postResv(this.resv, 'deny', this.amount, 'Credit', this.last4, this.purpose);
    }
  }

  doPost(resv) {
    this.hidePay();
    $('#Approval').text(`Approved: A Confirnation Email Been Sent To ${resv.cust.email}`);
    if (this.home != null) {
      return this.home.showConfirm();
    }
  }

  doDeny(resv) {
    if (resv === false) {
      ({});
    }
    this.showPay();
    return $('#Approval').text('Payment Denied').show();
  }

  onError(obj) {
    return Util.error('StoreRest.onError()', obj);
  }

  ajaxRest(table, op, input, onError) {
    var settings, url;
    url = this.uri + table;
    settings = {
      url: url,
      type: op
    };
    settings.headers = {
      Authorization: 'Bearer ' + Data.stripeTestKey
    };
    settings.data = input;
    settings.success = (result, status, jqXHR) => {
      this.stream.publish(table, result);
      Util.noop(jqXHR, status);
    };
    settings.error = (jqXHR, status, error) => {
      Util.noop(jqXHR);
      return onError(status, error);
    };
    $.ajax(settings);
  }

  toQuery(input) {
    var key, query, val;
    query = "";
    if (input == null) {
      return query;
    }
    for (key in input) {
      if (!hasProp.call(input, key)) continue;
      val = input[key];
      query += `@${key}=${val}`;
    }
    return query[0] = '?';
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

  termsHtml() {
    return "<ul class=\"Terms\">\n  <li>The number of guests and pets has to be declared in the reservation.</li>\n  <li>Prices have been automatically calculated.</li>\n  <li style=\"margin-left:20px;\">Additional guests are $10 per night above the base rate for 2-4 guests.</li>\n  <li style=\"margin-left:20px;\">Each pet is $12 per night.</li>\n  <li>A deposit is 50% of the total reservation.</li>\n  <li>There will be a deposit refund with a 50-day cancellation notice, less a $50 fee.</li>\n  <li>Less than 50-day notice, deposit is forfeited.</li>\n  <li>Short term reservations have a 3-day cancellation deadline.</li>\n</ul>";
  }

};

export default Pay;
