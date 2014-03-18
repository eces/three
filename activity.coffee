pool = require('./db.js').pool
platform = require 'platform'

exports.getUserString = (req) ->
  client = platform.parse req.headers['user-agent']
  return " (#{req.ip}, #{client.os}, #{client.name})"

exports.create = (uid, message) ->
  pool.getConnection (cErr, db) ->
    if cErr
      db.release()
      throw cErr
      return
    db.query """
    INSERT INTO `activities`
    SET `message` = ?, `userId` = ?, `createdAt` = NOW()
    """, [message, +uid], (e, r) ->
      db.release()
      if e
        throw e
        return