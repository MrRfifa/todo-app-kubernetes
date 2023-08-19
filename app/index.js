const express = require('express')
const winston = require('winston')
const app = express()

require('./startup/logging')()
require('./startup/routes')(app)
require('./startup/db')()
require('./startup/config')()

const port = process.env.APP_PORT || 4000
const server = app.listen(port, () => {
  winston.info(`Listening on port ${port}...`)
})

// If you want to use the server in a test, you can export it like this:
module.exports = app
module.exports = server
