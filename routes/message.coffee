pool = require('../db.js').pool
activity = require('../activity.js')
url = require 'url'

__languages__ = 'ko en zh-CN zh-TW ja'.split(' ')

exports.index = (req, res, next) ->
  res.render 'message/index.jade'

exports.list = (req, res, next) ->
  uid = +req.three.id
  pool.getConnection (cErr, db) ->
    if cErr
      db.release()
      res.send 500
      throw cErr
      return
    db.query """
    SELECT `messages`.*, `apps`.`platform` as `appPlatform`, `apps`.`name` as `appName`
    FROM `messages`, `apps`
    WHERE `messages`.`userId` = ?
      AND `messages`.`appId` = `apps`.`id`
    """, [+uid], (e0, r0) ->
    # AND `messages`.`appId` IN (`apps`.`id`, 0)
      db.release()
      if e0
        res.send 500
        throw e0
        return
      res.render 'message/list.jade',
        messages: r0

exports.create = (req, res, next) ->
  uid = +req.three.id
  message =
    appId: 0
    userId: uid
    identifier: ''
    name: req.param('name')
    defaultLang: 'en'

  pool.getConnection (cErr, db) ->
    if cErr
      db.release()
      res.send 200,
        code: 500
        message: '다시 시도해주세요.'
      throw cErr
      return
    db.query """
    INSERT INTO `messages`
    SET ?, `createdAt` = NOW(), `updatedAt` = NOW()
    """, [message], (e0, r0) ->
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
  uid = +req.three.id
  mid = req.param 'messageId'
  if not isFinite(mid)
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
    """, [uid], (e, r) ->
      if e
        db.release()
        res.send 500
        throw e
        return
      db.query """
      SELECT `messages`.*
      FROM `messages`
      WHERE `messages`.`id` = ?
        AND `messages`.`userId` = ?
      """, [mid, uid], (e0, r0) ->
        db.release()
        if e0
          res.send 500
          throw e0
          return

        if r0.length 
          aid = r0[0].appId
          res.render 'message/item.jade',
            apps: r
            message: r0[0]
            languages: __languages__
            url: "/v1/users/#{req.three.id}/apps/#{aid}/messages/#{r0[0].identifier}"
        else
          res.send 404

exports.update = (req, res, next) ->
  uid = +req.three.id
  mid = +req.param 'messageId'
  aid = +req.param 'appId'
  message =
    appId: aid
    userId: uid
    identifier: req.param 'identifier'
    ko: req.param 'ko'
    en: req.param 'en'
    zh_CN: req.param 'zh_CN'
    zh_TW: req.param 'zh_TW'
    ja: req.param 'ja'
    name: req.param('name')
    defaultLang: req.param('lang')
  if not isFinite(aid)
    res.send 200,
      code: 400
      message: '앱 아이디를 찾을 수 없습니다.'
    return
  if not isFinite(mid)
    res.send 200,
      code: 400
      message: '게시판 아이디를 찾을 수 없습니다.'
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
    SELECT COUNT(*) as `c`, `id`
    FROM `messages`
    WHERE `userId` = ?
      AND `appId` = ?
      AND `identifier` = ?
    """, [uid, aid, message.identifier], (e, r) ->
      if e
        db.release()
        res.send 200,
          code: 500
          message: '다시 시도해주세요.'
        throw e
        return
      if r[0].id is mid or r[0].c is 0
        db.query """
        UPDATE `messages`
        SET ?, `updatedAt` = NOW()
        WHERE `id` = ?
          AND `userId` = ?
        """, [message, mid, uid], (e0, r0) ->
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
      else
        res.send 200,
          code: 400
          message: '해당 앱에 같은 식별자를 가진 중복된 메시지가 있습니다. \n업데이트 취소.'
        return

exports.delete = (req, res, next) ->
  uid = +req.three.id
  mid = +req.param 'messageId'
  if not isFinite(mid)
    res.send 200,
      code: 400
      message: '메시지 아이디를 찾을 수 없습니다.'
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
    DELETE FROM `messages`
    WHERE `id` = ?
      AND `userId` = ?
    """, [mid, uid], (e0, r0) ->
      db.release()
      if e0
        res.send 200,
          code: 500
          message: '다시 시도해주세요.'
        throw e0
        return
      if r0.affectedRows
        activity.create req.three.id, "메시지 ##{mid} 삭제" + activity.getUserString(req)
        res.send 200,
          code: 200,
          timestamp: Date.now()
      else
        res.send 200,
          code: 500
          message: '다시 시도해주세요.'
        throw e0

# API v1
exports.view = (req, res, next) ->
  aid = req.param 'appId'
  uid = req.param 'userId'
  mIdentifier = req.param 'messageIdentifier'
  lang = req.param 'lang'
  
  if not isFinite(aid)
    res.send 400

  pool.getConnection (cErr, db) ->
    if cErr
      db.release()
      res.send 500
      throw cErr
      return
    db.query """
    SELECT * FROM `messages`
    WHERE `appId` = ?
      AND `userId` = ?
      AND `identifier` = ?
    """, [aid, uid, mIdentifier], (e0, r0) ->
      db.release()
      if e0
        res.send 500
        throw e0
        return
      if r0.length
        defaultLang = r0[0].defaultLang
        if lang is undefined
          lang = defaultLang
        body = r0[0][lang]
        # fallback to default language if requested message isn't defined.
        if body is undefined or body.length is 0
          body = r0[0][defaultLang]
        if body.startsWith('http')
          parts = url.parse body
          if parts.protocol isnt null and parts.host isnt null
            res.redirect 302, body
            return
        res.send 200, body
      else
        res.send 404

