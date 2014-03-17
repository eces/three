pool = require('../db.js').pool

__views__ = [
  {
    id: 'list-light'
    description: '밝은 디자인 앱에 어울리는 공지사항/리스트형 게시판 테마'
  }
  # {
  #   id: 'list-stable'
  #   description: '안정된 느낌의 공지사항/리스트형 게시판 테마'
  # }
  # {
  #   id: 'list-dark'
  #   description: '어두운 디자인 앱에 어울리는 공지사항/리스트형 게시판 테마'
  # }
  # {
  #   id: 'card-light'
  #   description: '밝은 디자인 앱에 어울리는 이벤트/배너형 게시판 테마'
  # }
]

__languages__ = ["Arabic", "Moroccan Arabic", "Bosnian", "Bulgarian", "Breton", "Catalan", "Welsh", "Czech", "Chuvash", "Danish", "German", "Greek", "English", "English (Australia)", "English (Canada)", "English (England)", "Esperanto", "Spanish", "Estonian", "Basque", "Persian", "Finnish", "Farose", "French (Canada)", "French", "Galician", "Hebrew", "Hindi", "Croatian", "Hungarian", "Armenian", "Bahasa Indonesia", "Icelandic", "Italian", "Japanese", "Georgian", "Korean", "Latvian", "Lithuanian", "Malayalam", "Marathi", "Bahasa Malaysian", "Norwegian", "Nepalese", "Dutch", "Norwegian Nynorsk", "Polish", "Portuguese (Brazil)", "Portuguese", "Romanian", "Russian", "Slovak", "Slovenian", "Albanian", "Swedish", "Thai", "Tagalog (Filipino)", "Turkish", "Tamaziɣt", "Ukrainian", "Uzbek", "Chinese", "Chinese (Traditional)"]

exports.index = (req, res, next) ->
  res.render 'board/index.jade'

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
    SELECT `boards`.*, `apps`.`name` as `appName`, `apps`.`platform` as `appPlatform`
    FROM `boards`, `apps`
    WHERE `boards`.`userId` = ? 
      AND `boards`.`appId` = `apps`.`id`
    """, [user.id], (e0, r0) ->
      db.release()
      if e0
        res.send 500
        throw e0
        return
      res.render 'board/list.jade',
        boards: r0

exports.create = (req, res, next) ->
  board =
    name: req.param 'name'
    viewType: 'list'
    appId: 0
    defaultLang: 'Korean'
    userId: +req.three.id
  if board.name.trim().length is 0
    res.send 200,
      code: 400
      message: '게시판 이름은 1글자 이상이어야 합니다.'
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
    INSERT INTO `boards`
    SET ?, `updatedAt` = NOW()
    """, [board], (e0, r0) ->
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
  board = 
    id: +req.param 'boardId'

  if not isFinite(board.id)
    res.send 404
    return

  pool.getConnection (cErr, db) ->
    if cErr
      db.release()
      res.send 500
      throw cErr
      return
    db.query """
    SELECT * FROM `boards`
    WHERE `id` = ?
    """, [board.id], (e, r) ->
      db.release()
      if r.length
        db.query """
        SELECT `id`, `name`, `identifier` FROM `apps`
        WHERE `userId` = ?
        """, [+req.three.id], (e1, r1) ->
          db.release()
          if e1
            res.send 500
            throw e1
            return
          res.render 'board/item.jade',
            board: r[0]
            apps: r1
            views: __views__
            languages: __languages__
            url: "http://threesomeplace.com/v1/users/#{req.three.id}/apps/#{r[0].appId}/boards/#{board.id}"
      else
        res.send 404

exports.update = (req, res, next) ->
  id = req.param 'boardId'
  if not isFinite(id)
    code: 400
    message: '게시판 아이디를 찾을 수 없습니다.'
    return

  board =
    name: req.param 'name'
    viewType: req.param 'viewType'
    appId: req.param 'appId'
    defaultLang: req.param 'defaultLang'
  if board.name.trim().length is 0
    res.send 200,
      code: 400
      message: '게시판 이름은 1글자 이상이어야 합니다.'
    return
  if not isFinite(board.appId)
    res.send 200,
      code: 400
      message: '앱 아이디를 찾을 수 없습니다.'
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
    WHERE `id` = ?
      AND `userId` = ?
    """, [+board.appId, +req.three.id], (e, r) ->
      if e
        db.release()
        res.send 200,
          code: 500
          message: '다시 시도해주세요.'
        throw e
        return
      if r[0].c is 0
        db.release()
        res.send 200,
          code: 400
          message: '연결할 앱을 찾을 수 없습니다.'
        return
      else
        db.query """
        UPDATE `boards`
        SET ?, `updatedAt` = NOW()
        WHERE `id` = ?
          AND `userId` = ?
        """, [board, +id, +req.three.id], (e0, r0) ->
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


exports.preview = (req, res, next) ->
  user =
    id: +req.three.id
  board = 
    id: +req.param 'boardId'

  pool.getConnection (cErr, db) ->
    if cErr
      db.release()
      res.send 500
      throw cErr
      return
    db.query """
    SELECT `id` as `bid`, `userId` as `uid`, `appId` as `aid` FROM `boards`
    WHERE `boards`.`id` = ?
      AND `boards`.`userId` = ?
    """, [board.id, user.id], (e, r) ->
      db.release()
      if e
        res.send 500
        throw e
        return
      if r.length
        aid = r[0].aid
        uid = r[0].uid
        bid = r[0].bid
        res.render 'board/preview.jade', 
          url: "/v1/users/#{uid}/apps/#{aid}/boards/#{bid}"
      else
        res.send 404

# API v1
exports.view = (req, res, next) ->
  aid = req.param 'appId'
  uid = req.param 'userId'
  bid = req.param 'boardId'
  lang = req.param 'lang'

  # options
  enableItemPreview = if req.param('enableItemPreview') is 'true' then true else false

  pool.getConnection (cErr, db) ->
    if cErr
      db.release()
      res.send 200, '다시 시도해주세요.'
      throw cErr
      return
    db.query """
    SELECT * FROM `boards` WHERE `id` = ?
    """, [bid], (e0, r0) ->
      if e0
        db.release()
        res.send 200, '다시 시도해주세요.'
        throw e0
        return
      if r0.length
        if lang is undefined
          lang = r0[0].defaultLang
        db.query """
        SELECT `posts`.* FROM `posts`
        WHERE `posts`.`boardId` = ?
          AND `lang` = ?
          AND `posts`.`publishAt` < NOW()
        ORDER BY `publishAt` DESC
        """, [bid, lang], (e1, r1) ->
          if e1
            db.release()
            res.send 200, '다시 시도해주세요.'
            throw e1
            return
          db.release()
          theme = ''
          switch r0[0].viewType
            when 'list-light' then theme = 'list-light'
            else
              theme = 'list-light'
          # example for multiple themes
          # theme = 'view'
          res.render 'board/' + theme + '.jade',
            board: r0[0]
            posts: r1
            enableItemPreview: enableItemPreview
      else
        db.release()
        res.send 200, '게시판을 찾을 수 없습니다.'

