require('dotenv').config()

module.exports = () => {
  if (!process.env.FRONTEND_URL) throw new Error('FATAL ERROR: front-end url is not defined.')
  if (!process.env.DB_URL) throw new Error('FATAL ERROR: database url is not defined.')
}
