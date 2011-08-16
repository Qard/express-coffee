# Load dependencies.
file = require 'fs'

# Export closure to build middleware.
module.exports = (opts, coffee) ->
  # Ensure some defaults.
  if typeof opts.watch is 'undefined' then opts.watch = ['.coffee']
  else if typeof opts.watch is 'string' then opts.watch = opts.watch.split ','

  # Return the middleware
  (req, res, next) ->
    # Make sure the current URL ends in either .coffee or .js
    if !!~opts.watch.indexOf('.coffee') and !!~req.url.search(/.coffee$/)
      cfile = opts.path + req.url
      jfile = cfile.replace /.coffee$/, '.js'

    else if !!~opts.watch.indexOf('.js') and !!~req.url.search(/.js$/)
      jfile = opts.path + req.url
      cfile = cfile.replace /.js$/, '.coffee'
    
    # These aren't the droids you're looking for.
    else return do next

    # Handle the final serve.
    end = (txt) ->
      res.contentType 'javascript'
      res.header 'Content-Length', txt.length
      res.send txt, 200
    
    # Yup, we have to (re)compile.
    compile = ->
      file.readFile cfile, (err, cdata) ->
        if err then do next
        else
          ctxt = coffee.compile do cdata.toString
          end ctxt
          file.writeFile jfile, ctxt
    
    # Check if the .js file exists.
    file.readFile jfile, (err, jdata) ->
      if err then do compile
      else if not opts.live then end jdata
      else
        # Get mod date of .coffee file.
        file.stat cfile, (err, cstat) ->
          if err then end jdata
          else
            # Get mod date of .js file.
            ctime = (new Date cstat.mtime).getTime()
            file.stat jfile, (err, jstat) ->
              if err then end jdata
              else
                # Compare mod dates.
                jtime = (new Date jstat.mtime).getTime()
                if ctime <= jtime then end jdata
                else do compile