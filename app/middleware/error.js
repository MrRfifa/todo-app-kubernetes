const HttpStatus = require('../utils/HttpStatus')
const winston = require('winston')

module.exports = (err, _req, res, _next) => {
  winston.error(err.message)
  res.status(HttpStatus.InternalServerError).send({ message: 'Something failed' })
}
