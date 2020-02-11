
$  = require('jquery'  )
Rx = require('rxjs/Rx' )

class Stream

  module.exports = Stream # Util.Export( Stream, 'util/Stream' )
  Stream.SubjectNames  = ['Select','Content','Connect','Test','Plane','About','Slide',
                          'Cursor','Navigate','Settings','Submit','Toggle','Layout']

  constructor:( @subjectNames=Stream.SubjectNames ) ->
    @subjects = {}
    for name in @subjectNames
      @subjects[name] = new Rx.Subject()
    @counts = {}

  # Get a subject by name. Create a new one if need with a warning
  getSubject:( name, warn=false ) ->
    if @subjects[name]?
       @subjects[name]
    else
      Util.warn( 'Stream.getSubject() unknown subject so returning new subject for', name ) if warn
      @subjects[name] = new Rx.Subject()
    @subjects[name]

  subscribe:( name, next, onError=@onError, onComplete=@onComplete ) ->
    subject = @getSubject( name, false ) # Many subscribers come before publishers
    subject.subscribe( next, onError, onComplete )
    return

  publish:( name, topic, jQuerySelector=null, eventType=null ) ->
    if not jQuerySelector? or not eventType?
      subject = @getSubject(  name )
      subject.next( topic )
      # Util.log( "Stream.publish()", name, topic )
    else
      @publishEvent( name, topic, jQuerySelector, eventType )
    return

  publishEvent:( name, topic, jQuerySelector, eventType ) ->
    subject  = @getSubject( name )
    element  = @domElement( jQuerySelector )
    return if @notElement( element, name )
    onEvent  = ( event ) =>
      @processEvent(  event )
      object  = if topic? then topic else event.target.value
      subject.next( object )
    element.addEventListener( eventType, onEvent )
    return

  notElement:( element, name ) ->
    status = element? and element.id? and Util.isStr( element.id )
    Util.log( 'Stream.notElement()', name ) if not status
    not status

  unsubscribe:( name ) ->
    subject = @getSubject(  name )
    subject.unsubscribe()
    return

  processEvent:( event ) ->
    event?.stopPropagation()                   # Will need to look into preventDefault
    event?.preventDefault()
    return

  complete:(completeSubject, subjects, onComplete ) ->
    @counts[completeSubject] = {}
    @counts[completeSubject].count = 0
    objects = []
    onNext = (object) =>
      objects.push( object )
      @counts[completeSubject].count++
      if @counts[completeSubject].count is subjects.length
         @counts[completeSubject].count = 0
         if Util.isFunc(onComplete) then onComplete(objects) else @publish( completeSubject, objects )
    for subject in subjects
      @subscribe(  subject, onNext )
    return

  concat:( name, sources, onComplete ) ->
    subs = []
    for source in sources
      sub = @getSubject(source).take(1)
      subs.push( sub )
    Obs = Rx['Observable']
    @subjects[name] = Obs.concat( subs ).take(subs.length)
    #Util.log( 'Stream.concat() subs.length', subs.length )
    onNext = (object) ->
      params = if object.params? then object.params else 'none'
      Util.noop( params )
      #Util.log( 'Stream.concat() next params', params )
    onError = (err) ->
      Util.log( 'Stream.concat() error', err)
    @subscribe( name, onNext, onError, onComplete )
    return

  isJQuery:( $elem ) ->
    $? and $elem? and ( $elem instanceof $ || 'jquery' in Object($elem) )

  isEmpty:( $elem ) ->
    $elem?.length is 0

  domElement:( jQuerySelector ) ->
    if @isJQuery(  jQuerySelector )
       Util.warn("Stream.createRxJQuery() selector #{jQuerySelector.selector} empty" ) if @isEmpty(jQuerySelector)
       jQuerySelector.get(0)
    else if Util.isStr( jQuerySelector )
       $(jQuerySelector).get(0)
    else
       Util.error('Stream.domElement( jqSel )', typeof(jQuerySelector), jQuerySelector, 'jQuerySelector is neither jQuery object nor selector' )
       $().get(0)

  onNext:( object ) -> Util.log(   'Stream.onNext()',     object      )

  onError:( error ) -> Util.error( 'Stream.onError()',    error       )

  onComplete:()     -> Util.dbg(   'Stream.onComplete()', 'Completed' )

  logSubjects:() ->
    for key, obj of @subjects
      Util.log( 'Stream.logSubjects', key )

  drag:( jqSel ) ->

    dragTarget = @createRxJQuery( jqSel )  # Note $jQuery has to be made reative with rxjs-jquery

    # Get the three major events
    mouseup   =  dragTarget.bindAsObservable("mouseup"  ).publish().refCount()
    mousemove = $(document).bindAsObservable("mousemove").publish().refCount()
    mousedown =  dragTarget.bindAsObservable("mousedown").publish().refCount().map( (event) -> # calculate offsets when mouse down
      event.preventDefault()
      left: event['clientX'] - dragTarget.offset().left
      top:  event['clientY'] - dragTarget.offset().top  )

    # Combine mouse down with mouse move until mouse up
    mousedrag = mousedown.selectMany( (offset) ->
      mousemove.map( (pos) ->  # calculate offsets from mouse down to mouse moves
        left: pos.clientX - offset.left
        top:  pos.clientY - offset.top
      ).takeUntil mouseup )

    # Update position subscription =
    mousedrag.subscribe( (pos) -> dragTarget.css( { top:pos.top, left:pos.left } ) )

  ###
  eventTopic:( event ) ->
    topic = 'Down'
    topic = 'Left'  if event.which is 37
    topic = 'Up'    if event.which is 38
    topic = 'Right' if event.which is 39
    topic = 'Down'  if event.which is 40
    topic

  publishEvent1:( name, topic, jQuerySelector, eventType ) ->
    subject      = @getSubject( name )
    element      = @domElement( jQuerySelector )
    return if @notElement( element, name )
    observable   = Rx.Observable.fromEvent( element, eventType ).mapTo( topic )
    mergeSubject = subject.merge( observable )
    mergeSubject.mapTo( topic )
    @resetSubject( name, mergeSubject )
    return
  ###