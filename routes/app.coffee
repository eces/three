pool = require('../db.js').pool

exports.index = (req, res, next) ->
  res.render 'app/index.jade'

exports.list = (req, res, next) ->
  user = 
    id: +req.three.id
  pool.getConnection (cErr, db) ->
    if cErr
      db.release()
      res.send 500
      throw cErr
      return

    db.query """
    SELECT * FROM `apps` WHERE `userId` = ?
    ORDER BY `updatedAt` DESC, `identifier` ASC
    """, [user.id], (e0, r0) ->
      db.release()
      if e0
        res.send 500
        throw e0
        return
      res.render 'app/list.jade',
        apps: r0

exports.create = (req, res, next) ->
  app =
    name: req.param 'name'
    identifier: ''
    iconUrl: ''
    userId: +req.three.id
    platform: ''
  if app.name.trim().length is 0
    res.send 200,
      code: 400
      message: '앱 이름은 1글자 이상이어야 합니다.'
    return
  pool.getConnection (cErr, db) ->
    if cErr
      db.release()
      res.send 200,
        code: 500
        message: '다시 시도해주세요.'
      throw cErr
      return
    db.query """
    INSERT INTO `apps`
    SET ?, `updatedAt` = NOW()
    """, [app], (e0, r0) ->
      db.release()
      if e0
        res.send 200,
          code: 500
          message: '다시 시도해주세요.'
        throw e0
        return
      res.send 200,
        code: 200
        id: r0.insertId

exports.find = (req, res, next) ->
  app = 
    id: +req.param 'appId'

  if not isFinite(app.id)
    res.send 404
    return

  pool.getConnection (cErr, db) ->
    if cErr
      db.release()
      res.send 500
      throw cErr
      return
    db.query """
    SELECT * FROM `apps`
    WHERE `id` = ?
    """, [app.id], (e, r) ->
      db.release()
      if r.length
        res.render 'app/item.jade',
          app: r[0]
      else
        res.send 404

exports.update = (req, res, next) ->
  id = req.param 'appId'
  if not isFinite(id)
    code: 400
    message: '앱 아이디를 찾을 수 없습니다.'
    return

  app =
    name: req.param 'name'
    identifier: req.param 'identifier'
    iconUrl: ''
    platform: req.param 'platform'
  if app.name.trim().length is 0
    res.send 200,
      code: 400
      message: '앱 이름은 1글자 이상이어야 합니다.'
    return
  pool.getConnection (cErr, db) ->
    if cErr
      db.release()
      res.send 200,
        code: 500
        message: '다시 시도해주세요.'
      throw cErr
      return

    db.query """
    SELECT COUNT(*) as `c` FROM `apps`
    WHERE `identifier` = ?
      AND `platform` = ?
      AND `userId` = ?
      AND `id` != ?
    """, [app.identifier, app.platform, +req.three.id, +id], (e, r) ->
      if e
        db.release()
        res.send 200,
          code: 500
          message: '다시 시도해주세요.'
        throw e
        return
      if r[0].c
        db.release()
        res.send 200,
          code: 400
          message: '앱 식별자가 중복됩니다.'
        return
      else
        db.query """
        UPDATE `apps`
        SET ?, `updatedAt` = NOW()
        WHERE `id` = ?
          AND `userId` = ?
        """, [app, +id, +req.three.id], (e0, r0) ->
          db.release()
          if e0
            res.send 200,
              code: 500
              message: '다시 시도해주세요.'
            throw e0
            return
          res.send 200,
            code: 200,
            timestamp: Date.now()
exports.delete = (req, res, next) ->
  res.send 501