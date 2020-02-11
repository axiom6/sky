var Data,
  hasProp = {}.hasOwnProperty;

import Util from './Util.js';

Data = (function() {
  class Data {
    // ---- Read JSON with batch async
    static batchRead(batch, callback, create = null) {
      var key, obj;
      for (key in batch) {
        if (!hasProp.call(batch, key)) continue;
        obj = batch[key];
        this.batchJSON(obj, batch, callback, create);
      }
    }

    static batchComplete(batch) {
      var key, obj;
      for (key in batch) {
        if (!hasProp.call(batch, key)) continue;
        obj = batch[key];
        if (!obj['data']) {
          return false;
        }
      }
      return true;
    }

    // "Access-Control-Request-Headers": "*", "Access-Control-Request-Method": "*"
    static batchJSON(obj, batch, callback, refine = null) {
      var opt, url;
      url = Data.toUrl(obj.url);
      opt = {
        mode: 'no-cors',
        headers: {
          'Content-Type': 'application/json'
        }
      };
      fetch(url, opt).then((response) => {
        return response.json();
      }).then((data) => {
        obj['data'] = Util.isFunc(refine) ? refine(data) : data;
        if (Data.batchComplete(batch)) {
          return callback(batch);
        }
      }).catch((error) => {
        return console.error("Data.batchJSON()", {
          url: url,
          error: error
        });
      });
    }

    static toUrl(url) {
      if (!url.startsWith('../')) {
        if (window.location.href.includes('localhost')) {
          return Data.local + url;
        } else {
          return Data['hosted'] + url;
        }
      } else {
        return url;
      }
    }

    static toStatus(status) {
      var index;
      index = Data.legacy.indexOf(status);
      if (index > 0) {
        return Data.statuses[index];
      } else {
        return status;
      }
    }

    static toColor(status) {
      var index;
      index = Data.statuses.indexOf(status);
      if (index > 0) {
        return Data.colors[index];
      } else {
        return "yellow";
      }
    }

    static config(uri) {
      switch (uri) {
        case 'skyriver':
          return this.configSkyriver;
        case 'skyline':
          return this.configSkyline;
        default:
          return this.configSkytest;
      }
    }

    static resId(date, roomId) {
      return date + roomId;
    }

    static dayId(date, roomId) {
      return date + roomId;
    }

    static roomId(anyId) {
      return anyId.substr(6, 1);
    }

    static getRoomIdFromNum(num) {
      var roomId;
      roomId = num;
      if (roomId === 9) {
        roomId = 'N';
      }
      if (roomId === 10) {
        roomId = 'S';
      }
      return roomId;
    }

    static toDate(anyId) {
      if (anyId != null) {
        return anyId.substr(0, 6);
      } else {
        return Util;
      }
    }

    static genResId(roomUIs) {
      var days, resId, roomId, roomUI;
      resId = "";
      for (roomId in roomUIs) {
        if (!hasProp.call(roomUIs, roomId)) continue;
        roomUI = roomUIs[roomId];
        if (!(!Util.isObjEmpty(roomUI.days))) {
          continue;
        }
        days = Util.keys(roomUI.days).sort();
        resId = days[0] + roomId;
        break;
      }
      if (!Util.isStr(resId)) {
        Util.error('Data.getResId() resId blank');
      }
      return resId;
    }

    static genCustId(phone) {
      return Util.padEnd(phone.substr(0, 10), 10, '_');
    }

    static genPaymentId(resId, payments) {
      var payInt, paySeq, pays;
      pays = Util.keys(payments).sort();
      payInt = parseInt(pays[pays.length - 1]) + 1;
      paySeq = pays.length > 0 ? payInt.toString() : '1';
      return resId + paySeq;
    }

    static randomCustKey() {
      return Math.floor(Math.random() * (9999999999 - 1000000000)) + 1000000000;
    }

    static today() {
      var date, year;
      date = new Date();
      year = date.getFullYear() - 2000; // Go Y2K
      return Data.toDateStr(date.getDate(), date.getMonth(), year);
    }

    static month() {
      return Data.months[Data.monthIdx];
    }

    static numDaysMonth(month = Data.month()) {
      var mi;
      mi = Data.months.indexOf(month);
      return Data.numDayMonth[mi];
    }

    static advanceDate(date, numDays) {
      var dd, mi, yy;
      [yy, mi, dd] = this.yymidd(date);
      dd += numDays;
      if (dd > Data.numDayMonth[mi]) {
        dd = dd - Data.numDayMonth[mi];
        mi++;
      } else if (dd < 1) {
        mi--;
        dd = Data.numDayMonth[mi];
      }
      return Data.toDateStr(dd, mi, yy);
    }

    static advanceMMDD(mmdd, numDays) {
      var dd, mi;
      [mi, dd] = this.midd(mmdd);
      dd += numDays;
      if (dd > Data.numDayMonth[mi]) {
        dd = dd - Data.numDayMonth[mi];
        mi++;
      } else if (dd < 1) {
        mi--;
        dd = Data.numDayMonth[mi];
      }
      return Util.pad(mi + 1) + '/' + Util.pad(dd);
    }

    // Only good for a 28 to 30 day interval
    static nights(arrive, stayto) {
      var arriveDay, arriveMon, num, staytoDay, staytoMon;
      num = 0;
      arriveDay = parseInt(arrive.substr(4, 2));
      arriveMon = parseInt(arrive.substr(2, 2));
      staytoDay = parseInt(stayto.substr(4, 2));
      staytoMon = parseInt(stayto.substr(2, 2));
      if (arriveMon === staytoMon) {
        num = staytoDay - arriveDay + 1;
      } else if (arriveMon + 1 === staytoMon) {
        num = Data.numDayMonth[arriveMon - 1] - arriveDay + staytoDay + 1;
      }
      return Math.abs(num);
    }

    static weekday(date) {
      var dd, mi, weekday, yy;
      [yy, mi, dd] = this.yymidd(date);
      weekday = new Date();
      weekday.setYear(2000 + yy);
      weekday.setMonth(mi);
      weekday.seDay(dd);
      return Data.weekdays[weekday.getDay()];
    }

    static isDate(date) {
      var dd, mi, valid, yy;
      if (!Util.isStr(date) || date.length !== 6) {
        return false;
      }
      [yy, mi, dd] = this.yymidd(date);
      valid = true;
      valid &= yy === Data.year;
      valid &= 0 <= mi && mi <= 11;
      valid &= 1 <= dd && dd <= 31;
      return valid;
    }

    static begEndDates(begDate1, endDate1) {
      var begDate2, endDate2;
      if (!((begDate1 != null) && (endDate1 != null))) {
        return [null, null];
      }
      begDate2 = begDate1 <= endDate1 ? begDate1 : endDate1;
      endDate2 = endDate1 > begDate1 ? endDate1 : begDate1;
      return [begDate2, endDate2];
    }

    static yymidd(date) {
      var dd, mi, yy;
      yy = parseInt(date.substr(0, 2));
      mi = parseInt(date.substr(2, 2)) - 1;
      dd = parseInt(date.substr(4, 2));
      return [yy, mi, dd];
    }

    static midd(mmdd) {
      var dd, mi;
      mi = parseInt(mmdd.substr(0, 2)) - 1;
      dd = parseInt(mmdd.substr(3, 2));
      return [mi, dd];
    }

    static toMMDD(date) {
      var dd, mi, yy;
      [yy, mi, dd] = this.yymidd(date);
      return Util.pad(mi + 1) + '/' + Util.pad(dd);
    }

    static ddMMDD(dd, mi = Data.monthIdx) {
      return Util.pad(mi + 1) + '/' + Util.pad(dd);
    }

    static toMMDD2(date) {
      var dd, mi, str, yy;
      [yy, mi, dd] = this.yymidd(date);
      str = (mi + 1).toString() + '/' + dd.toString();
      Util.log('Data.toMMDD()', date, yy, mi, dd, str);
      return str;
    }

    static isElem($elem) {
      return !(($elem != null) && ($elem.length != null) && $elem.length === 0);
    }

    static dayMonth(day) {
      var monthDay;
      monthDay = day + Data.begDay - 1;
      if (monthDay > Data.numDayMonth[this.monthIdx]) {
        return monthDay - Data.numDayMonth[Data.monthIdx];
      } else {
        return monthDay;
      }
    }

    static toDateStr(dd, mi = Data.monthIdx, yy = Data.year) {
      return yy.toString() + Util.pad(mi + 1) + Util.pad(dd);
    }

    static toMonth3DayYear(date) {
      var dd, mi, yy;
      [yy, mi, dd] = Data.isDate(date) ? this.yymidd(date) : this.yymidd(Data.today());
      Util.log('Data.yymidd()', date, yy, mi, dd);
      return Data.months3[mi] + dd.toString() + ', ' + (2000 + yy).toString();
    }

  };

  Data.legacy = ["unkn", "canc", "free", "mine", "prep", "depo", "chan", "book", "cnew", "bnew"];

  Data.statuses = ["Unknown", "Cancel", "Free", "Mine", "Prepaid", "Deposit", "Booking", "Skyline", "BookNew", "SkylNew"];

  Data.colors = ["#E8E8E8", "#EEEEEE", "#FFFFFF", "#BBBBBB", "#AAAAAA", "#AAAAAA", "#888888", "#444444", "#333333", "#222222"];

  Data.colors1 = ["yellow", "whitesmoke", "lightgrey", "green", "#555555", "#000000", "blue", "slategray", "purple", "black"];

  Data.statusesSel = ["Deposit", "Skyline", "Prepaid", "Booking", "Cancel"];

  Data.sources = ["Skyline", "Booking", "Website"];

  Data.tax = 0.1055; // Official Estes Park tax rate. Also in Booking.com

  Data.commis = 0.15; // Bookings commision

  Data.season = ["May", "June", "July", "August", "September", "October"];

  Data.months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

  Data.months3 = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

  Data.numDayMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  Data.weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  Data.days = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"];

  Data.persons = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"];

  Data.nighti = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14"];

  Data.pets = ["0", "1", "2", "3", "4"];

  Data.petPrice = 12;

  Data.year = 17;

  Data.spaOptOut = 20;

  Data.monthIdx = new Date().getMonth();

  Data.monthIdx = 4 <= Data.monthIdx && Data.monthIdx <= 9 ? Data.monthIdx : 4;

  Data.newDays = 3; // Number of  days to signify a new booking

  Data.numDays = 15; // Display 15 days in Guest reservation calendar

  Data.begMay = 15;

  Data.begDay = Data.monthIdx === 4 ? Data.begMay : 1; // Being season on May 15

  Data.beg = '170515'; // Beg seasom on May 15, 2017

  Data.end = '171009'; // Beg seasom on Oct  9, 2017

  Data.configSkyriver = {
    apiKey: "AIzaSyDJxypukgOw20z80EZW9w1ObgyqB20qfYI",
    authDomain: "skyriver-81c21.firebaseapp.com",
    databaseURL: "https://skyriver-81c21.firebaseio.com",
    projectId: "skyriver-81c21",
    storageBucket: "skyriver-81c21.appspot.com",
    messagingSenderId: "1090600167020"
  };

  Data.tomUID = "4eKA0L3Gl0aR8LSAnFtAlOMWLUd2";

  Data.skyUID = "zf3UMOQz8FZiQ5hBypHeoAhDQnn2";

  Data.sueUID = "K2osvFYkZoTGVzkEqdqrH8rkr8h2";

  Data.skyPrj = "project-1090600167020";

  /*
    SkylineOnTheRiver.com 	TXT 	v=spf1 include:_spf.firebasemail.com ~all
    smtpapi._domainkey.SkylineOnTheRiver.com 	TXT 	k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDPtW5iwpXVPiH5FzJ7Nrl8USzuY9zqqzjE0D1r04xDN6qwziDnmgcFNNfMewVKN2D1O+2J9N14hRprzByFwfQW76yojh54Xu3uSbQ3JP0A7k8o8GutRF8zbFUA8n0ZH2y0cIEjMliXY4W4LwPA7m4q0ObmvSjhd63O9d8z1XkUBwIDAQAB
    SkylineOnTheRiver.com 	TXT 	firebase=skyriver-81c21
  */
  Data.configSkytest = {
    apiKey: "AIzaSyAH4gtA-AVzTkwO_FXiEOlgDRK1rKLdJ2k",
    authDomain: "skytest-25d1c.firebaseapp.com",
    databaseURL: "https://skytest-25d1c.firebaseio.com",
    storageBucket: "skytest-25d1c.appspot.com",
    messagingSenderId: "978863515797"
  };

  Data.configSkyline = {
    apiKey: "AIzaSyBjMGVzZ6JgZBs8O7mBQfH6clHYDmjTsGU",
    authDomain: "skyline-fed2b.firebaseapp.com",
    databaseURL: "https://skyline-fed2b.firebaseio.com",
    projectId: "skyline-fed2b",
    storageBucket: "skyline-fed2b.appspot.com/",
    messagingSenderId: "279547846849"
  };

  Data.databases = {
    skyriver: "skyline-fed2b",
    skyline: "skyline-fed2b",
    skytest: "skytest-25d1c"
  };

  Data.stripeTestKey = "sk_test_FCa6Z3AusbsdhyV93B4CdWnV";

  Data.stripeTestPub = "pk_test_0VHIhWRH8hFwSeP2n084Ze4L";

  Data.stripeLiveKey = "sk_live_CCbj5oirIeHwTlyKVXJnbrgt";

  Data.stripeLivePub = "pk_live_Lb83wXgDVIuRoEpmK9ji2AU3";

  Data.stripeCurlKey = "sk_test_lUkwzunJkKfFmcEjHBtCfvhs";

  return Data;

}).call(this);

export default Data;
