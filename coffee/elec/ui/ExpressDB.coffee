
express = require('express' )

class ExpressDB

  module.export =  ExpressDB

  constructor:( @uri, @db ) ->
    @app  = express()
    @nano = require('nano')(@uri)
    @use  = @nano.db.use( @db )

  routes:() ->
    @app.post(   @db, (req,res) -> @post(req,res) )
    @app.get(    @db, (req,res) -> @get( req,res) )
    @app.put(    @db, (req,res) -> @put( req,res) )
    @app.delete( @db, (req,res) -> @del( req,res) )

  post:( req, res ) ->
    @use.insert req.data, req.table, ( err, body ) ->
      if not err
        res.status(200).send( body )
      else
        res.status(500).send( err )
    return

  get:(  req, res ) ->
    rev = { revs_info: true }
    @use.get req.table, rev, ( err, body ) ->
      if not err
        res.status(200).send( body )
      else
        res.status(500).send( err )
    return

  put:(  req, res ) ->
    rev = { revs_info: true }
    @use.insert req.data, rev, ( err, body ) ->
      if not err
        res.status(200).send( body )
      else
        res.status(500).send( err )
    return

  del:(  req, res ) ->
    @use.destroy req.table, req.rev, ( err, body ) ->
      if not err
        res.status(200).send( body )
      else
        res.status(500).send( err )
    return

###
res.download() 	Prompt a file to be downloaded.
res.end() 	End the response process.
res.json() 	Send a JSON response.
res.jsonp() 	Send a JSON response with JSONP support.
res.redirect() 	Redirect a request.
res.render() 	Render a view template.
res.send() 	Send a response of various types.
res.sendFile() 	Send a file as an octet stream.
res.sendStatus() 	Set the response status code and send its string representation as the response body.
###