var Master,
  hasProp = {}.hasOwnProperty;

import Util from './Util.js';

import Data from './Data';

import UI from './UI';

import Upload from './Upload';

import Query from './Query';

import Input from './Input';

import Season from './Season';

Master = class Master {
  constructor(stream, store, res) {
    this.onMasterBtn = this.onMasterBtn.bind(this);
    this.doPrint = this.doPrint.bind(this);
    this.onMasterPrt = this.onMasterPrt.bind(this);
    this.onResTblPrt = this.onResTblPrt.bind(this);
    this.onMakResBtn = this.onMakResBtn.bind(this);
    this.onSeasonBtn = this.onSeasonBtn.bind(this);
    this.onSeasonPrt = this.onSeasonPrt.bind(this);
    this.onDailysBtn = this.onDailysBtn.bind(this);
    this.onDailysPrt = this.onDailysPrt.bind(this);
    this.onUploadBtn = this.onUploadBtn.bind(this);
    this.readyMaster = this.readyMaster.bind(this);
    //Util.log( 'Master.readyMaster()' )
    this.readyCells = this.readyCells.bind(this);
    this.listenToDays = this.listenToDays.bind(this);
    this.listenToResv = this.listenToResv.bind(this);
    this.selectToDays = this.selectToDays.bind(this);
    this.allocDays = this.allocDays.bind(this);
    this.onAlloc = this.onAlloc.bind(this);
    this.onMonthClick = this.onMonthClick.bind(this);
    this.stream = stream;
    this.store = store;
    this.res = res;
    this.rooms = this.res.rooms;
    this.upload = new Upload(this.stream, this.store, this.res);
    this.query = new Query(this.stream, this.store, this.res, this);
    this.input = new Input(this.stream, this.store, this.res, this);
    this.season = new Season(this.stream, this.store, this.res);
    this.res.master = this;
    this.dateBeg = this.res.today;
    this.dateEnd = this.res.today;
    this.dateSel = "End";
    this.roomId = null;
    this.nextId = null;
    this.resMode = 'Table'; // or 'Input'
  }

  ready() {
    //@selectToDays() if @store.justMemory
    this.listenToDays();
    //listenToResv()
    $('#MasterBtn').click(this.onMasterBtn);
    $('#MasterPrt').click(this.onMasterPrt);
    $('#ResTblPrt').click(this.onResTblPrt);
    $('#MakResBtn').click(this.onMakResBtn);
    $('#SeasonBtn').click(this.onSeasonBtn);
    $('#SeasonPrt').click(this.onSeasonPrt);
    $('#DailysBtn').click(this.onDailysBtn);
    $('#DailysPrt').click(this.onDailysPrt);
    $('#UploadBtn').click(this.onUploadBtn);
    $('#ReadyMBtn').click(this.readyMaster);
    //res.dateRange( Data.beg, Data.end, @readyMaster ) # This works
    //res.selectAllDaysResvs( @readyMaster )
    this.res.selectAllResvs(this.readyMaster, true);
  }

  onMasterBtn(onComplete = null) {
    this.resMode = 'Table';
    $('#Season').hide();
    $('#Dailys').hide();
    $('#Upload').hide();
    $('#ResAdd').hide();
    $('#ResTbl').show();
    $('#Master').show();
    if (Util.isFunc(onComplete)) {
      onComplete();
    }
  }

  doPrint() {
    window.print();
    $('#Buttons').show('fast');
  }

  onMasterPrt() {
    var onComplete;
    onComplete = () => {
      return $('#Buttons, #ResTbl').hide('fast', this.doPrint);
    };
    this.onMasterBtn(onComplete);
  }

  onResTblPrt() {
    var onComplete;
    $('#QArrive').text(Data.ddMMDD(1));
    $('#QStayTo').text(Data.ddMMDD(Data.numDaysMonth()));
    this.query.resvBody(this.res.resvArrayDepart());
    onComplete = () => {
      return $('#Buttons, #Master').hide('fast', this.doPrint);
    };
    this.onMasterBtn(onComplete);
  }

  begStayTo() {
    return Data.toDateStr(Data.numDaysMonth(), Data.monthIdx - 1);
  }

  begQuery() {
    var dd, dt, mi, yy;
    [yy, mi, dd] = Data.yymidd(this.res.today);
    dt = mi === Data.monthIdx ? dd : 1;
    return Data.toDateStr(dt);
  }

  onMakResBtn() {
    this.resMode = 'Input';
    $('#Season').hide();
    $('#Dailys').hide();
    $('#Upload').hide();
    $('#ResAdd').show();
    $('#ResTbl').hide();
    $('#Master').show();
    this.fillInCells(this.dateBeg, this.dateEnd, this.roomId, 'Mine', 'Free'); // Clear any previous fill
    this.dateEnd = this.dateBeg;
  }

  onSeasonBtn(onComplete = null) {
    $('#Master').hide();
    $('#Dailys').hide();
    $('#Upload').hide();
    if (Util.isEmpty($('#Season').children())) {
      $('#Season').append(this.season.html());
    }
    $('.SeasonTitle').click((event) => {
      return this.season.onMonthClick(event);
    });
    this.season.showMonth(Data.month()); // Show the current month
    $('#ResAdd').hide();
    $('#ResTbl').hide();
    $('#Season').show();
    if (Util.isFunc(onComplete)) {
      onComplete();
    }
  }

  onSeasonPrt() {
    var onComplete;
    onComplete = () => {
      return $('#Buttons').hide('fast', this.doPrint);
    };
    this.onSeasonBtn(onComplete);
  }

  onDailysBtn(onComplete = null) {
    $('#ResAdd').hide();
    $('#ResTbl').hide();
    $('#Master').hide();
    $('#Season').hide();
    $('#Upload').hide();
    if (Util.isEmpty($('#Dailys').children())) {
      $('#Dailys').append(this.dailysHtml());
    }
    $('#Dailys').show();
    if (Util.isFunc(onComplete)) {
      onComplete();
    }
  }

  onDailysPrt() {
    var onComplete;
    onComplete = () => {
      return $('#Buttons').hide('fast', this.doPrint);
    };
    this.onDailysBtn(onComplete);
  }

  onUploadBtn() {
    $('#ResAdd').hide();
    $('#ResTbl').hide();
    $('#Master').hide();
    $('#Season').hide();
    $('#Dailys').hide();
    if (Util.isEmpty($('#Upload').children())) {
      $('#Upload').append(this.upload.html());
    }
    this.upload.bindUploadPaste();
    $('#UploadRes').click(this.upload.onUploadRes);
    $('#UploadCan').click(this.upload.onUploadCan);
    $('#UpdateDay').click(this.upload.onUpdateDay);
    $('#CreateCan').click(this.upload.onCreateCan);
    $('#CustomFix').click(this.upload.onCustomFix);
    $('#Upload').show();
  }

  readyMaster() {
    $('#Master').empty();
    $('#Master').append(this.html());
    this.showMonth(Data.month(), false); // Show the current month
    $('.PrevMonth').click((event) => {
      return this.onMonthClick(event);
    });
    $('.ThisMonth').click((event) => {
      return this.onMonthClick(event);
    });
    $('.NextMonth').click((event) => {
      return this.onMonthClick(event);
    });
    this.query.readyQuery();
    this.input.readyInput();
    this.readyCells();
  }

  readyCells() {
    var doCell;
    doCell = (event) => {
      var $cell, date, resv;
      this.fillInCells(this.dateBeg, this.dateEnd, this.roomId, 'Mine', 'Free');
      $cell = $(event.target);
      $cell = $cell.is('div') ? $cell.parent() : $cell;
      date = $cell.is('td') ? $cell.attr('data-date') : Data.toDateStr($cell.text());
      this.nextId = $cell.is('td') ? $cell.attr('data-roomid') : 0;
      if ((date == null) || (this.nextId == null)) {
        return;
      }
      [this.dateBeg, this.dateEnd, this.dateSel, this.roomId] = this.mouseDates(date);
      if (this.roomId === 0) {
        $('#ResAdd').hide();
        $('#ResTbl').show();
        this.fillInCells(this.dateBeg, this.dateEnd, this.roomId, 'Free', 'Mine');
        this.query.updateBody(this.dateBeg, this.dateEnd, 'arrive');
      } else {
        $('#ResTbl').hide();
        $('#ResAdd').show();
        resv = this.res.getResv(date, this.roomId);
        if (resv == null) {
          this.input.createResv(this.dateBeg, this.dateEnd, this.roomId);
        } else {
          this.input.updateResv(resv);
        }
      }
    };
    $('thead #Day th').click(doCell);
    $('[data-cell="y"]').click(doCell);
    $('[data-cell="y"]').contextmenu(doCell);
  }

  mouseDates(date) {
    this.res.order = 'Decend'; // Will flip to 'Ascend'
    if (this.nextId !== this.roomId) {
      this.dateBeg = date;
      this.dateEnd = date;
    } else if (this.dateBeg <= date && date <= this.dateEnd) {
      if (this.dateSel === 'Beg') {
        this.dateBeg = date;
        this.dateSel = 'End';
      } else if (this.dateSel === 'End') {
        this.dateEnd = date;
        this.dateSel = 'Beg'; // Not needed but good for expression
      }
    } else {
      if (this.dateEnd < date) {
        this.dateEnd = date;
      }
      if (this.dateBeg > date) {
        this.dateBeg = date;
      }
    }
    //Util.log( 'Master.mouseDates()', @dateBeg, date, @dateEnd, @dateSel )
    return [this.dateBeg, this.dateEnd, this.dateSel, this.nextId];
  }

  // Only fill in freeStatus cells return success
  // Also order dates if necessary
  fillInCells(begDate, endDate, roomId, free, fill) {
    var $cell, $cells, beg, end, i, len, next, status;
    if (!((begDate != null) && (endDate != null) && (roomId != null))) {
      return [null, null];
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
      if (roomId === 0) {
        this.dayStatus($cell, fill);
      } else {
        this.cellStatus($cell, fill);
      }
    }
    return [beg, end];
  }

  listenToDays() {
    var doDays;
    doDays = (dayId, day) => {
      if ((dayId != null) && (day != null)) {
        this.res.days[dayId] = day;
        return this.onAlloc(dayId);
      }
    };
    this.res.onDay('add', doDays);
    this.res.onDay('put', doDays);
  }

  listenToResv() {
    var doAdd, doDel;
    doAdd = (resId, resv) => {
      if ((resId != null) && (resv != null) && !this.res.resvs[resId]) {
        return this.res.resvs[resId] = resv;
      }
    };
    doDel = (resId, resv) => {
      if ((resId != null) && (resv != null) && this.res.resvs[resId]) {
        return delete this.res.resvs[resId];
      }
    };
    this.res.onRes('add', doAdd);
    this.res.onRes('put', doAdd);
    this.res.onRes('del', doDel);
  }

  selectToDays() {
    var doDays;
    doDays = (days) => {
      //console.log( 'Master.selectDays()', days )
      return this.allocDays(days);
    };
    this.res.onDays('select', doDays);
    this.store.select('Days');
  }

  allocDays(days) {
    var day, dayId;
    for (dayId in days) {
      if (!hasProp.call(days, dayId)) continue;
      day = days[dayId];
      this.onAlloc(dayId);
    }
  }

  onAlloc(dayId) {
    var date, roomId;
    date = Data.toDate(dayId);
    roomId = Data.roomId(dayId);
    //Util.log( 'Master.onAlloc', date, roomId )
    this.allocCell(roomId, date);
    if (this.season != null) {
      this.season.allocCell(roomId, date);
    }
  }

  cellId(pre, date, roomId) {
    return pre + date + roomId;
  }

  $cell(pre, date, roomId) {
    return $('#' + this.cellId(pre, date, roomId));
  }

  allocCell(roomId, date) {
    var klass;
    klass = this.res.klass(date, roomId);
    this.cellStatus(this.$cell('M', date, roomId), klass);
  }

  fillCell(date, roomId, klass) {
    this.cellStatus(this.$cell('M', date, roomId), klass);
  }

  cellStatus($cell, klass) {
    $cell.removeClass().addClass("room-" + klass);
    $cell.css({
      background: Data.toColor(klass)
    });
  }

  dayStatus($cell, klass) {
    $cell.css({
      background: Data.toColor(klass)
    });
  }

  onMonthClick(event) {
    this.showMonth($(event.target).text());
  }

  showMonth(month, second = true) {
    var $master;
    $master = $('#Master');
    if (month === Data.month() && second) { // Show all Months
      this.removeAllMonthStyles();
      $master.css({
        height: '860px'
      });
      $master.children().show(); // Show selected month
    } else {
      Data.monthIdx = Data.months.indexOf(month);
      $master.children().hide();
      $master.css({
        height: '475px'
      });
      $('#' + month).css({
        left: 0,
        top: 0,
        width: '100%',
        height: '475px',
        fontSize: '14px'
      }).show();
    }
  }

  // Removes expanded style from month and goes back to the month's css selector
  removeAllMonthStyles() {
    var i, len, month, ref, results;
    ref = Data.season;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      month = ref[i];
      results.push($('#' + month).removeAttr('style'));
    }
    return results;
  }

  html() {
    var htm, i, len, month, ref;
    htm = "";
    ref = Data.season;
    for (i = 0, len = ref.length; i < len; i++) {
      month = ref[i];
      htm += `<div id="${month}" class="${month}">${this.roomsHtml(Data.year, month)}</div>`;
    }
    return htm;
  }

  roomsHtml(year, month) {
    var begDay, date, day, endDay, htm, i, j, k, monthIdx, nextMonth, prevMonth, ref, ref1, ref2, ref3, ref4, ref5, ref6, room, roomId, weekday, weekdayIdx;
    monthIdx = Data.months.indexOf(month);
    prevMonth = monthIdx > 4 ? `<span class="PrevMonth">${Data.months[monthIdx - 1]}</span>` : "";
    nextMonth = monthIdx < 9 ? `<span class="NextMonth">${Data.months[monthIdx + 1]}</span>` : "";
    begDay = 1; // if month isnt 'May'     then 1 else 17
    endDay = Data.numDayMonth[monthIdx];
    weekday = new Date();
    weekday.setYear(2000 + year);
    weekday.setMonth(monthIdx);
    weekday.setDay(1);
    weekdayIdx = weekday.getDay();
    htm = `<div   class="MasterTitle">${prevMonth}<span class="ThisMonth">${month}</span>${nextMonth}</div>`;
    htm += "<table class=\"MonthTable\"><thead>";
    htm += "<tr><th></th>";
    for (day = i = ref = begDay, ref1 = endDay; (ref <= ref1 ? i <= ref1 : i >= ref1); day = ref <= ref1 ? ++i : --i) {
      weekday = Data.weekdays[(weekdayIdx + day - 1) % 7].charAt(0);
      htm += `<th>${weekday}</th>`;
    }
    htm += "</tr><tr id=\"Day\"\"><th></th>";
    for (day = j = ref2 = begDay, ref3 = endDay; (ref2 <= ref3 ? j <= ref3 : j >= ref3); day = ref2 <= ref3 ? ++j : --j) {
      date = Data.toDateStr(day, monthIdx);
      htm += `<th id="${this.cellId('M', date, 0)}">${day}</th>`;
    }
    htm += "</tr></thead><tbody>";
    ref4 = this.rooms;
    for (roomId in ref4) {
      if (!hasProp.call(ref4, roomId)) continue;
      room = ref4[roomId];
      htm += `<tr id="${roomId}"><td>${roomId}</td>`;
      for (day = k = ref5 = begDay, ref6 = endDay; (ref5 <= ref6 ? k <= ref6 : k >= ref6); day = ref5 <= ref6 ? ++k : --k) {
        date = Data.toDateStr(day, monthIdx);
        htm += this.createCell(date, roomId);
      }
      htm += "</tr>";
    }
    htm += "</tbody></table>";
    return htm;
  }

  createCell(date, roomId) {
    var bord, dd, htm, klass, last, mi, resv, yy;
    [yy, mi, dd] = Data.yymidd(date);
    resv = this.res.getResv(date, roomId);
    klass = this.res.klass(date, roomId);
    bord = this.border(date, roomId, resv, klass);
    last = (resv != null) && (resv.arrive === date || dd === 1) ? `<div>${resv.last}</div>` : '';
    htm = `<td id="${this.cellId('M', date, roomId)}" class="room-${klass}" style="${bord}" `;
    htm += `data-roomid="${roomId}" data-date="${date}" data-cell="y">${last
    // Lower case roomid
}</td>`;
    return htm;
  }

  addLast(date, roomId, last, status) {
    var $cell, $div;
    if (status === false) {
      ({});
    }
    $cell = this.$cell('M', date, roomId);
    $div = $cell.find('div');
    if (UI.isElem($div)) {
      $div.text(last);
    } else {
      $cell.append(`<div>${last}</div>`);
    }
  }

  updArrival(arrive0, arrive1, roomId, last, status) {
    if (arrive1 > arrive0) {
      this.fillCell(arrive0, roomId, 'Free');
    }
    this.delLast(arrive0, roomId);
    if (arrive1 < arrive0) {
      this.fillCell(arrive1, roomId, status);
    }
    this.addLast(arrive1, roomId, last, status);
  }

  delLast(date, roomId) {
    return this.$cell('M', date, roomId).empty();
  }

  border(date, roomId, resv, klass) {
    var bord, color;
    color = Data.toColor(klass);
    bord = "";
    if (resv != null) {
      bord = `background-color:${color}; border-top: 2px solid black;     border-bottom:2px solid black;   `;
      if (date === resv.arrive) {
        bord += `background-color:${color}; border-left: 2px solid black;    border-right:2px solid ${color}; `;
      } else if (date === resv.stayto) {
        bord += `background-color:${color}; border-right:2px solid black;    border-left:2px  solid ${color}; `;
      } else {
        bord += `background-color:${color}; border-right:2px solid ${color}; border-left:2px  solid ${color}; `;
      }
    } else {
      bord = "border:1px solid black;";
    }
    return bord;
  }

  dailysHtml() {
    var htm;
    htm = "";
    htm += "<h1 class=\"DailysH1\">Daily Activities</h1>";
    htm += "<h2 class=\"DailysH2\">Arrivals</h2>";
    htm += "<h2 class=\"DailysH2\">Departures</h2>";
    return htm;
  }

  // Not Used
  calcSpan(date, roomId, mi, dd, endDay) {
    var da, ds, ma, ms, resv, span, ya, ys;
    span = 1;
    resv = this.res.getResv(date, roomId);
    if (resv != null) {
      ya = 0;
      ma = 0;
      da = 0;
      ys = 0;
      ms = 0;
      ds = 0;
      [ya, ma, da] = Data.yymidd(resv.arrive);
      [ys, ms, ds] = Data.yymidd(resv.stayto);
      if (resv.arrive === date) {
        span = Math.min(resv.nights, endDay - dd + 1);
      } else if (ma !== ms && mi === ms) {
        span = ds;
      } else {
        span = 0;
      }
    }
    return span;
  }

};

export default Master;
