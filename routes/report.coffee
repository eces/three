pool = require('../db.js').pool
activity = require('../activity.js')

exports.index = (req, res, next) ->
  res.render 'report/index.jade'

exports.list = (req, res, next) ->
  uid = +req.three.id
  res.render 'report/list.jade'

# exports.list = (req, res, next) ->
#   user = 
#     id: +req.three.id
#   board = 
#     id: req.param 'boardId'

#   if not isFinite(board.id)
#     res.send 400
#     return

#   pool.getConnection (cErr, db) ->
#     if cErr
#       db.release()
#       res.send 500
#       throw cErr
#       return

#     db.query """
#     SELECT `boards`.*, `apps`.`name` as `appName`, `apps`.`platform` as `appPlatform`
#     FROM `boards`, `apps`
#     WHERE `boards`.`userId` = ? 
#       AND `boards`.`id` = ?
#       AND `boards`.`appId` = `apps`.`id`
#     """, [+user.id, +board.id], (e0, r0) ->
#       db.release()
#       if e0
#         res.send 500
#         throw e0
#         return
#       db.query """
#       SELECT * FROM `posts`
#       WHERE `boardId` = ?
#       ORDER BY `publishAt` DESC
#       """, [+board.id], (e1, r1) ->
#         res.render 'post/index.jade',
#           posts: r1
#           board: r0[0]

# exports.create = (req, res, next) ->
#   post =
#     subject: req.param 'subject'
#     body: ''
#     lang: req.param 'lang'
#     # publishAt: req.param 'publishAt'
#     boardId: req.param 'boardId'

#   if not isFinite(post.boardId)
#     res.send 200,
#       code: 400
#       message: '게시판 아이디를 찾을 수 없습니다.'
#     return

#   pool.getConnection (cErr, db) ->
#     if cErr
#       db.release()
#       res.send 200,
#         code: 500
#         message: '다시 시도해주세요.'
#       throw cErr
#       return
#     db.query """
#     INSERT INTO `posts`
#     SET ?, `createdAt` = NOW(), `updatedAt` = NOW(), `publishAt` = DATE_ADD(NOW(), INTERVAL 24 HOUR)
#     """, [post], (e0, r0) ->
#       db.release()
#       if e0
#         res.send 200,
#           code: 500
#           message: '다시 시도해주세요.'
#         throw e0
#         return
#       res.send 200,
#         code: 200
#         id: r0.insertId

# exports.find = (req, res, next) ->
#   board = 
#     id: +req.param 'boardId'

#   post =
#     id: +req.param 'postId'

#   if not isFinite(board.id) or not isFinite(post.id)
#     res.send 404
#     return

#   pool.getConnection (cErr, db) ->
#     if cErr
#       db.release()
#       res.send 500
#       throw cErr
#       return
#     db.query """
#     SELECT `posts`.*, `boards`.`appId` as `appId`, `boards`.`name` as `boardName`
#     FROM `boards`, `posts`
#     WHERE `boards`.`userId` = ? 
#       AND `boards`.`id` = ?
#       AND `posts`.`boardId` = `boards`.`id`
#       AND `posts`.`id` = ?
#     """, [+req.three.id, +board.id, +post.id], (e0, r0) ->
#       db.release()
#       if e0
#         res.send 500
#         throw e0
#         return

#       if r0.length 
#         aid = r0[0].appId
#         board.name = r0[0].boardName
#         res.render 'post/item.jade',
#           board: board
#           post: r0[0]
#           languages: __languages__
#           url: "/v1/users/#{req.three.id}/apps/#{aid}/boards/#{board.id}?enableItemPreview=true&lang=#{r0[0].lang}"
#       else
#         res.send 404

# exports.update = (req, res, next) ->
#   bid = +req.param 'boardId'
#   pid = +req.param 'postId'
#   post =
#     subject: req.param 'subject'
#     body: req.param 'body'
#     publishAt: req.param 'publishAt'
#     lang: req.param 'lang'
#   if not isFinite(bid)
#     res.send 200,
#       code: 400
#       message: '게시판 아이디를 찾을 수 없습니다.'
#     return
#   if not isFinite(pid)
#     res.send 200,
#       code: 400
#       message: '게시글 아이디를 찾을 수 없습니다.'
#     return
#   pool.getConnection (cErr, db) ->
#     if cErr
#       db.release()
#       res.send 200,
#         code: 500
#         message: '다시 시도해주세요.'
#       throw cErr
#       return
#     db.query """
#     SELECT COUNT(*) as `c`
#     FROM `boards`
#     WHERE `userId` = ?
#       AND `id` = ?
#     """, [+req.three.id, bid], (e, r) ->
#       if e
#         db.release()
#         res.send 200,
#           code: 500
#           message: '다시 시도해주세요.'
#         throw e
#         return
#       if r[0].c
#         db.query """
#         UPDATE `posts`
#         SET ?, `updatedAt` = NOW()
#         WHERE `id` = ?
#           AND `boardId` = ?
#         """, [post, pid, bid], (e0, r0) ->
#           db.release()
#           if e0
#             res.send 200,
#               code: 500
#               message: '다시 시도해주세요.'
#             throw e0
#             return
#           res.send 200,
#             code: 200,
#             timestamp: Date.now()
#       else
#         res.send 403

# exports.delete = (req, res, next) ->
#   bid = +req.param 'boardId'
#   pid = +req.param 'postId'
#   if not isFinite(bid)
#     res.send 200,
#       code: 400
#       message: '게시판 아이디를 찾을 수 없습니다.'
#     return
#   if not isFinite(pid)
#     res.send 200,
#       code: 400
#       message: '게시글 아이디를 찾을 수 없습니다.'
#     return
#   pool.getConnection (cErr, db) ->
#     if cErr
#       db.release()
#       res.send 200,
#         code: 500
#         message: '다시 시도해주세요.'
#       throw cErr
#       return
#     db.query """
#     SELECT COUNT(*) as `c`
#     FROM `boards`
#     WHERE `userId` = ?
#       AND `id` = ?
#     """, [+req.three.id, bid], (e, r) ->
#       if e
#         db.release()
#         res.send 200,
#           code: 500
#           message: '다시 시도해주세요.'
#         throw e
#         return
#       if r[0].c
#         db.query """
#         DELETE FROM `posts`
#         WHERE `id` = ?
#           AND `boardId` = ?
#         """, [pid, bid], (e0, r0) ->
#           db.release()
#           if e0
#             res.send 200,
#               code: 500
#               message: '다시 시도해주세요.'
#             throw e0
#             return
#           if r0.affectedRows
#             activity.create req.three.id, "게시판 ##{bid}, 글 삭제" + activity.getUserString(req)
#             res.send 200,
#               code: 200,
#               timestamp: Date.now()
#           else
#             res.send 200,
#               code: 500
#               message: '다시 시도해주세요.'
#             throw e0
#       else
#         res.send 200,
#           code: 403
#           message: '권한이 없습니다.'
