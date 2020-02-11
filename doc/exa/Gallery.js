
TINY.onGalley=function() {
  TINY.ElemById('slideshow').style.display='none';
  TINY.ElemById('wrapper'  ).style.display='block';
  var slideshow=new TINY.slideshow("slideshow");
    slideshow.auto=true;
    slideshow.speed=5;
    slideshow.link="linkhover";
    slideshow.info="information";
    slideshow.thumbs="slider";
    slideshow.left="slideleft";
    slideshow.right="slideright";
    slideshow.scrollSpeed=4;
    slideshow.spacing=5;
    slideshow.active="#fff";
    slideshow.init("slideshow","image","imgprev","imgnext","imglink");
  };
//Util.ready( onGalley );