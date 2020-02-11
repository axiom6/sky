var Query;

import Util from './Util.js';

import Data from './Data';

//mport UI   from './UI'
Query = class Query {
  constructor(stream, store, res, master) {
    this.stream = stream;
    this.store = store;
    this.res = res;
    this.master = master;
  }

  readyQuery() {
    $('#ResTbl').empty();
    $('#ResTbl').append(this.resvHead());
    this.resvSortClick('RHBooked', 'booked');
    this.resvSortClick('RHRoom', 'roomId');
    this.resvSortClick('RHArrive', 'arrive');
    this.resvSortClick('RHStayTo', 'stayto');
    this.resvSortClick('RHName', 'last');
    this.resvSortClick('RHStatus', 'status');
    this.updateBody(this.master.begQuery(), Data.toDateStr(Data.numDaysMonth()), 'arrive');
  }

  updateBody(beg, end, prop) {
    var resvs;
    $('#QArrive').text(Data.toMMDD(beg));
    $('#QStayTo').text(Data.toMMDD(end));
    resvs = [];
    if (prop === 'depart') {
      resvs = this.res.resvArrayDepart();
    }
    if (end != null) {
      resvs = this.res.resvArrayByProp(beg, end, prop);
    } else {
      resvs = this.res.resvArrayByDate(beg);
    }
    return this.resvBody(resvs);
  }

  resvSortClick(id, prop) {
    return $('#' + id).click(() => {
      return this.resvBody(this.res.resvArrayByProp(this.master.dateBeg, this.master.dateEnd, prop));
    });
  }

  resvHead() {
    var htm;
    htm = ""; //"""<div id="QDates"><span id="QArrive"></span><span id="QStayTo"></span></div>"""
    htm += "<table class=\"RTTable\"><thead><tr>";
    htm += "<th id=\"RHArrive\">Arrive</th><th id=\"RHStayTo\">Stay To</th><th id=\"RHNights\">Nights</th><th id=\"RHRoom\"  >Room</th>";
    htm += "<th id=\"RHName\"  >Name</th>  <th id=\"RHGuests\">Guests</th> <th id=\"RHStatus\">Status</th><th id=\"RHBooked\">Booked</th>";
    htm += "<th id=\"RHPrice\" >Price</th> <th id=\"RHTotal\" >Total</th>  <th id=\"RHCommis\">Comm</th>  <th id=\"RHTax\"  >Tax</th>";
    htm += "<th id=\"RHCharge\">Charge</th>";
    htm += "</tr><tr>";
    htm += "<th id=\"QArrive\"></th><th id=\"QStayTo\"></th><th></th><th></th>";
    htm += "<th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th>";
    htm += "</tr></thead><tbody id=\"RTBody\"></tbody></table>";
    return htm;
  }

  resvBody(resvs) {
    var arrive, booked, charge, charges, commis, commiss, htm, i, len, r, stayto, tax, taxes, totals, trClass;
    $('#RTBody').empty();
    htm = "";
    totals = 0;
    taxes = 0;
    commiss = 0;
    charges = 0;
    for (i = 0, len = resvs.length; i < len; i++) {
      r = resvs[i];
      arrive = Data.toMMDD(r.arrive);
      stayto = Data.toMMDD(r.stayto);
      booked = Data.toMMDD(r.booked);
      commis = r.status === 'Booking' || r.status === 'Prepaid' ? '$' + Util.toFixed(r.total * Data.commis) : '';
      tax = Util.toFixed(r.total * Data.tax);
      charge = Util.toFixed(r.total + parseFloat(tax));
      trClass = 'RTOldRow'; // if @res.isNewResv(r) then 'RTNewRow' else 'RTOldRow'
      htm += `<tr class="${trClass}">`;
      htm += `<td class="RTArrive">${arrive}  </td><td class="RTStayto">${stayto}</td><td class="RTNights">${r.nights}</td>`;
      htm += `<td class="RTRoomId">${r.roomId}</td><td class="RTLast"  >${r.last}</td><td class="RTGuests">${r.guests}</td>`;
      htm += `<td class="RTStatus">${r.status}</td><td class="RTBooked">${booked}</td><td class="RTPrice" >$${r.price}</td>`;
      htm += `<td class="RTTotal" >$${r.total}</td><td class="RTCommis">${commis}</td><td class="RTTax"   >$${tax}    </td>`;
      htm += `<td class="RTCharge">$${charge} </td></tr>`;
      totals += r.total;
      taxes += r.total * Data.tax;
      if (r.status === 'Booking' || r.status === 'Prepaid') {
        commiss += r.total * Data.commis;
      }
      charges += r.total + parseFloat(tax);
    }
    taxes = Util.toFixed(taxes);
    commiss = Util.toFixed(commiss);
    charges = Util.toFixed(charges);
    htm += "<tr class=\"'RTTotRow'\">";
    htm += "<td class=\"RTArrive\">          </td><td class=\"RTStayto\">          </td><td class=\"RTNights\">         </td>";
    htm += "<td class=\"RTRoomId\">          </td><td class=\"RTLast\"  >          </td><td class=\"RTGuests\">         </td>";
    htm += "<td class=\"RTStatus\">          </td><td class=\"RTBooked\">          </td><td class=\"RTPrice\" >         </td>";
    htm += `<td class="RTTotal" >$${totals}</td><td class="RTCommis">${commiss}</td><td class="RTTax"   >$${taxes}</td>`;
    htm += `<td class="RTCharge">$${charges}</td></tr>`;
    $('#RTBody').append(htm);
  }

};

export default Query;
