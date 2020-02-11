electron      = require('electron')
app           = electron.app
Menu          = electron.Menu
Action        = require(__dirname+'/Action.js')
Menus         = require(__dirname+'/Menus.js')

app.on 'ready', () ->
  action = new Action( app, __dirname )
  menus  = new Menus(  app, process, action )
  menu   = Menu.buildFromTemplate( menus.menus() )
  Menu.setApplicationMenu( menu )
  return

# Quit when all windows are closed.
app.on 'window-all-closed', () ->
  app.quit() if process.platform isnt 'darwin'
  return


