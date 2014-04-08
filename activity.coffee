pool = require('./db.js').pool
platform = require 'platform'

exports.create = (req, uid, message) ->
  pool.getConnection (cErr, db) ->
    if cErr
      db.release()
      throw cErr
      return
    activity = {}
    activity.message = message
    activity.userId = uid

    client = platform.parse req.headers['user-agent']
    activity.ip = req.ip
    activity.os = client.os
    activity.name = client.name

    db.query """
    INSERT INTO `activities`
    SET ?, `createdAt` = NOW()
    """, [activity], (e, r) ->
      db.release()
      if e
        throw e
        return