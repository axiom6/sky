  # Requires that @res.resvs to loaded
  readyCells:() =>
    doCell = (event) =>

      $cell    = $(event.target)
      status   = $cell.attr('data-status' )
      #resId   = $cell.attr('data-res'    )
      date     = $cell.attr('data-date'   )

      @fillInCells( @dateBeg, @dateEnd, @roomId, 'mine', 'free' )
      if      @resMode is 'Table'
        resvs = @res.resvRange(  date )
        @onResvTable( resvs )
      else if @resMode is 'Input'
        @roomId  = $cell.attr('data-roomId' )
        [@dateBeg,@dateEnd] = @mouseDates( date )
        if @fillInCells(     @dateBeg, @dateEnd, @roomId, 'free', 'mine' )
          @input.createResv( @dateBeg, @dateEnd, @roomId )
        else
          resv = @res.getResv( date, @roomId )
          if resv?
            resv.action = 'put'
            @input.populateResv( resv )
          else
            Util.error( 'Master.doCell() resv undefined for', { data:date, roomId:roomId } )
      return

    $('[data-cell="y"]').click(       doCell )
    $('[data-cell="y"]').contextmenu( doCell )
    return