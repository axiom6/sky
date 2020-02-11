var Book,
  hasProp = {}.hasOwnProperty;

import Util from './Util.js';

import Data from './Data.js';

import UI from './UI.js';

Book = class Book {
  constructor(stream, store, res, pay, pict) {
    // Significant transition from Book to Pay
    this.onGoToPay = this.onGoToPay.bind(this);
    this.calcPrice = this.calcPrice.bind(this);
    this.onGuests = this.onGuests.bind(this);
    this.onPets = this.onPets.bind(this);
    this.onSpa = this.onSpa.bind(this);
    this.onMonth = this.onMonth.bind(this);
    this.onDay = this.onDay.bind(this);
    this.resetRooms = this.resetRooms.bind(this);
    this.resetRooms2 = this.resetRooms2.bind(this);
    this.onPop = this.onPop.bind(this);
    this.onTest = this.onTest.bind(this);
    this.onCellBook = this.onCellBook.bind(this);
    this.allocDays = this.allocDays.bind(this);
    this.stream = stream;
    this.store = store;
    this.res = res;
    this.pay = pay;
    this.pict = pict;
    this.rooms = this.res.rooms;
    this.res.book = this;
    this.$cells = [];
    this.last = null; // Last date clicked
    this.totals = 0;
    this.method = 'site';
  }

  ready() {
    var onComplete;
    this.res.roomUI(this.rooms);
    $('#Book').empty();
    $('#Pays').empty();
    $('#Book').append(this.bookHtml());
    $('#Insts').append(this.instructHtml());
    $('#Inits').append(this.initsHtml());
    $('#Guest').append(this.guestHtml());
    $('.guests').change(this.onGuests);
    $('.pets').change(this.onPets);
    $('.SpaCheck').change(this.onSpa);
    $('#Months').change(this.onMonth);
    $('#Days').change(this.onDay);
    $('#Pop').click(this.onPop);
    $('#Test').click(this.onTest);
    $('#GoToPay').click(this.onGoToPay); // .prop('disabled',true)
    $('#Totals').css({
      height: '21px'
    });
    $('#Navb').hide();
    onComplete = () => {
      $('#Rooms').append(this.roomsHtml(Data.year, Data.monthIdx, Data.begDay, Data.numDays));
      this.roomsJQuery();
      return $('#Book').show();
    };
    this.res.dateRange(Data.beg, Data.end, onComplete);
  }

  bookHtml() {
    return "<div id=\"Make\" class=\"Title\">Make Your Reservation</div>\n<div id=\"Insts\"></div>\n<div><div id=\"Inits\"></div></div>\n<div id=\"Rooms\"></div>\n<div id=\"Guest\"></div>";
  }

  instructHtml() {
    return "<div   class=\"Instruct\">\n  <div>1. Select Month and Day of Arrival 2. Then for each Room Select:</div>\n  <div style=\"padding-left:16px;\">3. Number of Guests 4. Number of Pets 5. Click the Days</div>\n  <div>6. Enter Contact Information: First Last Names, Phone and EMail</div>\n</div>";
  }

  initsHtml() {
    var htm;
    htm = `<label for="Months" class="InitIp">Start: ${UI.htmlSelect("Months", Data.season, Data.month())}</label>`;
    htm += `<label for="Days"   class="InitIp">       ${UI.htmlSelect("Days", Data.days, Data.begDay)}</label>`;
    htm += `<label class="InitIp">&nbsp;&nbsp;${2000 + Data.year}</label>`;
    htm += "<span  id=\"Pop\"  class=\"Test\">Pop</span>";
    htm += "<span  id=\"Test\" class=\"Test\">Test</span>";
    return htm;
  }

  seeRoom(roomId, room) {
    //"""<a href="rooms/#{roomId}.html" id="#{roomId}L">#{room.name}</a>"""
    return room.name;
  }

  roomsHtml(year, monthIdx, begDay, numDays) {
    var date, day, htm, i, j, k, l, ref, ref1, ref2, ref3, ref4, room, roomId, weekday, weekdayIdx;
    date = new Data();
    date.setYear(2000 + year);
    date.setMonth(monthIdx);
    data.setDay(1);
    weekdayIdx = date.getDay();
    htm = "<table><thead>";
    htm += "<tr><th></th><th></th><th></th><th></th><th></th>";
    for (day = i = 1, ref = numDays; (1 <= ref ? i <= ref : i >= ref); day = 1 <= ref ? ++i : --i) {
      weekday = Data.weekdays[(weekdayIdx + begDay + day - 2) % 7];
      htm += `<th>${weekday}</th>`;
    }
    htm += "<th>Room</th></tr><tr><th>Cottage</th><th>Guests</th><th>Pets</th><th>Spa</th><th>Price</th>";
    for (day = j = 1, ref1 = numDays; (1 <= ref1 ? j <= ref1 : j >= ref1); day = 1 <= ref1 ? ++j : --j) {
      htm += `<th>${Data.dayMonth(day)}</th>`;
    }
    htm += "<th>Total</th></tr></thead><tbody>";
    ref2 = this.rooms;
    for (roomId in ref2) {
      if (!hasProp.call(ref2, roomId)) continue;
      room = ref2[roomId];
      htm += `<tr id="${roomId}"><td class="td-left">${this.seeRoom(roomId, room)}</td><td class="guests">${this.g(roomId)}</td><td class="pets">${this.p(roomId)}</td><td>${this.spa(roomId)}</td><td id="${roomId}M" class="room-price">${'$' + this.calcPrice(roomId)}</td>`;
      for (day = k = 1, ref3 = numDays; (1 <= ref3 ? k <= ref3 : k >= ref3); day = 1 <= ref3 ? ++k : --k) {
        date = Data.toDateStr(Data.dayMonth(day));
        htm += this.createCell(date, roomId);
      }
      htm += `<td class="room-total" id="${roomId}T"></td></tr>`;
    }
    htm += "<tr>";
    for (day = l = 1, ref4 = numDays + 5; (1 <= ref4 ? l <= ref4 : l >= ref4); day = 1 <= ref4 ? ++l : --l) {
      htm += "<td></td>";
    }
    htm += "<td class=\"room-total\" id=\"Totals\">&nbsp;</td></tr>";
    htm += "</tbody></table>";
    return htm;
  }

  guestHtml() {
    var phPtn;
    phPtn = "\d{3} \d{3} \d{4}"; // pattern="#{phPtn}"
    return `<form autocomplete="on" method="POST" id="FormName">\n  <div id="Names">\n    <span class="SpanIp">\n      <label for="First" class="control-label">First Name</label>\n      <input id= "First" type="text" class="input-lg form-control" autocomplete="given-name" required>\n      <div   id= "FirstER" class="NameER">* Required</div>\n    </span>\n\n    <span class="SpanIp">\n      <label for="Last" class="control-label">Last Name</label>\n      <input id= "Last" type="text" class="input-lg form-control" autocomplete="family-name" required>\n      <div   id= "LastER" class="NameER">* Required</div>\n    </span>\n\n    <span class="SpanIp">\n      <label for="Phone" class="control-label">Phone</label>\n      <input id= "Phone" type="tel" class="input-lg form-control" placeholder="••• ••• ••••"  pattern="${phPtn}" required>\n      <div   id= "PhoneER" class="NameER">* Required</div>\n    </span>\n\n    <span class="SpanIp">\n      <label for="EMail"   class="control-label">Email</label>\n      <input id= "EMail" type="email" class="input-lg form-control" autocomplete="email" required>\n      <div   id= "EMailER" class="NameER">* Required</div>\n    </span>\n  </div>\n  <div id="GoToDiv" style="text-align:center;">\n   <button class="btn btn-primary" type="submit" id="GoToPay">Go To Confirmation and Payment</button>\n  </div>\n</form>`;
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
    //$('#'+name+'ER').show() if not valid
    return [value, valid];
  }

  createCust(testing = false) {
    var cust, email, ev, first, fv, last, lv, phone, pv, tv;
    [first, fv] = this.isValid('First', 'Samuel', testing);
    [last, lv] = this.isValid('Last', 'Hosendecker', testing);
    [phone, pv] = this.isValid('Phone', '3037977129', testing);
    [email, ev] = this.isValid('EMail', 'Thomas.Edmund.Flaherty@gmail.com', testing);
    tv = this.totals > 0;
    cust = this.res.createCust(first, last, phone, email, "site");
    return [tv, fv, lv, pv, ev, cust];
  }

  onGoToPay(e) {
    var cust, ev, fv, lv, pv, tv;
    if (e != null) {
      e.preventDefault();
    }
    [tv, fv, lv, pv, ev, cust] = this.createCust();
    if (tv && fv && lv && pv && ev) {
      $('.NameER').hide();
      $('#Book').hide();
      this.pay.initPayResv(this.totals, cust, this.rooms);
    } else {
      alert(this.onGoToMsg(tv, fv, lv, pv, ev));
    }
  }

  onGoToMsg(tv, fv, lv, pv, ev) {
    var msg;
    msg = "";
    if (!tv) {
      msg += "Total is 0\n";
    }
    if (!tv) {
      msg += "Need to Click Rooms\n";
    }
    if (!fv) {
      msg += "Enter First Name\n";
    }
    if (!lv) {
      msg += "Enter Last  Name\n";
    }
    if (!pv) {
      msg += "Enter Phone Number\n";
    }
    if (!ev) {
      msg += "Enter Email\n";
    }
    return msg;
  }

  //Util.log('Book.createCell', { date:date, roomId:roomId, status:status, color:Data.toColor(status), style:style, htm:htm } )
  createCell(date, roomId) {
    var status, style;
    status = this.res.status(date, roomId);
    style = `background:${Data.toColor(status)};`;
    return `<td id="${this.cellId(date, roomId)}" class="room-${status}" style="${style}"></td>`;
  }

  cellId(date, roomId) {
    return 'R' + date + roomId;
  }

  roomIdCell($cell) {
    return $cell.attr('id').substr(7, 1);
  }

  dateCell($cell) {
    return $cell.attr('id').substr(1, 6);
  }

  $cell(date, roomId) {
    return $('#' + this.cellId(date, roomId));
  }

  roomsJQuery() {
    var $cell, date, day, i, j, len, ref, ref1, ref2, room, roomId, status;
    ref = this.$cells;
    for (i = 0, len = ref.length; i < len; i++) {
      $cell = ref[i];
      $cell.unbind("click");
    }
    this.$cells = [];
    ref1 = this.rooms;
    for (roomId in ref1) {
      room = ref1[roomId];
      room.$ = $('#' + roomId); // Keep jQuery out of room database table
      for (day = j = 1, ref2 = Data.numDays; (1 <= ref2 ? j <= ref2 : j >= ref2); day = 1 <= ref2 ? ++j : --j) {
        date = Data.toDateStr(Data.dayMonth(day));
        $cell = this.$cell(date, roomId);
        $cell.click((event) => {
          return this.onCellBook(event);
        });
        this.$cells.push($cell);
        this.updateTotal(roomId);
        status = this.res.status(date, roomId);
        this.cellStatus($cell, status);
      }
    }
  }

  calcPrice(roomId) {
    var room;
    room = this.rooms[roomId];
    room.price = this.res.calcPrice(roomId, room.guests, room.pets, 'Skyline');
    return room.price;
  }

  updateTotal(roomId) {
    var nights, price, room, text;
    price = this.calcPrice(roomId);
    $('#' + roomId + 'M').text(`${'$' + price}`);
    room = this.rooms[roomId];
    nights = Util.keys(room.days).length;
    room.total = price * nights + room.change;
    // Util.log( 'Book.updateTotal()', { roomId:roomId, nights:nights, change:room.change, total:room.total } )
    text = room.total === 0 ? '' : '$' + room.total;
    $('#' + roomId + 'T').text(text);
    this.updateTotals();
  }

  updateTotals() {
    var ref, room, roomId, text;
    this.totals = 0;
    ref = this.rooms;
    for (roomId in ref) {
      if (!hasProp.call(ref, roomId)) continue;
      room = ref[roomId];
      this.totals += room.total;
    }
    text = this.totals === 0 ? '' : '$' + this.totals;
    $('#Totals').text(text);
    if (this.totals > 0) {
      $('#GoToPay').prop('disabled', false);
    }
  }

  g(roomId) {
    return UI.htmlSelect(roomId + 'G', Data.persons, 2, 'guests', this.rooms[roomId].max);
  }

  p(roomId) {
    return UI.htmlSelect(roomId + 'P', Data.pets, 0, 'pets', 3);
  }

  onGuests(event) {
    var roomId;
    roomId = $(event.target).attr('id').charAt(0);
    this.rooms[roomId].guests = event.target.value;
    this.updateTotal(roomId);
  }

  onPets(event) {
    var roomId;
    roomId = $(event.target).attr('id').charAt(0);
    this.rooms[roomId].pets = event.target.value;
    this.updateTotal(roomId);
  }

  spa(roomId) {
    if (this.res.optSpa(roomId)) {
      return `<input id="${roomId}SpaCheck" class="SpaCheck" type="checkbox" value="${roomId}" checked>`;
    } else {
      return "";
    }
  }

  onSpa(event) {
    var $elem, checked, reason, room, roomId, spaFee;
    $elem = $(event.target);
    roomId = $elem.attr('id').charAt(0);
    room = this.rooms[roomId];
    checked = $elem.is(':checked');
    spaFee = checked ? 20 : -20;
    reason = checked ? 'Spa Added' : 'Spa Opted Out';
    room.change += spaFee;
    room.reason = reason;
    if (room.total > 0) {
      this.updateTotal(roomId);
    }
  }

  onMonth(event) {
    Data.monthIdx = Data.months.indexOf(event.target.value);
    Data.begDay = Data.month() === 'May' ? Data.begMay : 1;
    $('#Days').val(Data.begDay.toString());
    this.resetRooms(); // or resetDateRange:()
  }

  onDay(event) {
    Data.begDay = parseInt(event.target.value);
    if (Data.month() === 'October' && Data.begDay > 1) {
      Data.begDay = 1;
      alert('The Season Ends on October 15');
    }
    this.resetRooms(); // or resetDateRange:()
  }

  // Not needed because we have the whole date range for the season
  resetDateRange() {
    var beg, end;
    beg = Data.toDateStr(Data.begDay, Data.monthIdx);
    end = Data.advanceDate(beg, Data.numDays - 1);
    return this.res.dateRange(beg, end, this.resetRooms);
  }

  resetRooms() {}

  resetRooms2() {
    $('#Rooms').empty();
    $('#Rooms').append(this.roomsHtml(Data.year, Data.monthIdx, Data.begDay, Data.numDays));
    return this.roomsJQuery();
  }

  onPop() {
    //Util.log( 'Book.onPop()'  )
    this.createCust(true);
    this.pay.testing = true;
  }

  onTest() {
    if (this.test != null) {
      this.test.doTest();
    }
  }

  onCellBook(event) {
    var $cell, date, roomId, status;
    $cell = $(event.target);
    [date, roomId, status] = this.cellBook($cell);
    if (status === 'Mine') {
      this.fillInCells(this.last, date, roomId, 'Free', status);
    }
    this.last = date;
  }

  fillInCells(begDate, endDate, roomId, free, fill) {
    var $cell, $cells, beg, end, i, len, next, status;
    if (!((begDate != null) && (endDate != null) && (roomId != null))) {
      return;
    }
    [beg, end] = Data.begEndDates(begDate, endDate);
    $cells = [];
    next = beg;
    while (next <= end) {
      $cell = this.$cell('M', next, roomId);
      status = this.res.status(next, roomId);
      if (status === free || status === fill || status === 'Cancel') {
        $cells.push($cell);
        next = Data.advanceDate(next, 1);
      } else {
        return [null, null];
      }
    }
    for (i = 0, len = $cells.length; i < len; i++) {
      $cell = $cells[i];
      this.cellStatus($cell, fill);
    }
  }

  cellBook($cell) {
    var date, resId, roomId, status;
    date = this.dateCell($cell);
    roomId = this.roomIdCell($cell);
    resId = Data.resId(date, roomId);
    status = this.res.status(date, roomId);
    if (status === 'Free') {
      status = 'Mine';
      this.updateCellStatus($cell, 'Mine', resId);
    } else if (status === 'Mine') {
      status = 'Free';
      this.updateCellStatus($cell, 'Free', resId);
    }
    return [date, roomId, status];
  }

  updateCellStatus($cell, status, resId) {
    var date, day, nday, roomId, weekday;
    this.cellStatus($cell, status);
    date = this.dateCell($cell);
    roomId = this.roomIdCell($cell);
    resId = Data.resId(date, roomId);
    day = this.res.day(date, roomId);
    if (status === 'Mine') {
      this.res.setDay(day, status, resId);
    } else if (status === 'Free') {
      weekday = Data.weekday(date);
      if (weekday === 'Fri' || weekday === 'Sat') {
        nday = Data.advanceDate(date, 1);
        this.cellStatus(this.$cell(nday, roomId), 'Free');
      }
    }
    this.updateTotal(roomId);
    return [roomId, status];
  }

  allocDays(days) {
    var date, day, dayId, roomId;
    for (dayId in days) {
      if (!hasProp.call(days, dayId)) continue;
      day = days[dayId];
      date = Data.toDate(dayId);
      roomId = Data.roomId(dayId);
      this.allocCell(date, day.status, roomId);
    }
  }

  allocCell(date, status, roomId) {
    return this.cellStatus(this.$cell(date, roomId), status);
  }

  cellStatus($cell, klass) {
    $cell.removeClass().addClass("room-" + klass);
    $cell.css({
      background: Data.toColor(klass)
    });
  }

};

//Util.log( 'Book.cellStatus', klass, Data.toColor(klass) )
export default Book;
