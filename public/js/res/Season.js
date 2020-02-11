var Season;

import Data from './Data';

//mport UI   from './UI'
Season = class Season {
  constructor(stream, store, res) {
    this.onMonthClick = this.onMonthClick.bind(this);
    this.stream = stream;
    this.store = store;
    this.res = res;
    this.rooms = this.res.rooms;
    this.showingMonth = 'Master';
  }

  html() {
    var htm, i, len, month, ref;
    htm = "";
    ref = Data.season;
    for (i = 0, len = ref.length; i < len; i++) {
      month = ref[i];
      htm += `<div id="${month}C" class="${month}C">${this.monthTable(month)}</div>`;
    }
    return htm;
  }

  monthTable(month) {
    var begDate, begDay, col, day, endDay, htm, i, j, k, monthIdx, row, weekday;
    monthIdx = Data.months.indexOf(month);
    begDate = new Date();
    begDate.setYear(2000 + Data.year);
    begDate.setMonth(monthIdx);
    begDate.setDay(1);
    begDay = begDate.getDay() - 1;
    endDay = Data.numDayMonth[monthIdx];
    htm = `<div   class="SeasonTitle">${month}</div>`;
    htm += "<table class=\"SeasonTable\"><thead><tr>";
    for (day = i = 0; i < 7; day = ++i) {
      weekday = Data.weekdays[day];
      htm += `<th>${weekday}</th>`;
    }
    htm += "</tr></thead><tbody>";
    for (row = j = 0; j < 6; row = ++j) {
      htm += "<tr>";
      for (col = k = 0; k < 7; col = ++k) {
        day = this.monthDay(begDay, endDay, row, col);
        htm += `<td><div class="TDC">${this.roomDayHtml(monthIdx, day)}</div></td>`;
      }
      htm += "</tr>";
    }
    return htm += "</tbody></table>";
  }

  roomDayHtml(monthIdx, day) {
    var date, htm, i, last, resv, roomClass, roomId, roomNum;
    htm = "";
    if (day === 0) {
      return htm;
    }
    htm += `<div class="DayC">${day}</div>`;
    for (roomNum = i = 1; i <= 10; roomNum = ++i) {
      roomId = Data.getRoomIdFromNum(roomNum);
      roomClass = "RoomC" + roomId;
      date = Data.toDateStr(day, monthIdx);
      resv = this.res.getResv(date, roomId);
      last = resv != null ? resv.last : "";
      htm += `<div class="${roomClass}">#${roomId} ${last}</div>`;
    }
    return htm;
  }

  monthDay(begDay, endDay, row, col) {
    var day;
    day = row * 7 + col - begDay;
    day = 1 <= day && day <= endDay ? day : 0;
    return day;
  }

  roomDayId(monthIdx, day, roomId) {
    var date;
    date = Data.dateStr(day, monthIdx);
    return this.cellId('S', roomId, date);
  }

  onMonthClick(event) {
    this.showMonth($(event.target).text());
  }

  showMonth(month) {
    var $master;
    $master = $('#Season');
    if (month === this.showingMonth) { // Show all Months
      this.removeAllMonthStyles();
      $('.TDC').hide();
      $master.children().show();
      this.showingMonth = 'Master'; // Show selected month
    } else {
      $master.children().hide();
      $('.TDC').show();
      this.$month(month).css({
        left: 0,
        top: 0,
        width: '100%',
        height: '740px',
        fontSize: '14px',
        border: 'none'
      }).show();
      this.showingMonth = month;
    }
  }

  // Removes expanded style from month and goes back to the month's css selector
  removeAllMonthStyles() {
    var i, len, month, ref, results;
    ref = Data.season;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      month = ref[i];
      results.push(this.$month(month).removeAttr('style'));
    }
    return results;
  }

  $month(month) {
    return $('#' + month + 'C');
  }

  cellId(pre, date, roomId) {
    return pre + date + roomId;
  }

  $cell(pre, date, roomId) {
    return $('#' + this.cellId(pre, date, roomId));
  }

  allocCell(roomId, date) {
    this.cellStatus(this.$cell('S', date, roomId));
  }

  cellStatus($cell, status) {
    $cell.removeClass().addClass("own-" + status);
  }

};

export default Season;
