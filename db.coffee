mysql = require('mysql')

module.exports.pool = mysql.createPool {
  host: 'localhost'
  user: 'mintpresso'
  password: 'trinity8668'
  database: 'threesome'
  # debug: true
}