
electron      = require('electron')
BrowserWindow = electron.BrowserWindow

class Action

  module.exports = Action

  constructor:( @app, @dirname ) ->
    @views = {}
    @current = 'Main'
    @view( @current, '/coffee/elec/ui/main.html', 240, 200 )

  newf:      () -> @log( 'Action Newf'      )
  open:      () -> @log( 'Action Open'      )
  save:      () -> @log( 'Action Save'      )
  pref:      () -> @log( 'Action Pref'      )
  undo:      () -> @log( 'Action Undo'      )
  redo:      () -> @log( 'Action Redo'      )
  cut:       () -> @log( 'Action Cut'       )
  copy:      () -> @log( 'Action Copy'      )
  paste:     () -> @log( 'Action Paste'     )
  selectAll: () -> @log( 'Action SelectAll' )
  find:      () -> @log( 'Action Find'      )
  replace:   () -> @log( 'Action Replace'   )

  close:() =>
    return if not @current? or not @views[@current]? or @current is 'Main'
    view = @views[@current]
    view.window.close()
    return

  closeView:( view ) =>
    return if not view?
    view.window = null
    delete @views[@current]
    @current = 'Main'
    return

  toggleDevTools:() ->
    return if not @current?
    view = @views[@current]
    if view.devTools
      view.window['webContents'].closeDevTools()
      view.devTools = false
    else
      view.window['webContents'].openDevTools()
      view.devTools = true
    return
    
  log:( str ) ->
    console.log( str )
    return

  createView:() ->
    { window:{}, hasFocus:false, devTools:false }

  view:( name, htm, width=1800, height=1200 ) ->
    url = 'file:///Users/ax/Documents/prj/skyline'
    if not @views[name]
      fontPrefs =  { defaultFontFamily:{standard:"FontAwesome",serif:"FontAwesome",sansSerif:"FontAwesome",monospace:"FontAwesome"} }
      options    = { title:name, width:width, height:height, webPreferences:fontPrefs }
      if name is 'Main'
        options.x = 50
        options.y = 50
        options.frame = false
      viewn = @createView()
      viewn.window = new BrowserWindow( options )
      @views[name] = viewn
      @current     = name
      # Need to toggleDevTools() before loading URL to obtain accurate measuerment - still not working
      @toggleDevTools() if name isnt 'Main'
      viewn.window.loadURL( url + htm )
      viewn.window.on( 'closed', () => @closeView( @views[name] ) )
      viewn.focus = true
      viewn  .window['webContents'].on('did-finish-load', () ->
        viewn.window['webContents'].send('init', name ) )
    return
