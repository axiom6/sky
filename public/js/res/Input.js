var Input;

import Util from './Util.js';

import Data from './Data.js';

import UI from './UI.js';

Input = class Input {
  constructor(stream, store, res, master) {
    this.stream = stream;
    this.store = store;
    this.res = res;
    this.master = master;
    this.resv = {};
    this.state = 'add';
  }

  readyInput() {
    $('#ResAdd').empty();
    $('#ResAdd').append(this.html());
    $('#ResAdd').hide();
    return this.action();
  }

  createResv(arrive, stayto, roomId) {
    [arrive, stayto] = this.master.fillInCells(arrive, stayto, roomId, 'Free', 'Mine');
    if (!((arrive != null) && (stayto != null))) {
      return;
    }
    this.resv = {};
    this.resv.arrive = arrive;
    this.resv.stayto = stayto;
    this.resv.depart = Data.advanceDate(stayto, 1);
    this.resv.roomId = roomId;
    this.resv.resId = Data.resId(arrive, roomId); // Not need but for completeness
    this.resv.last = "";
    this.resv.status = 'Booking';
    this.resv.guests = 4;
    this.resv.pets = 0;
    this.resv.price = this.res.calcPrice(this.resv.roomId, this.resv.guests, this.resv.pets, this.resv.status);
    this.resv.booked = Data.today();
    this.state = 'add';
    this.refreshResv(this.resv);
  }

  updateResv(resv) {
    this.resv = this.res.copyResv(resv); // Make full copy
    this.state = 'put';
    this.refreshResv(this.resv);
  }

  html() {
    var htm;
    htm = "<table id=\"NRTable\"><thead>";
    htm += "<tr><th>Arrive</th><th>Stay To</th><th>Room</th><th>Name</th>";
    htm += "<th>Guests</th><th>Pets</th><th>Status</th>";
    htm += "<th>Nights</th><th>Price</th><th>Total</th><th>Tax</th><th>Charge</th><th>Action</th></tr>";
    htm += "</thead><tbody>";
    htm += `<tr><td>${this.arrive()}</td><td>${this.stayto()}</td><td>${this.rooms()}</td><td>${this.names()}</td>`;
    htm += `<td>${this.guests()}</td><td>${this.pets()}</td><td>${this.status()}</td>`;
    htm += "<td id=\"NRNights\"></td><td id=\"NRPrice\"></td><td id=\"NRTotal\"></td><td id=\"NRTax\"></td><td id=\"NRCharge\"></td>";
    htm += `<td id="NRSubmit">${this.submit()}</td></tr>`;
    htm += "</tbody></table>";
    return htm;
  }

  action() {
    var delDay, onMMDD, toDate;
    toDate = (mmdd) => {
      var dd, mi;
      [mi, dd] = Data.midd(mmdd);
      return Data.toDateStr(dd, mi);
    };
    delDay = (date, roomId) => {
      var dayId;
      dayId = Data.dayId(date, roomId);
      return this.res.delDay(this.res.days[dayId]);
    };
    onMMDD = (htmlId, mmdd0, mmdd1) => {
      var date0, date1, roomId;
      roomId = this.resv.roomId;
      date0 = toDate(mmdd0);
      date1 = toDate(mmdd1);
      if (htmlId === 'NRArrive') {
        this.res.delResv(this.resv);
        this.resv.resId = Data.resId(date1, roomId);
        this.resv.arrive = date1;
        this.resv.nights = Data.nights(this.resv.arrive, this.resv.stayto);
        this.res.addResv(this.resv);
        this.master.updArrival(date0, date1, this.resv.roomId, this.resv.last, this.resv.status);
      } else if (htmlId === 'NRStayTo') {
        if (date1 < date0) {
          this.master.fillCell(date0, roomId, 'Free');
          delDay(date0, roomId);
        } else {
          this.master.fillCell(date1, roomId, this.resv.status);
        }
        this.resv.stayto = date1;
      }
      //Util.log( 'Input.onMDD', htmlId, date0, date1, @resv.arrive, @resv.stayto )
      this.refreshResv(this.resv);
    };
    UI.onArrowsMMDD('NRArrive', onMMDD);
    UI.onArrowsMMDD('NRStayTo', onMMDD);
    $('#NRNames').change((event) => {
      this.resv.last = event.target.value;
    });
    //Util.log('Last', @resv.last )
    $('#NRRooms').change((event) => {
      this.resv.roomId = event.target.value;
      //Util.log('RoomId', @resv.roomId )
      this.refreshResv(this.resv);
    });
    $('#NRGuests').change((event) => {
      this.resv.guests = event.target.value;
      //Util.log('Guests', @resv.guests )
      this.refreshResv(this.resv);
    });
    $('#NRPets').change((event) => {
      this.resv.pets = event.target.value;
      //Util.log('Pets', @resv.pets )
      this.refreshResv(this.resv);
    });
    $('#NRStatus').change((event) => {
      this.resv.status = event.target.value;
      //Util.log('Status', @resv.status )
      this.refreshResv(this.resv);
    });
    return this.resvSubmits();
  }

  arrive() {
    return UI.htmlArrows('NRArrive', 'NRArrive');
  }

  stayto() {
    return UI.htmlArrows('NRStayTo', 'NRStayTo');
  }

  rooms() {
    return UI.htmlSelect('NRRooms', this.res.roomKeys, this.resv.roomId);
  }

  guests() {
    return UI.htmlSelect('NRGuests', Data.persons, 4);
  }

  pets() {
    return UI.htmlSelect('NRPets', Data.pets, 0);
  }

  status() {
    return UI.htmlSelect('NRStatus', Data.statusesSel, 'Skyline');
  }

  names() {
    return UI.htmlInput('NRNames');
  }

  submit() {
    var htm;
    htm = UI.htmlButton('NRCreate', 'NRSubmit', 'Create');
    htm += UI.htmlButton('NRChange', 'NRSubmit', 'Change');
    htm += UI.htmlButton('NRDelete', 'NRSubmit', 'Delete');
    //tm += UI.htmlButton( 'NRCancel', 'NRSubmit', 'Cancel' )
    return htm;
  }

  refreshResv(resv) {
    resv.depart = Data.advanceDate(resv.stayto, 1);
    resv.nights = Data.nights(resv.arrive, resv.stayto);
    resv.price = this.res.calcPrice(resv.roomId, resv.guests, resv.pets, resv.status);
    resv.deposit = resv.price * 0.5;
    resv.total = resv.nights * resv.price;
    resv.tax = parseFloat(Util.toFixed(resv.total * Data.tax));
    resv.charge = Util.toFixed(resv.total + resv.tax);
    $('#NRArrive').text(Data.toMMDD(resv.arrive));
    $('#NRStayTo').text(Data.toMMDD(resv.stayto));
    $('#NRNames').val(resv.last);
    $('#NRRooms').val(resv.roomId);
    $('#NRGuests').val(resv.guests);
    $('#NRPets').val(resv.pets);
    $('#NRStatus').val(resv.status);
    $('#NRNights').text(resv.nights);
    $('#NRPrice').text('$' + resv.price);
    $('#NRTotal').text('$' + resv.total);
    $('#NRTax').text('$' + resv.tax);
    $('#NRCharge').text('$' + resv.charge);
    this.master.addLast(resv.arrive, resv.roomId, resv.last);
    if (this.state === 'add') {
      $('#NRCreate').show();
      $('#NRChange').hide();
      $('#NRDelete').hide();
    } else if (this.state === 'put') {
      $('#NRCreate').hide();
      $('#NRChange').show();
      $('#NRDelete').show();
    }
  }

  resvSubmits() {
    var doRes;
    doRes = () => {
      var r;
      r = this.resv;
      if (r.status === 'Skyline' || 'Deposit') {
        r = this.res.createResvSkyline(r.arrive, r.stayto, r.roomId, r.last, r.status, r.guests, r.pets);
      } else if (r.status === 'Booking' || 'Prepaid') {
        r = this.res.createResvBooking(r.arrive, r.stayto, r.roomId, r.last, r.status, r.guests, r.total, r.booked);
      } else {
        alert(`Unknown Reservation Status: ${r.status} Name:${r.last}`);
      }
      this.master.addLast(r.arrive, r.roomId, r.last);
      this.resv = r;
    };
    $('#NRCreate').click(() => {
      if (Util.isStr(this.resv.last)) {
        doRes();
        this.res.addResv(this.resv);
      } else {
        alert('Incomplete Reservation Last Name Blank');
      }
    });
    $('#NRChange').click(() => {
      this.res.deleteDaysFromResv(this.resv);
      doRes();
      this.res.putResv(this.resv);
    });
    $('#NRDelete').click(() => {
      this.resv.status = 'Cancel';
      this.res.delResv(this.resv);
    });
    // For later
    return $('#NRCancel').click(() => {
      doRes();
      this.resv.status = 'Cancel';
      this.res.delResv(this.resv);
      this.res.canResv(this.resv);
    });
  }

};

export default Input;
