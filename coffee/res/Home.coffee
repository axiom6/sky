
import Util    from './Util.js'

class Home

  constructor:( @stream, @store, @res, @pict ) ->
    @isFullScreen = false

  ready:( book ) ->
    @book = book
    $('#HeadRel').append( @headHtml() )
    $('#RoomRel').append( @roomHtml() )
    $('#ViewRel').append( @viewHtml() )
    $('#MakeRes').click( @onMakeRes )
    $('#HomeBtn').click( @onHome    )
    $('#MapDirs').click( () => Util.toPage('rooms/X.html') )
    $('#Contact').click( () => Util.toPage('rooms/Y.html') )

    @pict.createFoto( 'Slides', 'Over' )

    $('#Over' ).click( () => @pict.createFoto(  'Slides', 'Over'  ) )
    $('#Deck' ).click( () => @pict.createFoto(  'Slides', 'Deck'  ) )
    $('#Mtn'  ).click( () => @pict.createFoto(  'Slides', 'Mtn'   ) )
    $('#River').click( () => @pict.createFoto(  'Slides', 'River' ) )
    $('#Walk' ).click( () => @pict.createFoto(  'Slides', 'Walk'  ) )
    $('#Wild' ).click( () => @pict.createFoto(  'Slides', 'Wild'  ) )
    $('#Yard' ).click( () => @pict.createFoto(  'Slides', 'Yard'  ) )
    $('#Vid'  ).click( () => @pict.createVid(   'Slides', 'Vid'   ) )
    return

  headHtml:() ->
    """
    <ul class="Head1">
     <li>Trout Fishing</li>
     <li>Bring your Pet</li>
     <li>Owner On Site</li>
    </ul>
    <ul class="Head2">
      <li>Hiking</li>
      <li>Free Wi-Fi</li>
      <li>Cable TV</li>
    </ul>
    <ul class="Head3">
      <li>Private Parking Spaces</li>
      <li>Kitchens in Every Cabin</li>
      <li>3 Private Spas</li>
    </ul>
    <ul class="Head4">
      <li>Private Barbecue Grills</li>
      <li>All Non-Smoking Cabins</li>
      <li>Wood Burning Fireplaces</li>
    </ul>
    """

  viewHtml:() ->
    htm  = """<div class="HomeSee">Enjoy Everything Skyline Has to Offer</div>"""
    htm += @viewBtns()
    htm += """<div id="Slides"></div>"""
    htm

  roomHtml:() ->
    htm  = """<div class="RoomSee">See Our Cabins</div>"""
    htm += """<ul  class="RoomUL">"""
    for own roomId, room of @res.rooms
      link = """location.href='rooms/#{roomId}.html' """
      htm += """<li class="RoomLI"><button class="btn btn-primary" onclick="#{link}">#{room.name}</button></li>"""
    htm += """</ul>"""
    htm

  viewBtns:() ->
    """<div class="ViewSee">
         <button id="Over"  class="btn btn-primary">Overview</button>
         <button id="Deck"  class="btn btn-primary">Deck</button>
         <button id="Mtn"   class="btn btn-primary">Mountains</button>
         <button id="River" class="btn btn-primary">River</button>
         <button id="Walk"  class="btn btn-primary">Walk</button>
         <button id="Wild"  class="btn btn-primary">Wildlife</button>
         <button id="Yard"  class="btn btn-primary">Yard</button>
         <button id="Vid"  class="btn btn-primary">Video</button>
       </div>
     """

  hideMkt:() ->
    $('#MakeRes').hide()
    $('#HomeBtn').hide()
    $('#MapDirs').hide()
    $('#Contact').hide()
    $('#Caption').hide()
    $('#Head'   ).hide()
    $('#View'   ).hide()

  showMkt:() ->
    $('#MakeRes').show()
    $('#HomeBtn').hide()
    $('#MapDirs').show()
    $('#Contact').show()
    $('#Caption').show()
    $('#Head'   ).show()
    $('#View'   ).show()

  showConfirm:() ->
    $('#MakeRes').hide()
    $('#HomeBtn').show()
    $('#MapDirs').show()
    $('#Contact').show()
    $('#Caption').hide()
    $('#Head'   ).hide()
    $('#View'   ).hide()

  onMakeRes:() =>
    @hideMkt()
    @book.ready()
    return

  onHome:() =>
    @showMkt()
    return

  fullScreen:() ->
    $('#HeadAbs').hide()
    $('#RoomAbs').hide()
    $('#ViewAbs').css( { left:0, top:0, width:'100%', height:'100%' } )
    @pict.createSlideShow( 'Slides', 'Over' )
    @isFullScreen = true
    return

  normScreen:() ->
    $('#ViewAbs').css( { left:'18%', top:'26%', width:'82%', height:'74%' } )
    $('#HeadAbs').show()
    $('#RoomAbs').show()
    @pict.createSlideShow( 'Slides', 'Over' )
    @isFullScreen = false
    return

# htm += """<div class="FootSee">Skyline Cottages Where the River Meets the Mountains</div>"""

export default Home