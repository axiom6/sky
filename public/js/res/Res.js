var Res,
  hasProp = {}.hasOwnProperty;

import Data from './Data.js';

import Util from './Util.js';

Res = (function() {
  class Res {
    constructor(stream, store, appName, rooms1) {
      this.selectAllResvs = this.selectAllResvs.bind(this);
      this.selectAllDaysResvs = this.selectAllDaysResvs.bind(this);
      // .... Persistence ........
      this.onRes = this.onRes.bind(this);
      this.onDay = this.onDay.bind(this);
      // We don't always know or want to listen to a single resId
      //onResId:( op, doResv, resId ) => @store.on( 'Res', op,  resId, (resId,resv) => doResv(resId,resv) )
      this.insert = this.insert.bind(this);
      this.select = this.select.bind(this);
      this.stream = stream;
      this.store = store;
      this.appName = appName;
      this.rooms = rooms1;
      this.roomKeys = Util.keys(this.rooms);
      this.book = null;
      this.master = null;
      this.days = {};
      this.resvs = {};
      this.cans = {};
      this.order = 'Decend';
      this.today = Data.today();
    }

    dateRange(beg, end, onComplete = null) {
      this.store.subscribe('Day', 'range', 'none', (days) => {
        var day, dayId, ref;
        this.days = days;
        ref = this.days;
        for (dayId in ref) {
          if (!hasProp.call(ref, dayId)) continue;
          day = ref[dayId];
          day.status = Data.toStatus(day.status);
        }
        if (Util.isFunc(onComplete)) {
          return onComplete();
        }
      });
      this.store.range('Day', beg + '1', end + 'S');
    }

    selectAllDays(onComplete = null) {
      this.store.subscribe('Day', 'select', 'none', (days) => {
        this.days = days;
        if (Util.isFunc(onComplete)) {
          //day.status = Data.toStatus(day.status) for own dayId, day of @days
          return onComplete();
        }
      });
      this.store.select('Day');
    }

    selectAllResvs(onComplete = null, genDays = false) {
      this.store.subscribe('Res', 'select', 'none', (resvs) => {
        var ref, resId, resv;
        this.resvs = resvs;
        if (genDays) {
          ref = this.resvs;
          for (resId in ref) {
            if (!hasProp.call(ref, resId)) continue;
            resv = ref[resId];
            this.updateDaysFromResv(resv, false);
          }
        }
        if (Util.isFunc(onComplete)) { // resvs not passed to onComplete() - accesss @resvs later on
          return onComplete();
        }
      });
      this.store.select('Res');
    }

    selectAllDaysResvs(onComplete = null) {
      this.selectAllDays(() => {
        return this.selectAllResvs(onComplete);
      });
    }

    // Note the expanded roomUI is for Book.coffee and should never be persisted
    roomUI(rooms) {
      var key, room;
      for (key in rooms) {
        if (!hasProp.call(rooms, key)) continue;
        room = rooms[key];
        room.$ = {};
        room = this.populateRoom(room, {}, 0, 0, 2, 0);
      }
    }

    populateRoom(room, days, total, price, guests, pets) {
      room.days = days;
      room.total = total;
      room.price = price;
      room.guests = guests;
      room.pets = pets;
      room.change = 0; // Changes usually to spa opt out
      room.reason = 'No Changes';
      return room;
    }

    isNewResv(resv) {
      var nights;
      nights = Data.nights(resv.booked, this.today);
      return nights < Data.newDays;
    }

    status(date, roomId) {
      var day, dayId, st;
      if (roomId === 0) {
        return 'Free';
      }
      dayId = Data.dayId(date, roomId);
      day = this.days[dayId];
      st = day != null ? day.status : 'Free';
      //Util.trace( 'Res.status', st ) if not Util.isStr(st) or st is 'Unknown'
      return st;
    }

    klass(date, roomId) {
      var resv, status;
      resv = this.getResv(date, roomId);
      status = 'Free';
      if (resv != null) {
        status = resv.status;
        if (this.isNewResv(resv)) {
          if (status === 'Skyline' || status === 'book') {
            status = 'SkylNew';
          }
          if (status === 'Booking' || status === 'chan') {
            status = 'BookNew';
          }
        }
      } else {
        status = this.status(date, roomId);
      }
      //Util.log( 'Res.color()', date, roomId, resv?, nights, status )
      return status;
    }

    getResv(date, roomId) {
      var day;
      day = this.day(date, roomId);
      if (day != null) {
        return this.resvs[day.resId];
      } else {
        return null;
      }
    }

    day(date, roomId) {
      var day, dayId;
      dayId = Data.dayId(date, roomId);
      day = this.days[dayId];
      if (day != null) {
        return day;
      } else {
        return this.setDay({}, 'Free', 'none', dayId);
      }
    }

    dayIds(arrive, stayto, roomId) {
      var i, ids, j, nights, ref;
      nights = Data.nights(arrive, stayto);
      ids = [];
      for (i = j = 0, ref = nights; (0 <= ref ? j < ref : j > ref); i = 0 <= ref ? ++j : --j) {
        ids.push(Data.dayId(Data.advanceDate(arrive, i), roomId));
      }
      return ids;
    }

    datesFree(arrive, stayto, roomId, resv) {
      var dayId, dayIds, j, len;
      dayIds = this.dayIds(arrive, stayto, roomId);
      for (j = 0, len = dayIds.length; j < len; j++) {
        dayId = dayIds[j];
        if ((this.days[dayId] != null) && !(this.days[dayId].status === 'Free' || this.days[dayId].resId === resv.resId)) {
          Util.log('Res.collision days', {
            arrive: arrive,
            stayto: stayto,
            roomId: roomId,
            dayId: dayId
          });
          Util.log('Res.collision resv', {
            arrive: resv.arrive,
            stayto: resv.stayto,
            roomId: resv.roomId,
            name: resv.last
          });
          return false;
        }
      }
      return true;
    }

    allocDays(days) {
      if (this.book != null) {
        this.book.allocDays(days);
      }
      if (this.master != null) {
        this.master.allocDays(days);
      }
    }

    updateResvs(newResvs) {
      var resId, resv;
      for (resId in newResvs) {
        if (!hasProp.call(newResvs, resId)) continue;
        resv = newResvs[resId];
        this.addResv(resv);
      }
      return this.resvs;
    }

    updateCancels(newCancels) {
      var can, resId;
      for (resId in newCancels) {
        if (!hasProp.call(newCancels, resId)) continue;
        can = newCancels[resId];
        this.addCan(can);
      }
      return this.resvs;
    }

    isResvDay(day, resv) {
      return (day != null) && day.resId === resv.resId;
    }

    daysFromResv(resv) {
      var dayId, days, i, j, ref;
      days = {}; // resv days
      for (i = j = 0, ref = resv.nights; (0 <= ref ? j < ref : j > ref); i = 0 <= ref ? ++j : --j) {
        dayId = Data.dayId(Data.advanceDate(resv.arrive, i), resv.roomId);
        days[dayId] = this.isResvDay(this.days[dayId], resv) ? this.days[dayId] : this.setDay({}, resv.status, resv.resId, dayId);
      }
      return days;
    }

    deleteDaysFromResv(resv) {
      var day, dayId, days;
      days = this.daysFromResv(resv);
      for (dayId in days) {
        day = days[dayId];
        day.status = 'Free';
      }
      this.allocDays(days);
      for (dayId in days) {
        day = days[dayId];
        this.delDay(day);
      }
    }

    updateDaysFromResv(resv, add = true) {
      var day, dayId, days;
      days = this.daysFromResv(resv);
      this.allocDays(days);
      if (add) {
        for (dayId in days) {
          day = days[dayId];
          this.addDay(day);
        }
      }
    }

    calcPrice(roomId, guests, pets, status) {
      //Util.log( 'Res.calcPrice()', { roomId:roomId, guests:guests, pets:pets, guestprice:@rooms[roomId][guests], petfee:pets*Data.petPrice  } )
      if (status === 'Booking' || status === 'Prepaid') {
        return this.rooms[roomId].booking;
      } else {
        return this.rooms[roomId][guests] + pets * Data.petPrice;
      }
    }

    spaOptOut(roomId, isSpaOptOut = true) {
      if (this.rooms[roomId].spa === 'O' && isSpaOptOut) {
        return Data.spaOptOut;
      } else {
        return 0;
      }
    }

    genDates(arrive, nights) {
      var date, dates, i, j, ref;
      dates = {};
      for (i = j = 0, ref = nights; (0 <= ref ? j < ref : j > ref); i = 0 <= ref ? ++j : --j) {
        date = Data.advanceDate(arrive, i);
        dates[date] = "";
      }
      return dates;
    }

    // .... Creation ........
    total(status, nights, roomId, guests, pets = 0) {
      var tot;
      tot = 0;
      if (status === 'Skyline') {
        tot = nights * (this.rooms[roomId][guests] + pets * Data.petPrice);
      } else {
        tot = nights * this.rooms[roomId].booking;
      }
      return tot;
    }

    createResvSkyline(arrive, stayto, roomId, last, status, guests, pets, spa = false, cust = {}, payments = {}) {
      var booked, nights, price, total;
      booked = Data.today();
      price = this.rooms[roomId][guests] + pets * Data.petPrice;
      nights = Data.nights(arrive, stayto);
      total = price * nights;
      return this.createResv(arrive, stayto, booked, roomId, last, status, guests, pets, 'Skyline', total, spa, cust, payments);
    }

    createResvBooking(arrive, stayto, roomId, last, status, guests, total, booked) {
      var pets;
      total = total === 0 ? this.rooms[roomId].booking * Data.nights(arrive, stayto) : total;
      pets = 0;
      return this.createResv(arrive, stayto, booked, roomId, last, status, guests, pets, 'Booking', total);
    }

    createResv(arrive, stayto, booked, roomId, last, status, guests, pets, source, total, spa = false, cust = {}, payments = {}) {
      var resv;
      resv = {};
      resv.nights = Data.nights(arrive, stayto);
      resv.arrive = arrive;
      resv.stayto = stayto;
      resv.depart = Data.advanceDate(stayto, 1);
      resv.booked = booked;
      resv.roomId = roomId;
      resv.last = last;
      resv.status = status;
      resv.guests = guests;
      resv.pets = pets;
      resv.source = source;
      resv.resId = Data.resId(arrive, roomId);
      resv.total = total;
      resv.price = total / resv.nights;
      resv.tax = Util.toFixed(total * Data.tax);
      resv.spaOptOut = this.spaOptOut(roomId, spa);
      resv.charge = Util.toFixed(total + parseFloat(resv.tax) - resv.spaOptOut);
      resv.paid = 0;
      resv.balance = 0;
      resv.cust = cust;
      resv.payments = payments;
      this.updateDaysFromResv(resv);
      return resv;
    }

    // Copy the entire resv inluding cust and payments
    copyResv(r) {
      var c;
      c = Object.assign({}, r);
      c.cust = Object.assign({}, r.cust);
      c.payments = Object.assign({}, r.payments);
      return c;
    }

    createCust(first, last, phone, email, source) {
      var cust;
      cust = {};
      cust.custId = Data.genCustId(phone);
      cust.first = first;
      cust.last = last;
      cust.phone = phone;
      cust.email = email;
      cust.source = source;
      return cust;
    }

    createPayment(amount, method, last4, purpose) {
      var payment;
      payment = {};
      payment.amount = amount;
      payment.date = Data.today();
      payment.method = method;
      payment.with = method;
      payment.last4 = last4;
      payment.purpose = purpose;
      payment.cc = '';
      payment.exp = '';
      payment.cvc = '';
      return payment;
    }

    onRes(op, doRes) {
      return this.store.on('Res', op, 'none', (resId, res) => {
        return doRes(resId, res);
      });
    }

    onDay(op, doDay) {
      return this.store.on('Day', op, 'none', (dayId, day) => {
        return doDay(dayId, day);
      });
    }

    insert(table, rows, onComplete = null) {
      this.store.subscribe(table, 'insert', 'none', (rows) => {
        if (Util.isFunc(onComplete)) {
          return onComplete(rows);
        }
      });
      this.store.insert(table, rows);
    }

    select(table, rows, onComplete = null) {
      this.store.subscribe(table, 'select', 'none', (rows) => {
        if (Util.isFunc(onComplete)) {
          return onComplete(rows);
        }
      });
      this.store.select(table);
    }

    make(table, rows, onComplete = null) {
      this.store.subscribe(table, 'make', 'none', () => {
        return this.insert(table, rows, Util.isFunc(onComplete) ? onComplete() : void 0);
      });
      this.store.make(table);
    }

    /*
    makeTables:() ->
    @make( 'Room', Res.Rooms )
    @store.make( 'Res' )
    @store.make( 'Day' )
    return

     * Destroys whole data base up to root
    dropMakeTable:( table ) ->
    @store.subscribe( table, 'drop', 'none', () => @store.make(table) )
    @store.drop( table )
    return
     */
    setResvStatus(resv, post, purpose) {
      if (post === 'post') {
        if (purpose === 'PayInFull' || purpose === 'Complete') {
          resv.status = 'Skyline';
        }
        if (purpose === 'Deposit') {
          resv.status = 'Deposit';
        }
      } else if (post === 'deny') {
        resv.status = 'Free';
      }
      if (!Util.inArray(Data.statuses, resv.status)) {
        Util.error('Pay.setResStatus() unknown status ', resv.status);
        resv.status = 'Free';
      }
      return resv.status;
    }

    addResv(resv) {
      this.resvs[resv.resId] = resv;
      this.updateDaysFromResv(resv);
      this.store.add('Res', resv.resId, resv);
    }

    putResv(resv) {
      this.resvs[resv.resId] = resv;
      this.updateDaysFromResv(resv);
      this.store.put('Res', resv.resId, resv);
    }

    delResv(resv) {
      delete this.resvs[resv.resId];
      this.deleteDaysFromResv(resv);
      this.store.del('Res', resv.resId);
    }

    addCan(can) {
      can['cancel'] = this.today;
      this.cans[can.resId] = can;
      this.deleteDaysFromResv(can);
      this.store.add('Can', can.resId, can);
    }

    putCan(can) {
      this.resvs[can.resId] = can;
      this.store.put('Can', can.resId, can); // We do a put
    }

    delCan(can) {
      delete this.cans[can.resId];
      this.store.del('Can', can.resId);
    }

    addDay(day) {
      if (day.status !== 'Unknown') {
        this.days[day.dayId] = day;
        this.store.add('Day', day.dayId, day);
      } else {
        Util.error('Unknown day', day);
        Util.error('Checkon res', this.resvs[day.resId]);
      }
    }

    putDay(day) {
      this.days[day.dayId] = day;
      this.store.put('Day', day.dayId, day);
    }

    delDay(day) {
      delete this.days[day.dayId];
      this.store.del('Day', day.dayId);
    }

    postPayment(resv, post, amount, method, last4, purpose) {
      var payId, status;
      status = this.setResvStatus(resv, post, purpose);
      if (status === 'Skyline' || status === 'Deposit') {
        payId = Data.genPaymentId(resv.resId, resv.payments);
        resv.payments[payId] = this.createPayment(amount, method, last4, purpose);
        resv.paid += amount;
        resv.balance = resv.totals - resv.paid;
        this.postResv(resv);
      }
    }

    // Used for Days / dayId / roomId and for Res / rooms[dayId] since both has status and resid properties
    setDay(day, status, resId, dayId) {
      day.status = status;
      day.resId = resId;
      day.dayId = dayId;
      return day;
    }

    // ......Utilities ......
    optSpa(roomId) {
      return this.rooms[roomId].spa === 'O';
    }

    hasSpa(roomId) {
      return this.rooms[roomId].spa === 'O' || this.rooms[roomId].spa === 'Y';
    }

    // ...... UI Elements that does not quite belong here .....

    // Query
    resvArrayByDate(date) {
      var array, dayId, j, len, ref, resId, roomId;
      array = [];
      ref = this.roomKeys;
      for (j = 0, len = ref.length; j < len; j++) {
        roomId = ref[j];
        dayId = Data.dayId(date, roomId);
        if (this.days[dayId] != null) {
          resId = this.days[dayId].resId;
          if (this.resvs[resId] != null) {
            array.push(this.resvs[resId]);
          }
        }
      }
      return array;
    }

    resvArrayByProp(beg, end, prop) {
      var array, date, dayId, j, len, ref, resId, resv, resvs, roomId;
      if (!((beg != null) && (end != null))) {
        return [];
      }
      resvs = {};
      array = [];
      ref = this.roomKeys;
      for (j = 0, len = ref.length; j < len; j++) {
        roomId = ref[j];
        date = beg;
        while (date <= end) {
          dayId = Data.dayId(date, roomId);
          if (this.days[dayId] != null) {
            resId = this.days[dayId].resId;
            if (this.resvs[resId] != null) {
              resvs[resId] = this.resvs[resId];
            }
          }
          date = Data.advanceDate(date, 1);
        }
      }
      for (resId in resvs) {
        if (!hasProp.call(resvs, resId)) continue;
        resv = resvs[resId];
        array.push(resv);
      }
      this.order = this.order === 'Decend' ? 'Ascend' : 'Decend';
      if (prop === 'stayto') {
        this.order = 'Ascend';
      }
      return Util.quicksort(array, prop, this.order);
    }

    resvArrayDepart() {
      var array, beg, end, ref, resId, resv;
      array = [];
      beg = Data.toDateStr(1);
      end = Data.toDateStr(Data.numDaysMonth());
      ref = this.resvs;
      for (resId in ref) {
        resv = ref[resId];
        if (beg <= resv.depart && resv.depart <= end) {
          array.push(resv);
        }
      }
      return Util.quicksort(array, 'depart', 'Ascend');
    }

    resvSortDebug(array, prop, order) {
      var i, j, k, ref, ref1;
      for (i = j = 0, ref = array.length; (0 <= ref ? j < ref : j > ref); i = 0 <= ref ? ++j : --j) {
        Util.log(array[i][prop]);
      }
      array = Util.quicksort(array, prop, order);
      Util.log('------ Res.sortArray() end');
      for (i = k = 0, ref1 = array.length; (0 <= ref1 ? k < ref1 : k > ref1); i = 0 <= ref1 ? ++k : --k) {
        Util.log(array[i][prop]);
      }
      return array;
    }

  };

  Res.Sets = [
    'full',
    'book',
    'resv',
    'chan' // Data set for @res.days and @res.resv
  ];

  return Res;

}).call(this);

//array = @sortArray( array, prop, 'string', 'Ascend' )
//til.log( '------ Res.sortArray() xxx', { a:array[0][prop], b:array[3][prop], sort:@stringAscend( array[0], array[3] ) } )
export default Res;
