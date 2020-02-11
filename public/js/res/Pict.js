var Pict;

import Util from './Util.js';

Pict = class Pict {
  static page(title, prev, curr, next) {
    var pict;
    pict = new Pict();
    Util.ready(function() {
      pict.roomPageHtml(title, prev, next);
      pict.createFoto('RoomSlides', curr);
    });
  }

  constructor() {
    this.slide = null;
    window.Util = Util;
  }

  roomPageHtml(title, prev, next) {
    var htm, nextPage, prevPage;
    prevPage = ` '${prev}.html' `;
    nextPage = ` '${next}.html' `;
    htm = `<button class="home" onclick="Util.toPage('../index.html');">Home Page</button>\n<button class="prev" onclick="Util.toPage(${prevPage});"    >Prev Cabin</button>\n<span   class="room">${title}</span>\n<button class="next" onclick="Util.toPage(${nextPage});"    >Next Cabin</button>`;
    $('#top').append(htm);
  }

  createFoto(parentId, roomId) {
    var $par, h, id, images, r, url, w;
    $par = $('#' + parentId);
    w = $par.width();
    h = $par.height() - 40;
    r = w > 40 && h > 40 ? w / h : 1.0;
    id = parentId === 'RoomSlides' ? "slideroom" : "slideshow";
    // Util.log( 'Pict.createFoto()', { w:w, h:h, r:r } )
    $par.empty();
    $('.HomeSee').width(w);
    $('.ViewSee').width(w);
    //w *= 0.8 if id is "slideroom"
    url = parentId === 'RoomSlides' ? '../img/img.json' : './img/img.json';
    images = (Img) => {
      var dir, htm, i, len, pic, ref;
      htm = `<div id="${id
      // data-nav="thumbs"
}" class="fotorama"  data-allowfullscreen="true" `;
      htm += `data-minheight="${h}" data-maxheight="${h}" data-ratio="${r}" `;
      htm += `data-minwidth ="${w}" data-maxwidth ="${w}" `;
      htm += ">";
      dir = parentId === 'RoomSlides' ? './' + Img[roomId].dir : Img[roomId].dir;
      ref = Img[roomId]['pics'];
      for (i = 0, len = ref.length; i < len; i++) {
        pic = ref[i];
        htm += this.fotoImg(pic, dir);
      }
      htm += "</div>";
      $par.append(htm);
      return $('#' + `${id}`).fotorama();
    };
    //console.log( 'Pict.createFoto()', { parentId:parentId, roomId:roomId, dir:dir, Img:Img } )
    $.getJSON(url, images);
  }

  // data-width="#{w}"
  fotoImg(pic, dir) {
    var htm;
    // console.log( 'Pict.fotoImg()', { dir:dir, pic:pic } )
    htm = `<img src="${dir}${pic.src}"  `;
    htm += `data-caption="${pic.src
    // if Util.isStr( pic.name )
}" `;
    htm += ">";
    return htm;
  }

  createVid(parentId) {
    var $par, htm;
    $par = $('#' + parentId);
    // w   = Math.max( $par.width(),  640 )
    // h   = Math.max( $par.height(), 640 )
    // r   = if w > 40 and h > 40 then w/h else 1.0
    $par.empty();
    htm = "<div id=\"ViewVid\">\n  <iframe id=\"VideoView\" title=\"Skyline Cottages\" class=\"youtube-player\"\n    src=\"https://www.youtube.com/embed/MsUfGee7kYY\" frameborder=\"0\" allowFullScreen></iframe>\n</div>";
    return $par.append(htm);
  }

};

/*
createFotoVid:( parentId ) ->
$par  = $('#'+parentId)
w     = Math.max( $par.width(),  640 )
h     = Math.max( $par.height(), 640 )
r     = if w > 40 and h > 40 then w/h else 1.0
$par.empty()
htm  = """<div id="slideshow" class="fotorama"  data-allowfullscreen="true" """
htm += """data-maxwidth="#{w}"   data-maxheight="#{h}"   data-ratio="#{r}" """
htm += """data-minwidth="#{640}" data-minheight="#{640}" >"""
htm += """<a href="https://www.youtube.com/embed/MsUfGee7kYY" data-video="true"><img class="SkyVid" src="img/site/youtube.png"></a>"""
 * https://vimeo.com/240855827
htm += """</div>"""
$par.append( htm )  
 */
export default Pict;
