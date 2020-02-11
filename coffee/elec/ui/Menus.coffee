
class Menus

  module.exports = Menus

  constructor:( @app, @process, @action ) ->
    @name    = 'Muse'

  menus:() ->
    all = []
    all.push( @macs() ) if @process.platform is 'darwin'
    all.push( @file() )
    all.push( @edit() )
    all.push( @view() )
    all

  macs:() ->
    { label: @name, submenu:[
      { label:'About '+@name, role:'about' }
      { type:  'separator' }
      { label:'Services',         role:'services', submenu:[] }
      { type:'separator' }
      { label:'Hide '+@name,  role:'hide',       accelerator:'Command+H'       }
      { label:'Hide Others',  role:'hideothers', accelerator:'Command+Shift+H' }
      { label:'Show All',     role:'unhide' }
      { label: 'Quit', accelerator:'Command+Q', click:()=> @app.quit() } ] }

  file:() ->
    { label: 'File', submenu: [
      { label: 'New',   accelerator:'Command+N', click: () => @action.newf()  }
      { label: 'Open',  accelerator:'Command+O', click: () => @action.open()  }
      { label: 'Save',  accelerator:'Command+S', click: () => @action.save()  }
      { type:'separator' }
      { label: 'Preferences', accelerator:'Command+P', click: () => @action.pref() } ] }

  edit:() ->
    { label: 'Edit', submenu: [
      { label: 'Undo',       accelerator:'Command+Z', click: () => @action.undo()  }
      { label: 'Redo',       accelerator:'Command+U', click: () => @action.redo() }
      { type: 'separator' }
      { label: 'Cut',        accelerator:'Command+X', click: () => @action.cut()  }
      { label: 'Copy',       accelerator:'Command+C', click: () => @action.copy() }
      { label: 'Paste',      accelerator:'Command+V', click: () => @action.paste() }
      { label: 'Select All', accelerator:'Command+A', click: () => @action.selectAll() }
      { type: 'separator' }
      { label: 'Find',       accelerator:'Command+F', click: () => @action.find() }
      { label: 'Replace',    accelerator:'Command+R', click: () => @action.replace() }] }

  view:() ->
    { label: 'View', submenu: [
      { label: 'Close',  accelerator:'Command+W', click: () => @action.close() }
      { label: 'Guest',  click: () => @action.view( 'Guest',  '/public/guest.html'  ) }
      { label: 'Owner',  click: () => @action.view( 'Owner',  '/public/index.html'  ) }
      { label: 'Tester', click: () => @action.view( 'Tester', '/public/tester.html' ) }
      { label: 'Toggle Dev Tools', accelerator: 'Command+T', click: () => @action.toggleDevTools() } ] }