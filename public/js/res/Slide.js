var Slide;

import Util from './Util.js';

Slide = class Slide {
  static ElemById(i) {
    return document.getElementById(i);
  }

  static ElemByTag(e, p) {
    var elems;
    p = p != null ? p : document;
    elems = p.getElementsByTagName(e);
    if (elems == null) {
      Util.trace('SlideElemByTag()', e);
    }
    if (elems != null) {
      return elems;
    } else {
      return [document.createElement(e)];
    }
  }

  constructor(name) {
    this.infoSpeed = 10;
    this.imgSpeed = 10;
    this.speed = 10;
    this.thumbOpacity = 70;
    this.navHover = 70;
    this.navOpacity = 25;
    this.scrollSpeed = 5;
    this.letterbox = '#000';
    this.n = name;
    this.c = 0;
    this.a = [];
  }

  init(s, z, b, f, q) {
    var a, g, h, i, j, m, r, ref, u, w;
    s = Slide.ElemById(s);
    m = Slide.ElemByTag('li', s);
    w = 0;
    this.l = m.length;
    this.q = Slide.ElemById(q);
    this.f = Slide.ElemById(z);
    this.r = Slide.ElemById(this.info);
    this.o = parseInt(this.style(z, 'width'));
    if (this.thumbs) {
      u = Slide.ElemById(this.left);
      r = Slide.ElemById(this.right);
      u.onmouseover = new Function('TINY.scroll.init("' + this.thumbs + '",-1,' + this.scrollSpeed + ')');
      u.onmouseout = r.onmouseout = new Function('TINY.scroll.cl("' + this.thumbs + '")');
      r.onmouseover = new Function('TINY.scroll.init("' + this.thumbs + '",1,' + this.scrollSpeed + ')');
      this.p = Slide.ElemById(this.thumbs);
    }
    for (i = j = 0, ref = this.l; (0 <= ref ? j < ref : j > ref); i = 0 <= ref ? ++j : --j) {
      this.a[i] = {};
      h = m[i];
      a = this.a[i];
      a.t = Slide.ElemByTag('h3', h)[0].innerHTML;
      a.d = Slide.ElemByTag('p', h)[0].innerHTML;
      a.l = Slide.ElemByTag('a', h)[0] ? Slide.ElemByTag('a', h)[0].href : '';
      a.p = Slide.ElemByTag('span', h)[0].innerHTML;
      if (this.thumbs) {
        g = Slide.ElemByTag('img', h)[0];
        this.p.appendChild(g);
        w += parseInt(g.offsetWidth);
        if (i !== this.l - 1) {
          g.style.marginRight = this.spacing + 'px';
          w += this.spacing;
        }
        this.p.style.width = w + 'px';
        g.style.opacity = this.thumbOpacity / 100;
        g.style.filter = 'alpha(opacity=' + this.thumbOpacity + ')';
        g.onmouseover = new Function('TINY.alpha.set(this,100,5)');
        g.onmouseout = new Function('TINY.alpha.set(this,' + this.thumbOpacity + ',5)');
        g.onclick = new Function(this.n + '.pr(' + i + ',1)');
      }
    }
    if (b && f) {
      b = Slide.ElemById(b);
      f = Slide.ElemById(f);
      b.style.opacity = f.style.opacity = this.navOpacity / 100;
      b.style.filter = f.style.filter = 'alpha(opacity=' + this.navOpacity + ')';
      b.onmouseover = f.onmouseover = new Function('TINY.alpha.set(this,' + this.navHover + ',5)');
      b.onmouseout = f.onmouseout = new Function('TINY.alpha.set(this,' + this.navOpacity + ',5)');
      b.onclick = new Function(this.n + '.mv(-1,1)');
      f.onclick = new Function(this.n + '.mv(1,1)');
    }
    if (this.auto) {
      return this.is(0, 0);
    } else {
      return this.is(0, 1);
    }
  }

  mv(d, c) {
    var t;
    t = this.c + d;
    t = t < 0 ? this.l - 1 : t > this.l - 1 ? 0 : t;
    this.c = t;
    return this.pr(t, c);
  }

  pr(t, c) {
    clearTimeout(this.lt);
    if (c) {
      clearTimeout(this.at);
    }
    this.c = t;
    return this.is(t, c);
  }

  le(s, c) {
    var l, m, n, w;
    this.f.appendChild(this.i);
    w = this.o - parseInt(this.i.offsetWidth);
    if (w > 0) {
      l = Math.floor(w / 2);
      this.i.style.borderLeft = l + 'px solid ' + this.letterbox;
      this.i.style.borderRight = (w - l) + 'px solid ' + this.letterbox;
    }
    this.alpha.set(this.i, 100, this.imgSpeed);
    n = new Function(this.n + '.nf(' + s + ')');
    this.lt = setTimeout(n, this.imgSpeed * 100);
    if (!c) {
      this.at = setTimeout(new Function(this.n + '.mv(1,0)'), this.speed * 1000);
    }
    if (this.a[s].l !== '') {
      this.q.onclick = new Function('window.location="' + this.a[s].l + '"');
      this.q.onmouseover = new Function('@className="' + this.link + '"');
      this.q.onmouseout = new Function('@className=""');
      this.q.style.cursor = 'pointer';
    } else {
      this.q.onclick = this.q.onmouseover = null;
      this.q.style.cursor = 'default';
    }
    m = Slide.ElemByTag('img', this.f);
    if (m.length > 2) {
      return this.f.removeChild(m[0]);
    }
  }

  is(s, c) {
    var a, i, j, l, ref, results, x;
    if (this.info) {
      this.height.set(this.r, 1, this.infoSpeed / 2, -1);
    }
    i = new Image();
    i.style.opacity = 0;
    i.style.filter = 'alpha(opacity=0)';
    this.i = i;
    i.onload = new Function(this.n + '.le(' + s + ',' + c + ')');
    i.src = this.a[s].p;
    //i.width  = @width
    //i.height = @height
    if (this.thumbs) {
      a = Slide.ElemByTag('img', this.p);
      l = a.length;
      results = [];
      for (x = j = 0, ref = l; (0 <= ref ? j < ref : j > ref); x = 0 <= ref ? ++j : --j) {
        results.push(a[x].style.borderColor = x !== s ? '' : this.active);
      }
      return results;
    }
  }

  nf(s) {
    var h;
    if (this.info) {
      s = this.a[s];
      Slide.ElemByTag('h3', this.r)[0].innerHTML = s.t;
      Slide.ElemByTag('p', this.r)[0].innerHTML = s.d;
      this.r.style.height = 'auto';
      h = parseInt(this.r.offsetHeight);
      this.r.style.height = 0;
      return this.height.set(this.r, h, this.infoSpeed, 0);
    }
  }

  scroll() {
    return {
      init: function(e, d, s) {
        var fn, l, p;
        e = typeof e === 'object' ? e : Slide.ElemById(e);
        p = e.style.left || TINY.style.val(e, 'left');
        e.style.left = p;
        l = d === 1 ? parseInt(e.offsetWidth) - parseInt(e.parentNode.offsetWidth) : 0;
        fn = () => {
          return this.scroll.mv(e, l, d, s);
        };
        return e.si = setInterval(fn, 20);
      },
      mv: function(e, l, d, s) {
        var c, i, n;
        c = parseInt(e.style.left);
        if (c === l) {
          return this.scroll.cl(e);
        } else {
          i = Math.abs(l + c);
          i = i < (typeof s === "function" ? s({
            i: s
          }) : void 0);
          n = c - i * d;
          return e.style.left = n + 'px';
        }
      },
      cl: function(e) {
        e = typeof e === 'object' ? e : Slide.ElemById(e);
        return clearInterval(e.si);
      }
    };
  }

  height() {
    return {
      set: function(e, h, s, d) {
        var fn, hd, ho, oh;
        e = typeof e === 'object' ? e : Slide.ElemById(e);
        oh = e.offsetHeight;
        ho = e.style.height || this.style.val(e, 'height');
        ho = oh - parseInt(ho);
        hd = oh - ho > h ? -1 : 1;
        clearInterval(e.si);
        fn = () => {
          return this.height.tw(e, h, ho, hd, s);
        };
        return e.si = setInterval(fn, 20);
      },
      tw: function(e, h, ho, hd, s) {
        var oh;
        oh = e.offsetHeight - ho;
        if (oh === h) {
          return clearInterval(e.si);
        } else {
          if (oh !== h) {
            return e.style.height = oh + (Math.ceil(Math.abs(h - oh) / s) * hd) + 'px';
          }
        }
      }
    };
  }

  alpha() {
    return {
      set: function(e, a, s) {
        var d, fn, o;
        e = typeof e === 'object' ? e : Slide.ElemById(e);
        o = e.style.opacity || TINY.style.val(e, 'opacity');
        d = a > o * 100 ? 1 : -1;
        e.style.opacity = o;
        clearInterval(e.ai);
        fn = () => {
          return this.alpha.tw(e, a, d, s);
        };
        return e.ai = setInterval(fn, 20);
      },
      tw: function(e, a, d, s) {
        var n, o;
        o = Math.round(e.style.opacity * 100);
        if (o === a) {
          return clearInterval(e.ai);
        } else {
          n = o + Math.ceil(Math.abs(a - o) / s) * d;
          e.style.opacity = n / 100;
          return e.style.filter = 'alpha(opacity=' + n + ')';
        }
      }
    };
  }

  style(e, p) {
    e = typeof e === 'object' ? e : Slide.ElemById(e);
    if (e.currentStyle) {
      return e.currentStyle[p];
    } else {
      return document.defaultView.getComputedStyle(e, null).getPropertyValue(p);
    }
  }

  style2() {
    return {
      val: function(e, p) {
        if (e = typeof e === 'object') {
          e;
        } else {
          Slide.ElemById(e);
        }
        if (e.currentStyle) {
          return e.currentStyle[p];
        } else {
          return document.defaultView.getComputedStyle(e, null).getPropertyValue(p);
        }
      }
    };
  }

};
