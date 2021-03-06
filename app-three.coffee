express = require 'express'
routes = {}

routes.user = require './routes/user'
routes.app = require './routes/app'
routes.board = require './routes/board'
routes.post = require './routes/post'
routes.message = require './routes/message'
routes.resource = require './routes/resource'
routes.feedback = require './routes/feedback'
routes.report = require './routes/report'

http = require 'http'
path = require 'path'

pool = require('./db.js').pool
sessions = require 'client-sessions'

secret = '@3aosJ3W30CS@OqgKcgi8Ax70lg;XGsH6;WW`Mc_VGP>G:ocbBhNPR;maPL6[[/['

String.prototype.endsWith = (suffix) ->
  return (this.substr(this.length - suffix.length) is suffix)

String.prototype.startsWith = (prefix) ->
  return (this.substr(0, prefix.length) is prefix)

app = express()
module.exports = app

app.set 'port', process.env.PORT || 3010
app.enable 'trust proxy'

app.use sessions {
 cookieName: 'three-session'
 requestKey: 'three'
 secret: secret
 duration: 24 * 60 * 60 * 1000
 activeDuration: 1000 * 60 * 5
 cookie: {
   ephemeral: false
   httpOnly: true
   # httpOnly: false
   secure: false
 }
}

app.use (req, res, next) ->
  # from threesomeplace old project
  err = req.three.error
  msg = req.three.success
  delete req.three.error
  delete req.three.success
  res.locals.error = if err isnt undefined then err else ''
  res.locals.message = if msg isnt undefined then msg else ''

  res.locals.signed = if req.three.id isnt undefined then true else false
  if res.locals.signed
    res.locals.three = {}
    +res.locals.three.id = req.three.id
    res.locals.three.email = req.three.email
    res.locals.three.name = req.three.name

  res.locals.moment = require 'moment'
  res.locals.moment.lang 'ko'
  res.locals.dev = if 'development' is app.get('env') then true else false
  res.locals.title = '쓰리썸플레이스 - 지금 당장 필요한 모바일 웹 기술'
  res.locals.host = req.headers.host
  next()

if 'development' is app.get('env')
  app.use express.logger('dev')
  app.use express.errorHandler()
else
  # production
  newrelic = require 'newrelic'
  app.use express.logger('tiny')
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser(secret)
app.use express.static(path.join(__dirname, 'public'))
app.engine 'jade', require('jade').__express
# app.use 'public/js', express.static(path.join(__dirname, 'public/js'))
# app.use 'public/css', express.static(path.join(__dirname, 'public/css'))
app.use app.router

requireSession = (req, res, next) ->
  if req.three.id isnt undefined
    next()
    return
  else
    req.three.error = '로그인 해주세요.'
    res.redirect '/'
    return

decrementRate = (req, res, next) ->
  uid = req.param 'userId'
  if uid is undefined or not isFinite(uid)
    res.send 404
    return
  else
    next()
    pool.getConnection (cErr, db) ->
      if cErr
        db.release()
        console.log '[Error] decrementRate: req.path'
        return
      db.query """
      UPDATE `users` SET `rateRemains` = `rateRemains`-1
      WHERE `id` = ?
      """, [+uid], (e0, r0) ->
        db.release()
        if e0
          throw e0 
          return
    return

app.get '/', (req, res, next) ->
  # if req.three.id isnt undefined
  #   res.redirect '/users/' + req.three.id
  # else
  res.locals.uri = '/#'
  res.render 'index.jade'

# :string
app.post '/users/subscribe', (req, res, next) ->
  routes.user.subscribe req, res, next
# :number
app.get '/users/:userId', (req, res, next) ->
  res.locals.uri = '/users'
  routes.user.index req, res, next

app.post '/users', (req, res, next) ->
  routes.user.signup req, res, next

app.put '/users', requireSession, (req, res, next) ->
  res.send 503


app.get '/session', (req, res, next) ->
  if req.three.id isnt undefined
    res.redirect '/users/' + req.three.id
  else
    res.locals.uri = '/session'
    routes.user.form req, res, next

app.post '/session', (req, res, next) ->
  routes.user.signin req, res, next

app.get '/session/destroy', requireSession, (req, res, next) ->
  routes.user.signout req, res, next

app.get '/apps', (req, res, next) ->
  res.locals.uri = '/apps'
  if req.three.id
    routes.app.list req, res, next
  else
    routes.app.index req, res, next

# app.get '/apps/:appId/images'

app.post '/apps', requireSession, (req, res, next) ->
  routes.app.create req, res, next

app.get '/apps/:appId', requireSession, (req, res, next) ->
  res.locals.uri = '/apps'
  routes.app.find req, res, next

app.put '/apps/:appId', requireSession, (req, res, next) ->
  routes.app.update req, res, next

app.delete '/apps/:appId', requireSession, (req, res, next) ->
  routes.app.delete req, res, next

app.get '/boards', (req, res, next) ->
  res.locals.uri = '/boards'
  if req.three.id
    routes.board.list req, res, next
  else
    routes.board.index req, res, next

app.get '/1', (req, res) ->
  res.render 'board/view.jade'

app.post '/boards', requireSession, (req, res, next) ->
  routes.board.create req, res, next

app.get '/boards/:boardId', requireSession, (req, res, next) ->
  res.locals.uri = '/boards'
  routes.board.find req, res, next

app.get '/boards/:boardId/preview', requireSession, (req, res, next) ->
  res.locals.uri = '/boards'
  routes.board.preview req, res, next

app.post '/boards/:boardId/posts', requireSession, (req, res, next) ->
  routes.post.create req, res, next

app.put '/boards/:boardId', (req, res, next) ->
  routes.board.update req, res, next

app.get '/boards/:boardId/posts', requireSession, (req, res, next) ->
  res.locals.uri = '/boards'
  routes.post.list req, res, next

app.put '/boards/:boardId/posts/:postId', requireSession, (req, res, next) ->
  routes.post.update req, res, next

app.delete '/boards/:boardId/posts/:postId', requireSession, (req, res, next) ->
  routes.post.delete req, res, next

app.get '/boards/:boardId/posts/:postId', requireSession, (req, res, next) ->
  res.locals.uri = '/boards'
  routes.post.find req, res, next

app.delete '/boards/:boardId', requireSession, (req, res, next) ->
  routes.board.delete req, res, next

app.get '/messages', (req, res, next) ->
  res.locals.uri = '/messages'
  if req.three.id
    routes.message.list req, res, next
  else
    routes.message.index req, res, next

app.post '/messages', requireSession, (req, res, next) ->
  routes.message.create req, res, next

app.get '/messages/:messageId', requireSession, (req, res, next) ->
  res.locals.uri = '/messages'
  routes.message.find req, res, next

app.put '/messages/:messageId', requireSession, (req, res, next) ->
  routes.message.update req, res, next

app.delete '/messages/:messageId', requireSession, (req, res, next) ->
  routes.message.delete req, res, next

app.get '/resources', (req, res, next) ->
  res.locals.uri = '/resources'
  if req.three.id
    routes.resource.list req, res, next
  else
    routes.resource.index req, res, next

app.get '/feedbacks', (req, res, next) ->
  res.locals.uri = '/feedbacks'
  if req.three.id
    routes.feedback.list req, res, next
  else
    routes.feedback.index req, res, next

app.get '/reports', (req, res, next) ->
  res.locals.uri = '/reports'
  if req.three.id
    routes.report.list req, res, next
  else
    routes.report.index req, res, next

app.get '/support', (req, res, next) ->
  res.locals.uri = '/support'
  res.render 'support/index.jade'

# app.get '/messages', requireSession, (req, res, next) ->
#   res.locals.uri = '/messages'
#   routes.message.list req, res, next

app.get '/docs', (req, res) ->
  res.locals.uri = '/docs'
  res.render 'document/index.jade'
  # res.redirect 302, 'https://ghost.org/about'

__titles__ =
  '/docs': '개발자 문서'
  '/docs/overview/how-to-use': '개발자 문서 > 살펴보기 > 가격 정책 및 약관 '
  '/docs/overview/use-case': '개발자 문서 > 살펴보기 > 가격 정책 및 약관'
  '/docs/overview/security': '개발자 문서 > 살펴보기 > 보안'

app.get '/docs/:category/:title', (req, res) ->
  title = req.param 'title'
  category = req.param 'category'
  if not /^[a-z]+$/i.test(category) or not /^[a-z0-9\-\_]+$/i.test(title)
    res.render 'document/404.jade'
    return

  res.locals.uri = '/docs/' + category + '/' + title
  res.locals.title = if __titles__[res.locals.uri] isnt undefined then __titles__[res.locals.uri] else __titles__['/docs']
  res.render 'document/' + category + '/' + title + '.jade', (err, html) ->
    if err
      res.render 'document/404.jade'
      throw err if res.locals.dev
    else
      res.send html


# API v1
app.get '/v1/users/:userId/debug', decrementRate, (req, res, next) ->
  res.send 200
app.get '/v1/users/:userId/apps/:appId/boards/:boardId', decrementRate, (req, res, next) ->
  routes.board.view req, res, next
app.get '/v1/users/:userId/apps/:appId/messages/:messageIdentifier.:extension', decrementRate, (req, res, next) ->
  routes.message.view req, res, next
app.get '/v1/users/:userId/apps/:appId/messages/:messageIdentifier', decrementRate, (req, res, next) ->
  routes.message.view req, res, next
app.get '/v1/users/:userId/apps/:appId/files/:filename.:extension', decrementRate, (req, res, next) ->
  routes.message.sendfile req, res, next
app.get '/v1/users/:userId/apps/:appId/files/:filename', decrementRate, (req, res, next) ->
  routes.message.sendfile req, res, next

server = http.createServer(app)
server.listen app.get('port'), () ->
  console.log('[app.js] Express server listening on port ' + app.get('port'))
