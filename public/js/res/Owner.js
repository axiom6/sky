var Owner;

import Stream from 'js/store/Stream';

import Util from './Util.js';

import Res from './Res';

import Master from './Msster';

Owner = class Owner {
  static init() {
    return Util.ready(function() {
      var config, master, res, store, stream;
      config = Util.arg === 'skytest' ? Data.configSkytest : Data.configSkyline;
      stream = new Stream([]);
      store = new Fire(stream, Util.arg, config);
      //tore    = new Memory( stream, Util.arg         )
      res = new Res(stream, store, 'Owner');
      master = new Master(stream, store, res);
      return master.ready();
    });
  }

};

Owner.init();

export default Owner;
