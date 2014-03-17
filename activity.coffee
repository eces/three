pool = require('./db.js').pool

exports.getUserString = (req) ->
  h = req.headers['user-agent']
  if h.indexOf('Windows') isnt -1
    platform = 'Windows'
  else if h.indexOf('Mac OS X') isnt -1
    platform = 'Mac OS X'
  else if h.indexOf('Linux') isnt -1
    platform = 'Linux'
  else
    platform = ''
  if h.indexOf('MSIE') isnt -1
    browser = 'IE'
  else if h.indexOf('Safari') isnt -1
    browser = 'Safari'
  else if h.indexOf('Firefox') isnt -1
    browser = 'Firefox'
  else if h.indexOf('NING') isnt -1
    browser = 'NING'
  else
    browser = ''
  return " (#{req.ip}, #{platform}, #{browser})"

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