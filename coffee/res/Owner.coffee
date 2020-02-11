
import Stream  from'js/store/Stream'
#mport Fire    from 'js/store/Fire'
#mport Memory  from 'js/store/Memory'
import Util    from './Util.js'
#mport Data    from './Data'
import Res     from './Res'
import Master  from './Msster'

class Owner


  @init = () ->

    Util.ready ->
      config   = if  Util.arg is 'skytest' then Data.configSkytest else Data.configSkyline
      stream   = new Stream( [] )
      store    = new Fire(   stream, Util.arg ,config )
      #tore    = new Memory( stream, Util.arg         )
      res      = new Res(    stream, store, 'Owner'   )
      master   = new Master( stream, store, res       )
      master.ready()

Owner.init()

export default Owner