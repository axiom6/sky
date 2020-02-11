
class Cust

  module.exports = Cust
  Cust.Data      = require( 'data/Cust.json' )

  constructor:( @stream, @store, @Data ) ->
    @first  = ""
    @last   = ""
    @phone  = ""
    @email  = ""
    @source = ""



  add:( id, cust ) -> @store.add( 'Cust', id, cust )
  get:( id       ) -> @store.get( 'Cust', id       )
  put:( id, cust ) -> @store.put( 'Cust', id, cust )
  del:( id       ) -> @store.del( 'Cust', id       )
