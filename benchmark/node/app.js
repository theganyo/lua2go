'use strict'

const connect = require('connect')
const http = require('http')
const debug = require('debug')('test')
const microgateway = require('microgateway-core')
const config = require('config')

const gateway = microgateway(config)

debug('starting gateway')

gateway.start((err, server) => {
  if (err) {
    debug('gateway err %o', err)
    process.exit(1)
  }

  debug('gateway started')
})
