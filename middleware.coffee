# TODO: Evaluate if file.watchFile() will work better.

# Load dependencies.
file = require 'fs'
uglify = require 'uglify-js'

# Get parser and uglifier
jsp = uglify.parser
pro = uglify.uglify

# Export closure to build middleware.
module.exports = (opts, coffee) ->
  live = !!process.env.PRODUCTION
  if typeof opts.uglify is 'undefined' then opts.uglify = live
  if typeof opts.live is 'undefined' then opts.live = !live

  # determine if a single path was provided or if seperate dest and src paths were provided
  if opts.src and opts.dest
    # do nothing.  We're set
  else if opts.path
    if not opts.src     # assume src is path
      opts.src = opts.path
    if not opts.dest    # assume dest is path
      opts.dest = opts.path
  # Return the middleware
  (req, res, next) ->
    # Make sure the current URL ends in either .coffee or .js
    if  !~req.url.search(/^\/javascripts/) or !~req.url.search(/.js$/) then do next
    else
      jfile = opts.dest + req.url
      cfile = opts.src + req.url.replace(/^\/javascripts/, '/coffeescripts')
      cfile = cfile.replace(/.js$/, '.coffee')
      
      # Handle the final serve.
      end = (txt) ->
        res.contentType 'js'
        res.send txt
      
      # Yup, we have to (re)compile.
      compile = ->
        file.readFile cfile, (err, cdata) ->
          if err then do next
          else
            # Don't crash the server just because a compile failed.
            try
              # Attempt to compile to Javascript.
              ctxt = coffee.compile do cdata.toString

              # Ugligfy, if enabled.
              if opts.uglify
                ast = jsp.parse ctxt
                ast = pro.ast_mangle ast
                ast = pro.ast_squeeze ast
                ctxt = pro.gen_code ast

              # Return result
              end ctxt

              # Save to file. Make new directory, if necessary.
              path = jfile.substr 0, jfile.lastIndexOf '/'
              file.stat path, (err, stat) ->
                save = -> file.writeFile jfile, ctxt
                if not err and stat.isDirectory() then do save
                else file.mkdir path, 0666, save
            
            # Continue on errors.
            catch err then do next
      
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
              ctime = do (new Date cstat.mtime).getTime
              file.stat jfile, (err, jstat) ->
                if err then end jdata
                else
                  # Compare mod dates.
                  jtime = do (new Date jstat.mtime).getTime
                  if ctime <= jtime then end jdata
                  else do compile