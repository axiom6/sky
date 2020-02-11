
import Util from './Util.js'

class Slide
   
  @ElemById: (i) ->
    document.getElementById(i)
    
  @ElemByTag:(e,p) ->
    p = if p? then p else document
    elems = p.getElementsByTagName(e)
    Util.trace( 'SlideElemByTag()', e ) if not elems?
    if elems? then elems else [document.createElement(e)]

  constructor:( name ) ->
    @infoSpeed=10
    @imgSpeed=10
    @speed=10
    @thumbOpacity=70
    @navHover=70
    @navOpacity=25
    @scrollSpeed=5
    @letterbox='#000'
    @n=name
    @c=0
    @a=[]
 
  init:(s,z,b,f,q) ->
    s=Slide.ElemById(s)
    m=Slide.ElemByTag('li',s)
    w=0
    @l=m.length
    @q=Slide.ElemById(q)
    @f=Slide.ElemById(z)
    @r=Slide.ElemById(@info)
    @o=parseInt(@style(z,'width'))
    if @thumbs
      u=Slide.ElemById(@left)
      r=Slide.ElemById(@right)
      u.onmouseover=new Function('TINY.scroll.init("'+@thumbs+'",-1,'+@scrollSpeed+')')
      u.onmouseout=r.onmouseout=new Function('TINY.scroll.cl("'+@thumbs+'")')
      r.onmouseover=new Function('TINY.scroll.init("'+@thumbs+'",1,'+@scrollSpeed+')')
      @p=Slide.ElemById(@thumbs)
    
    for i in [0...@l]
      @a[i]={}
      h=m[i]
      a=@a[i]
      a.t=   Slide.ElemByTag('h3',h)[0].innerHTML
      a.d=   Slide.ElemByTag('p',h)[0].innerHTML
      a.l=if Slide.ElemByTag('a',h)[0] then Slide.ElemByTag('a',h)[0].href else ''
      a.p=   Slide.ElemByTag('span',h)[0].innerHTML
      if @thumbs
        g=Slide.ElemByTag('img',h)[0]
        @p.appendChild(g)
        w+=parseInt(g.offsetWidth)
        if i!=@l-1
          g.style.marginRight=@spacing+'px'
          w+=@spacing
        
        @p.style.width=w+'px'
        g.style.opacity=@thumbOpacity/100
        g.style.filter='alpha(opacity='+@thumbOpacity+')'
        g.onmouseover=new Function('TINY.alpha.set(this,100,5)')
        g.onmouseout=new Function('TINY.alpha.set(this,'+@thumbOpacity+',5)')
        g.onclick=new Function(@n+'.pr('+i+',1)')

    
    if b&&f
      b=Slide.ElemById(b)
      f=Slide.ElemById(f)
      b.style.opacity=f.style.opacity=@navOpacity/100
      b.style.filter=f.style.filter='alpha(opacity='+@navOpacity+')'
      b.onmouseover=f.onmouseover=new Function('TINY.alpha.set(this,'+@navHover+',5)')
      b.onmouseout=f.onmouseout=new Function('TINY.alpha.set(this,'+@navOpacity+',5)')
      b.onclick=new Function(@n+'.mv(-1,1)')
      f.onclick=new Function(@n+'.mv(1,1)')

    if @auto then @is(0,0) else @is(0,1)

  mv:(d,c) ->
    t=@c+d
    t = if t<0 then @l-1 else if t> @l-1  then 0 else t
    @c=t
    @pr(t,c)

  pr:(t,c) ->
    clearTimeout(@lt)
    if(c)
      clearTimeout(@at)
    @c=t
    @is(t,c)

  le:(s,c) ->
    @f.appendChild(@i)
    w=@o-parseInt(@i.offsetWidth)
    if w>0
      l=Math.floor(w/2)
      @i.style.borderLeft=l+'px solid '+@letterbox
      @i.style.borderRight=(w-l)+'px solid '+@letterbox

    @alpha.set(@i,100,@imgSpeed)
    n=new Function(@n+'.nf('+s+')')
    @lt=setTimeout(n,@imgSpeed*100)
    if !c
      @at=setTimeout(new Function(@n+'.mv(1,0)'),@speed*1000)
  
    if @a[s].l!=''
      @q.onclick=new Function('window.location="'+@a[s].l+'"')
      @q.onmouseover=new Function('@className="'+@link+'"')
      @q.onmouseout=new Function('@className=""')
      @q.style.cursor='pointer'
    else
      @q.onclick=@q.onmouseover=null
      @q.style.cursor='default'
    
    m=Slide.ElemByTag('img',@f)
    if(m.length>2)
      @f.removeChild(m[0])

  is:(s,c) ->
    if @info
      @height.set(@r,1,@infoSpeed/2,-1)

    i=new Image()
    i.style.opacity=0
    i.style.filter='alpha(opacity=0)'
    @i=i
    i.onload=new Function(@n+'.le('+s+','+c+')')
    i.src=@a[s].p
    #i.width  = @width
    #i.height = @height
    if @thumbs
      a=Slide.ElemByTag('img',@p)
      l=a.length
      for x in [0...l]
        a[x].style.borderColor= if x!=s then '' else @active
          
  nf:(s) ->
    if @info
      s=@a[s]
      Slide.ElemByTag('h3',@r)[0].innerHTML=s.t
      Slide.ElemByTag('p', @r)[0].innerHTML=s.d
      @r.style.height='auto'
      h=parseInt(@r.offsetHeight)
      @r.style.height=0
      @height.set(@r,h,@infoSpeed,0)

  scroll:() ->
    return {
      init: (e, d, s) ->
        e = if typeof e == 'object' then e else Slide.ElemById(e)
        p = e.style.left || TINY.style.val(e, 'left')
        e.style.left = p
        l = if d == 1 then parseInt(e.offsetWidth) - parseInt(e.parentNode.offsetWidth) else 0
        fn = () => @scroll.mv(e, l, d, s)
        e.si = setInterval(fn, 20)
      mv: (e, l, d, s) ->
        c = parseInt(e.style.left)
        if c == l
          @scroll.cl(e)
        else
          i = Math.abs(l + c)
          i = i < s? i: s
          n = c - i * d
          e.style.left = n + 'px'
      cl: (e) ->
        e = if typeof e == 'object' then e else Slide.ElemById(e)
        clearInterval(e.si)
    }

  height: () ->
    return {
      set: (e, h, s, d) ->
        e  = if typeof e == 'object' then e else Slide.ElemById(e)
        oh = e.offsetHeight
        ho = e.style.height || @style.val(e, 'height')
        ho = oh - parseInt(ho)
        hd = if oh - ho > h then -1 else 1
        clearInterval(e.si)
        fn = () => @height.tw(e, h, ho, hd, s)
        e.si = setInterval( fn , 20)

      tw: (e, h, ho, hd, s) ->
        oh = e.offsetHeight - ho
        if(oh == h)
          clearInterval(e.si)
        else
          if(oh != h)
            e.style.height = oh + (Math.ceil(Math.abs(h - oh) / s) * hd) + 'px'
    }

  alpha:() ->
    return {
      set: (e, a, s) ->
        e = if typeof e == 'object' then e else Slide.ElemById(e)
        o = e.style.opacity || TINY.style.val(e, 'opacity')
        d = if a > o * 100 then 1 else -1
        e.style.opacity = o
        clearInterval(e.ai)
        fn = () => @alpha.tw(e, a, d, s)
        e.ai = setInterval( fn, 20)

      tw: (e, a, d, s) ->
        o = Math.round(e.style.opacity * 100)
        if o == a
          clearInterval(e.ai)
        else
          n = o + Math.ceil(Math.abs(a - o) / s) * d
          e.style.opacity = n / 100
          e.style.filter = 'alpha(opacity=' + n + ')'
    }

  style:(e, p) ->
    e = if typeof e == 'object' then e else Slide.ElemById(e)
    if e.currentStyle then e.currentStyle[p] else document.defaultView.getComputedStyle(e, null).getPropertyValue(p)

  style2:() ->
    return {
      val: (e, p) ->
        if e = typeof e == 'object' then e else Slide.ElemById(e)
        if e.currentStyle then e.currentStyle[p] else document.defaultView.getComputedStyle(e, null).getPropertyValue(p)
    }