# Load dependencies.
file = require 'fs'
uglify = require 'uglify-js'
chainer = require 'chainer'
lager = require 'lager'
log = new lager
require 'colors'

# Get parser and uglifier
jsp = uglify.parser
pro = uglify.uglify

# Export closure to build middleware.
module.exports = (opts, coffee) ->
  live = !!process.env.PRODUCTION
  if typeof opts.uglify is 'undefined' then opts.uglify = live
  if typeof opts.live is 'undefined' then opts.live = !live

  # Compiler interface.
  class Compiler
    # Log compiler notices.
    log: (msg) ->
      if opts.debug
        log.log msg, @jpath

    constructor: (@jpath, @debug) ->
      @log 'compiler invoked'

      # Determine coffeescript path.
      @cpath = @jpath.replace('/javascripts', '/coffeescripts').replace(/\.js$/, '.coffee')
    
    time: (time) -> (new Date time.mtime).getTime()
    
    needsCompile: (cb) ->
      @log 'checking if file needs (re)compiling'
      chain = new chainer
      stats = {}
      errs = {}

      # Wrapper to log result.
      done = (res) =>
        if res then @log 'file needs to be recompiled'
        cb res

      # Create type handler
      typeHandler = (type) =>
        (err, stat) =>
          errs[type] = err
          stats[type] = stat
          chain.next()
      
      # Fetch file info.
      chain.add => file.stat @jpath, typeHandler 'js'
      chain.add => file.stat @cpath, typeHandler 'coffee'

      # Run the tests.
      chain.add =>
        if errs.coffee then return done false
        if errs.js then return done true
        done @time(stats.coffee) > @time(stats.js)
      
      chain.run()

    compile: (cb) ->
      @log '(re)compiling'

      file.readFile @cpath, (err, cdata) =>
        if err then cb()
        else
          try
            # Attempt to compile to Javascript.
            txt = coffee.compile cdata.toString()

            # Ugligfy, if enabled.
            if opts.uglify
              ast = jsp.parse txt
              ast = pro.ast_mangle ast
              ast = pro.ast_squeeze ast
              txt = pro.gen_code ast

            # Save to file. Make new directory, if necessary.
            path = @jpath.substr 0, @jpath.lastIndexOf '/'
            file.stat path, (err, stat) =>
              save = =>
                file.writeFile @jpath, txt, =>
                  @log '(re)compile complete'
                  cb()
              if not err and stat.isDirectory() then save()
              else file.mkdir path, 0666, save
          
          # Continue on errors.
          catch err
            @log 'an error occurred while compiling the file: ' + err.message
            cb()

  # Return the middleware
  (req, res, next) ->
    # Ignore URLs that don't start in /javascripts and end in .js.
    if not (/^\/javascripts/.test(req.url) and /\.js$/.test(req.url)) then return next()

    # Run the compiler.
    compiler = new Compiler opts.path + req.url
    compiler.needsCompile (needs) -> if needs then compiler.compile next else next()