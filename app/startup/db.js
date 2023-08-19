const winston = require('winston')
const mongoose = require('mongoose')

module.exports = () => {
  // Set up MongoDB connection
  mongoose
    .connect(process.env.DB_URL, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    })
    .then(() => winston.info('Connected Successfully To The Database.'))
    .catch((err) => {
      throw new Error(err.message)
    })
}
