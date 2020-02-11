var Upload,
  hasProp = {}.hasOwnProperty;

import Util from './Util.js';

import Data from './Data.js';

import Bookings from './Bookings.js';

Upload = class Upload {
  constructor(stream, store, res) {
    this.onUploadRes = this.onUploadRes.bind(this);
    this.onUploadCan = this.onUploadCan.bind(this);
    /* For dev only. Repopulates database
    onCreateRes:() =>
    Util.log( 'Upload.onCreateRes')
    for own resId, resv of @res.resvs
    @res.delResv( resv )
    resvs = require( 'data/res.json' )
    for own resId, resv of resvs
    @res.addResv( resv )
    return
    */
    this.onUpdateDay = this.onUpdateDay.bind(this);
    this.onCreateCan = this.onCreateCan.bind(this);
    this.onCustomFix = this.onCustomFix.bind(this);
    this.stream = stream;
    this.store = store;
    this.res = res;
    this.uploadedText = "";
    this.uploadedResvs = {};
  }

  html() {
    var htm;
    htm = "";
    htm += "<h1  class=\"UploadH1\">Upload Booking.com</h1>";
    htm += "<button   id=\"UploadRes\"  class=\"btn btn-primary\">Upload Res</button>";
    htm += "<button   id=\"UploadCan\"  class=\"btn btn-primary\">Upload Can</button>";
    htm += "<button   id=\"UpdateDay\"  class=\"btn btn-primary\">Update Day</button>";
    htm += "<button   id=\"CustomFix\"  class=\"btn btn-primary\">Custom Fix</button>";
    htm += "<textarea id=\"UploadText\" class=\"UploadText\" rows=\"50\" cols=\"100\"></textarea>";
    return htm;
  }

  bindUploadPaste() {
    var onPaste;
    onPaste = (event) => {
      if (window.clipboardData && window.clipboardData.getData) { // IE
        this.uploadedText = window.clipboardData.getData('Text');
      } else if (event.clipboardData && event.clipboardData.getData) {
        this.uploadedText = event.clipboardData.getData('text/plain');
      }
      event.preventDefault();
      if (Util.isStr(this.uploadedText)) {
        this.uploadedResvs = this.uploadParse(this.uploadedText);
        return $('#UploadText').text(this.uploadedText);
      }
    };
    return document.addEventListener("paste", onPaste);
  }

  uploadParse(text) {
    var book, j, len, line, lines, resv, resvs, toks;
    resvs = {};
    if (!Util.isStr(text)) {
      return resvs;
    }
    lines = text.split('\n');
    for (j = 0, len = lines.length; j < len; j++) {
      line = lines[j];
      toks = line.split('\t');
      if (toks[0] === 'Guest name') {
        continue;
      }
      book = this.bookFromToks(toks);
      resv = this.resvFromBook(book);
      if (resv != null) {
        resvs[resv.resId] = resv;
      }
    }
    return resvs;
  }

  bookFromToks(toks) {
    var book;
    book = {};
    book.names = toks[0];
    book.arrive = toks[1];
    book.depart = toks[2];
    book.room = toks[3];
    book.booked = toks[4];
    book.status = toks[5];
    book.total = toks[6];
    book.commis = toks[7];
    book.bookingId = toks[8];
    //Util.log( 'Book......')
    //Util.log(  book )
    return book;
  }

  resvFromBook(book) {
    var arrive, booked, depart, guests, last, names, roomId, status, stayto, total;
    names = book.names.split(' ');
    arrive = this.toResvDate(book.arrive);
    depart = this.toResvDate(book.depart);
    stayto = Data.advanceDate(depart, -1);
    booked = this.toResvDate(book.booked);
    roomId = this.toResvRoomId(book.room);
    //first = names[0]
    last = names[1];
    status = this.toStatusBook(book.status);
    guests = this.toNumGuests(names);
    total = parseFloat(book.total.substr(3));
    if (status === 'Booking') {
      return this.res.createResvBooking(arrive, stayto, roomId, last, status, guests, total, booked);
    } else {
      return null;
    }
  }

  onUploadRes() {
    Util.log('Upload.onUploadRes');
    if (!Util.isStr(this.uploadedText)) {
      this.uploadedText = Bookings.bookingResvs;
      this.uploadedResvs = this.uploadParse(this.uploadedText);
      $('#UploadText').text(this.uploadedText);
    }
    if (Util.isObjEmpty(this.uploadedResvs)) {
      return;
    }
    if (!this.updateValid(this.uploadedResvs)) {
      return;
    }
    this.res.updateResvs(this.uploadedResvs);
    return this.uploadedResvs = {};
  }

  onUploadCan() {
    Util.log('Upload.onUploadCan');
    if (!Util.isStr(this.uploadedText)) {
      this.uploadedText = Data.canceled;
      this.uploadedResvs = this.uploadParse(this.uploadedText);
      $('#UploadText').text(this.uploadedText);
    }
    if (Util.isObjEmpty(this.uploadedResvs)) {
      return;
    }
    if (!this.updateValid(this.uploadedResvs)) {
      return;
    }
    this.res.updateCancels(this.uploadedResvs);
    return this.uploadedResvs = {};
  }

  onUpdateDay() {
    var onComplete;
    Util.log('Upload.onUpdateDay');
    onComplete = () => {
      var day, dayId, ref, ref1, resId, results, resv;
      ref = this.res.days;
      for (dayId in ref) {
        if (!hasProp.call(ref, dayId)) continue;
        day = ref[dayId];
        this.res.delDay(day);
      }
      ref1 = this.res.resvs;
      results = [];
      for (resId in ref1) {
        if (!hasProp.call(ref1, resId)) continue;
        resv = ref1[resId];
        results.push(this.res.updateDaysFromResv(resv));
      }
      return results;
    };
    this.res.selectAllDays(onComplete);
  }

  onCreateCan() {
    var can, canId, cans;
    Util.log('Upload.onCreateCan');
    //@store.make( 'Can' ) # Unexplicably Deleted Tables 'Res' and 'Day'
    cans = require('data/can.json');
    for (canId in cans) {
      if (!hasProp.call(cans, canId)) continue;
      can = cans[canId];
      this.res.addCan(can);
    }
  }

  onCustomFix() {
    var resvs;
    resvs = this.fixParse();
    if (resvs === false) {
      ({});
    }
  }

  //for resId,  resv of resvs
  //  @res.addResv( resv )
  fixParse() {
    var book, j, k, len, len1, line, lines, ref, resv, resvs, text, toks;
    resvs = {};
    ref = [Bookings.june, Bookings.july, Bookings.aug, Bookings.sept, Bookings.july19];
    for (j = 0, len = ref.length; j < len; j++) {
      text = ref[j];
      lines = text.split('\n');
      for (k = 0, len1 = lines.length; k < len1; k++) {
        line = lines[k];
        toks = line.split(' ');
        book = this.fixToks(toks);
        resv = this.fixResv(book);
        resvs[resv.resId] = resv;
      }
    }
    return resvs;
  }

  fixToks(toks) {
    var book;
    book = {};
    book.arrive = toks[0];
    book.stayto = toks[1];
    book.nights = toks[2];
    book.room = toks[3];
    book.last = toks[4];
    book.guests = toks[5];
    book.status = toks[6];
    book.booked = toks[7];
    //Util.log( 'Book......')
    //Util.log(  book )
    return book;
  }

  fixResv(book) {
    var arrive, booked, guests, last, nights, roomId, status, stayto, total;
    arrive = this.toFixDate(book.arrive);
    stayto = this.toFixDate(book.stayto);
    nights = Data.nights(arrive, stayto);
    roomId = book.room;
    last = book.last;
    status = this.toStatusFix(book.status);
    guests = book.guests;
    booked = this.toFixDate(book.booked);
    total = this.res.total(status, nights, roomId, guests);
    return this.res.createResv(arrive, stayto, booked, roomId, last, status, guests, 0, status, total);
  }

  toFixDate(mmdd) {
    var dd, mi;
    [mi, dd] = mmdd.length <= 2 ? [6, parseInt(mmdd)] : Data.midd(mmdd);
    return Data.toDateStr(dd, mi);
  }

  toStatusFix(s) {
    var r;
    r = s;
    if (s.length === 1) {
      r = s === 'B' ? 'Booking' : 'Skyline';
    }
    return r;
  }

  updateValid(uploadedResvs) {
    var resId, u, v, valid;
    valid = true;
    for (resId in uploadedResvs) {
      if (!hasProp.call(uploadedResvs, resId)) continue;
      u = uploadedResvs[resId];
      v = true;
      //.v &= Util.isStr( u.first )
      v &= Util.isStr(u.last);
      v &= 1 <= u.guests && u.guests <= 12;
      v &= Data.isDate(u.arrive);
      v &= Data.isDate(u.depart);
      v &= typeof pets === 'number' ? 0 <= u.pets && u.pets <= 4 : true;
      v &= 0 <= u.nights && u.nights <= 28;
      v &= Util.inArray(this.res.roomKeys, u.roomId);
      v &= 0.00 <= u.total && u.total <= 8820.00;
      v &= 120.00 <= u.price && u.price <= 315.00;
      valid &= v;
      if (!v) {
        Util.log('Resv Not Valid', resId, v);
        Util.log(u);
      }
    }
    Util.log('Master.updateValid()', valid);
    return true;
  }

  toNumGuests(names) {
    var i, j, ref;
    for (i = j = 0, ref = names.length; (0 <= ref ? j < ref : j > ref); i = 0 <= ref ? ++j : --j) {
      if (names[i] === 'guest' || names[i] === 'guests') {
        return names[i - 1];
      }
    }
    return '0'; // This will invalidate
  }

  toResvDate(bookDate) {
    var day, month, toks, year;
    toks = bookDate.split(' ');
    year = Data.year;
    month = Data.months.indexOf(toks[1]) + 1;
    day = toks[0];
    return year.toString() + Util.pad(month) + day;
  }

  toResvRoomId(bookRoom) {
    var toks;
    toks = bookRoom.split(' ');
    if (toks[0].charAt(0) === '#') {
      return toks[0].charAt(1);
    } else {
      return toks[2].charAt(0);
    }
  }

  toStatusBook(bookingStatus) {
    switch (bookingStatus) {
      case 'OK':
        return 'Booking';
      case 'Canceled':
        return 'Cancel';
      default:
        return 'Unknown';
    }
  }

};

export default Upload;
