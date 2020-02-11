
import Util from './Util.js'

class Pict

  @page:( title, prev, curr, next ) ->
    pict = new Pict()
    Util.ready () ->
      pict.roomPageHtml( title, prev, next )
      pict.createFoto( 'RoomSlides', curr )
      return
    return

  constructor:() ->
    @slide = null
    window.Util = Util

  roomPageHtml:( title, prev, next ) ->
    prevPage = """ '#{prev}.html' """
    nextPage = """ '#{next}.html' """
    htm = """
        <button class="home" onclick="Util.toPage('../index.html');">Home Page</button>
        <button class="prev" onclick="Util.toPage(#{prevPage});"    >Prev Cabin</button>
        <span   class="room">#{title}</span>
        <button class="next" onclick="Util.toPage(#{nextPage});"    >Next Cabin</button>
    """
    $('#top').append( htm   )
    return

  createFoto:( parentId, roomId ) ->
    $par  = $('#'+parentId)
    w     = $par.width()
    h     = $par.height() - 40
    r     = if w > 40 and h > 40 then w/h else 1.0
    id    = if parentId is 'RoomSlides' then "slideroom" else "slideshow"
    # Util.log( 'Pict.createFoto()', { w:w, h:h, r:r } )
    $par.empty()
    $('.HomeSee').width( w )
    $('.ViewSee').width( w )
    #w *= 0.8 if id is "slideroom"
    url = if parentId is 'RoomSlides' then '../img/img.json'  else './img/img.json'

    images = (Img) =>
      htm  = """<div id="#{id}" class="fotorama"  data-allowfullscreen="true" """ # data-nav="thumbs"
      htm += """data-minheight="#{h}" data-maxheight="#{h}" data-ratio="#{r}" """
      htm += """data-minwidth ="#{w}" data-maxwidth ="#{w}" """
      htm += """>"""
      dir = if parentId is 'RoomSlides' then './' + Img[roomId].dir else Img[roomId].dir
      for pic  in  Img[roomId]['pics']
        htm += @fotoImg( pic, dir )
      htm += """</div>"""
      $par.append( htm )
      $('#'+"#{id}").fotorama()
      #console.log( 'Pict.createFoto()', { parentId:parentId, roomId:roomId, dir:dir, Img:Img } )

    $.getJSON( url, images )
    return

  # data-width="#{w}"
  fotoImg:( pic, dir ) ->
    # console.log( 'Pict.fotoImg()', { dir:dir, pic:pic } )
    htm  = """<img src="#{dir}#{pic.src}"  """
    htm += """data-caption="#{pic.src}" """ # if Util.isStr( pic.name )
    htm += """>"""
    htm

  createVid:( parentId ) ->
    $par  = $('#'+parentId)
    # w   = Math.max( $par.width(),  640 )
    # h   = Math.max( $par.height(), 640 )
    # r   = if w > 40 and h > 40 then w/h else 1.0
    $par.empty()
    htm   = """<div id="ViewVid">
                 <iframe id="VideoView" title="Skyline Cottages" class="youtube-player"
                   src="https://www.youtube.com/embed/MsUfGee7kYY" frameborder="0" allowFullScreen></iframe>
               </div>"""
    $par.append( htm )

  ###
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
    # https://vimeo.com/240855827
    htm += """</div>"""
    $par.append( htm )  
  ###

export default Pict