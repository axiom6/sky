var Guest;

import Stream from '../store/Stream.js';

import Memory from '../store/Memory.js';

import Data from './Data.js';

import Pict from './Pict.js';

import Home from './Home.js';

import Res from './Res.js';

import Pay from './Pay.js';

import Book from './Book.js';

import Test from './Test.js';

Guest = (function() {
  class Guest {
    static init(batch) {
      var book, home, logger, pay, pict, res, store, stream, test;
      logger = {
        subscribe: false,
        publish: false,
        subjects: []
      };
      stream = new Stream(['Select', 'Content', 'Connect', 'Test', 'Plane', 'About', 'Slide', 'Cursor', 'Navigate', 'Settings', 'Submit', 'Toggle', 'Layout'], logger);
      //tore  = new Fire(   stream, "skyline", Data.configSkyline )
      store = new Memory(stream, "skyriver");
      res = new Res(stream, store, 'Guest', batch.Rooms.data);
      pict = new Pict();
      home = new Home(stream, store, res, pict);
      pay = new Pay(stream, store, res, home);
      book = new Book(stream, store, res, pay, pict);
      test = new Test(stream, store, res, pay, pict, book, batch.Resvs.data);
      book.test = test;
      home.ready(book);
    }

    static start() {
      Data.batchRead(Guest.Batch, Guest.init);
    }

  };

  Guest.Batch = {
    Rooms: {
      url: 'data/room.json',
      data: null
    },
    Resvs: {
      url: 'data/res.json',
      data: null
    }
  };

  return Guest;

}).call(this);

Data.local = "./";

Data.hosted = '/';

export default Guest;
