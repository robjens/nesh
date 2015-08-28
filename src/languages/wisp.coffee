###
Wisp homoiconic Clojure-like to JavaScript transpiler
language component for Nesh, the Node.js enhanced shell.
###

require 'colors'

wisp = require 'wisp'
compiler = require 'wisp/compiler'
log = require '../log'
path = require 'path'
vm = require 'vm'

exports.setup = ({nesh}) ->
    log.debug 'Loading Wisp, Homoiconic JavaScript with Node.js'

    # Set the compile function to convert Wisp -> bare Javascript
    nesh.compile = (data) ->
        compiler.compile data

    # Import the CoffeeScript REPL, which handles individual line commands
    nesh.repl =
      start: (opts) ->
          opts.eval = (code, context, filename, callback) ->
              if code[0] is '(' and code[code.length - 1] is ')'
                  code = code.slice 1, -1

              err = null
              output = null
              try
                  result = compiler.compile code
                  global.exports = module.exports
                  output = vm.runInThisContext(result.code, {filename})
              catch e
                err = e

              # Sometimes this is the only output... in that case just ignore
              if output is 'use strict' then output = undefined

              callback err, output

          repl = require('repl').start opts

    # Set the default welcome message to include the CoffeeScript version
    nesh.defaults.welcome = "Wondereous " + "wisp".cyan  + " REPL"

    # Set the CoffeeScript prompt
    nesh.defaults.prompt = 'wisp> '
    nesh.defaults.useGlobal = true

    # Save history in ~/.wisp_history
    nesh.defaults.historyFile = path.join(nesh.config.home, '.wisp_history')

