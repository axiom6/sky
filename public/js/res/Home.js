var Home,
  hasProp = {}.hasOwnProperty;

import Util from './Util.js';

Home = class Home {
  constructor(stream, store, res, pict) {
    this.onMakeRes = this.onMakeRes.bind(this);
    this.onHome = this.onHome.bind(this);
    this.stream = stream;
    this.store = store;
    this.res = res;
    this.pict = pict;
    this.isFullScreen = false;
  }

  ready(book) {
    this.book = book;
    $('#HeadRel').append(this.headHtml());
    $('#RoomRel').append(this.roomHtml());
    $('#ViewRel').append(this.viewHtml());
    $('#MakeRes').click(this.onMakeRes);
    $('#HomeBtn').click(this.onHome);
    $('#MapDirs').click(() => {
      return Util.toPage('rooms/X.html');
    });
    $('#Contact').click(() => {
      return Util.toPage('rooms/Y.html');
    });
    this.pict.createFoto('Slides', 'Over');
    $('#Over').click(() => {
      return this.pict.createFoto('Slides', 'Over');
    });
    $('#Deck').click(() => {
      return this.pict.createFoto('Slides', 'Deck');
    });
    $('#Mtn').click(() => {
      return this.pict.createFoto('Slides', 'Mtn');
    });
    $('#River').click(() => {
      return this.pict.createFoto('Slides', 'River');
    });
    $('#Walk').click(() => {
      return this.pict.createFoto('Slides', 'Walk');
    });
    $('#Wild').click(() => {
      return this.pict.createFoto('Slides', 'Wild');
    });
    $('#Yard').click(() => {
      return this.pict.createFoto('Slides', 'Yard');
    });
    $('#Vid').click(() => {
      return this.pict.createVid('Slides', 'Vid');
    });
  }

  headHtml() {
    return "<ul class=\"Head1\">\n <li>Trout Fishing</li>\n <li>Bring your Pet</li>\n <li>Owner On Site</li>\n</ul>\n<ul class=\"Head2\">\n  <li>Hiking</li>\n  <li>Free Wi-Fi</li>\n  <li>Cable TV</li>\n</ul>\n<ul class=\"Head3\">\n  <li>Private Parking Spaces</li>\n  <li>Kitchens in Every Cabin</li>\n  <li>3 Private Spas</li>\n</ul>\n<ul class=\"Head4\">\n  <li>Private Barbecue Grills</li>\n  <li>All Non-Smoking Cabins</li>\n  <li>Wood Burning Fireplaces</li>\n</ul>";
  }

  viewHtml() {
    var htm;
    htm = "<div class=\"HomeSee\">Enjoy Everything Skyline Has to Offer</div>";
    htm += this.viewBtns();
    htm += "<div id=\"Slides\"></div>";
    return htm;
  }

  roomHtml() {
    var htm, link, ref, room, roomId;
    htm = "<div class=\"RoomSee\">See Our Cabins</div>";
    htm += "<ul  class=\"RoomUL\">";
    ref = this.res.rooms;
    for (roomId in ref) {
      if (!hasProp.call(ref, roomId)) continue;
      room = ref[roomId];
      link = `location.href='rooms/${roomId}.html' `;
      htm += `<li class="RoomLI"><button class="btn btn-primary" onclick="${link}">${room.name}</button></li>`;
    }
    htm += "</ul>";
    return htm;
  }

  viewBtns() {
    return "<div class=\"ViewSee\">\n  <button id=\"Over\"  class=\"btn btn-primary\">Overview</button>\n  <button id=\"Deck\"  class=\"btn btn-primary\">Deck</button>\n  <button id=\"Mtn\"   class=\"btn btn-primary\">Mountains</button>\n  <button id=\"River\" class=\"btn btn-primary\">River</button>\n  <button id=\"Walk\"  class=\"btn btn-primary\">Walk</button>\n  <button id=\"Wild\"  class=\"btn btn-primary\">Wildlife</button>\n  <button id=\"Yard\"  class=\"btn btn-primary\">Yard</button>\n  <button id=\"Vid\"  class=\"btn btn-primary\">Video</button>\n</div>";
  }

  hideMkt() {
    $('#MakeRes').hide();
    $('#HomeBtn').hide();
    $('#MapDirs').hide();
    $('#Contact').hide();
    $('#Caption').hide();
    $('#Head').hide();
    return $('#View').hide();
  }

  showMkt() {
    $('#MakeRes').show();
    $('#HomeBtn').hide();
    $('#MapDirs').show();
    $('#Contact').show();
    $('#Caption').show();
    $('#Head').show();
    return $('#View').show();
  }

  showConfirm() {
    $('#MakeRes').hide();
    $('#HomeBtn').show();
    $('#MapDirs').show();
    $('#Contact').show();
    $('#Caption').hide();
    $('#Head').hide();
    return $('#View').hide();
  }

  onMakeRes() {
    this.hideMkt();
    this.book.ready();
  }

  onHome() {
    this.showMkt();
  }

  fullScreen() {
    $('#HeadAbs').hide();
    $('#RoomAbs').hide();
    $('#ViewAbs').css({
      left: 0,
      top: 0,
      width: '100%',
      height: '100%'
    });
    this.pict.createSlideShow('Slides', 'Over');
    this.isFullScreen = true;
  }

  normScreen() {
    $('#ViewAbs').css({
      left: '18%',
      top: '26%',
      width: '82%',
      height: '74%'
    });
    $('#HeadAbs').show();
    $('#RoomAbs').show();
    this.pict.createSlideShow('Slides', 'Over');
    this.isFullScreen = false;
  }

};

// htm += """<div class="FootSee">Skyline Cottages Where the River Meets the Mountains</div>"""
export default Home;
