
import  Util from './Util.js'
#import Data from './Data'
#import UI   from './UI'

class Test

  constructor:( @stream, @store, @res, @pay, @pict, @book, @resData ) ->

  doTest:() ->
    for     own resId,  res  of @resData
      for   own roomId, room of res
        for own dayId,  day  of res.days['full']
          $cell = $('#R'+roomId+dayId)
          @book.cellBook( $cell )
      cust = res.cust
      @getNamePhoneEmail( cust.first, cust.last, cust.phone, cust.email )
      fn = () => @doGoToPay(res)
      setTimeout( fn, 4000 )
    return

  doGoToPay:( res ) ->
    @book.onGoToPay( null )
    payment = Util.keys(res.payments).sort()[0]
    @popCC( payment.cc, payment.exp, payment.cvc )
    fn = () => @pay.submit( null )
    setTimeout( fn, 4000 )
    return

  getNamesPhoneEmail:( first, last, phone, email ) ->
    [@pay.first,fv] = @pay.isValid('First', first,  true )
    [@pay.last, lv] = @pay.isValid('Last',  last,   true )
    [@pay.phone,pv] = @pay.isValid('Phone', phone,  true )
    [@pay.email,ev] = @pay.isValid('EMail', email,  true )

  popCC:( cc, exp, cvc ) ->
    $('#cc-num').val( cc   )
    $('#cc-exp').val( exp  )
    $('#cc-cvc').val( cvc  )
    return

export default Test