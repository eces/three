pool = require('../db.js').pool
activity = require('../activity.js')
url = require 'url'
fs = require 'fs'

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
    SELECT `messages`.*, `apps`.`platform` as `appPlatform`, `apps`.`name` as `appName`, `apps`.`id` as `appId`
    FROM `messages`, `apps`
    WHERE `messages`.`userId` = ?
      AND `messages`.`appId` = `apps`.`id`
    ORDER BY `messages`.`appId`, `messages`.`identifier` ASC
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
    WHERE `userId` = ?
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
            url: "http://#{req.headers.host}/v1/users/#{req.three.id}/apps/#{aid}/messages/#{r0[0].identifier}"
        else
          res.send 404

exports.update = (req, res, next) ->
  # console.log '>>>>>>>>', req.files
  # console.log req
  uid = +req.three.id
  mid = +req.param 'messageId'
  aid = +req.param 'appId'
  message =
    appId: aid
    userId: uid
    identifier: req.param 'identifier'
    ko: req.param 'ko'
    en: req.param 'en'
    'zh-CN': req.param 'zh-CN'
    'zh-TW': req.param 'zh-TW'
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
  if not /^[a-z0-9\-\_]+$/i.test(message.identifier)
    res.send 200,
      code: 400
      message: '식별자 형식이 잘못되었습니다. URI 규칙을 따릅니다.'
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
        # upload files
  #       { size: 74643,
  # path: '/tmp/8ef9c52abe857867fd0a4e9a819d1876',
  # name: 'edge.png',
  # type: 'image/png',
  # hash: false,
  # lastModifiedDate: Thu Aug 09 2012 20:07:51 GMT-0700 (PDT),
  # _writeStream: 
  #  { path: '/tmp/8ef9c52abe857867fd0a4e9a819d1876',
  #    fd: 13,
  #    writable: false,
  #    flags: 'w',
  #    encoding: 'binary',
  #    mode: 438,
  #    bytesWritten: 74643,
  #    busy: false,
  #    _queue: [],
  #    _open: [Function],
  #    drainable: true },
  # length: [Getter],
  # filename: [Getter],
  # mime: [Getter] }
        for lang in __languages__
          file = req.files[lang]
          console.log 'accepted', file
          if file isnt undefined
            # 1MB limit
            if file.size > 1024*1024
              db.release()
              res.send 200,
                code: 500
                message: '업로드 할 파일이 제한용량(1MB)보다 큽니다.'
              return
            # by accepting any files such as map data and table sheet, could have a huge opportunity.
            # if not file.type.startsWith('image')
            #   db.release()
            #   res.send 200,
            #     code: 500
            #     message: '베타서비스 기간에는 이미지 파일만 업로드 할수 있습니다.'
            #   return
            filename = Date.now()
            path = "./uploads/#{uid}/#{aid}/#{filename}.jpg"
            if not fs.existsSync "./uploads/#{uid}/#{aid}"
              if not fs.existsSync "./uploads/#{uid}"
                fs.mkdirSync "./uploads/#{uid}"
              fs.mkdirSync "./uploads/#{uid}/#{aid}"
            source = file.path
            input = fs.createReadStream source
            output = fs.createWriteStream path
            input.pipe output
            input.on 'end', ->
              fs.unlinkSync source
            # fill urls
            message[lang] = "http://#{req.headers.host}/v1/users/#{uid}/apps/#{aid}/files/#{filename}"
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

exports.sendfile = (req, res, next) ->
  uid = +req.param 'userId'
  if not isFinite(uid)
    res.send 404
    return
  aid = +req.param 'appId'
  filename = req.param('filename') + '.jpg'
  fs.exists "./uploads/#{uid}/#{aid}/#{filename}", (exists) ->
    console.log "./uploads/#{uid}/#{aid}/#{filename}", exists
    if exists
      res.sendfile "./uploads/#{uid}/#{aid}/#{filename}"
    else
      res.send 404


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
        activity.create req, uid, "메시지 ##{mid} 삭제"
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

