pool = require('../db.js').pool
activity = require('../activity.js')
Intl = require('intl')

exports.subscribe = (req, res, next) ->
  e = req.param 'email'
  pool.getConnection (cErr, db) ->
    if cErr
      db.release()
      res.send
        code: 500
        message: '다시 시도해주세요.'
      throw cErr
      return
    db.query """
    INSERT INTO `subscriptions`
    SET `email` = ?, `createdAt` = NOW()
    """, [e], (e, r) ->
      if e
        res.send
          code: 500
          message: '다시 시도해주세요.'
        throw e
        return
      res.send
        code: 200


exports.form = (req, res, next) ->
  res.locals.promoCode = req.param('promo_code')
  res.render 'user/form.jade'

exports.index = (req, res, next) ->
  user = {
    id: +req.param 'userId'
  }

  if req.three.id is undefined or req.three.id isnt user.id
    console.log +req.three.id, user.id
    res.send 404
    return

  pool.getConnection (cErr, db) ->
    if cErr
      db.release()
      res.send 500
      throw cErr
      return

    crypto = require 'crypto'
    sha256 = crypto.createHash('sha256')
    promoCode = sha256.update('trp' + user.id).digest('hex')

    db.query """
    SELECT *, (SELECT COUNT(`id`) FROM `users` WHERE `promo` = ?) as `promoted` FROM `users` WHERE `id` = ?
    """, [promoCode, user.id], (e0, r0) ->
      if e0
        db.release()
        res.send 500
        throw e0
        return
      if r0.length
        # api usage
        # plan info
        
        # style: 'currency'
        # currency: 'KRW'
        db.query """
        SELECT * FROM `activities`
        WHERE `userId` = ?
        ORDER BY `id` DESC
        LIMIT 10
        """, [user.id], (e1, r1) ->
          db.release()
          if e1
            res.send 500
            throw e1
            # return

          f = new Intl.NumberFormat 'en-US',
            style: 'decimal'
            minimumFractionDigits: 0
          r0[0].rateRemainsCurrency = f.format r0[0].rateRemains
          r0[0].rateLimitCurrency = f.format r0[0].rateLimit
          res.render 'user/index.jade', 
            user: r0[0]
            activities: r1
            promoUrl: '/session?promo_code=' + promoCode
          return
      else
        db.release()
        res.send 404
        return

exports.signup = (req, res) ->
  user = {}
  user.email = req.param 'email'
  user.password = req.param 'password'
  user.name = req.param 'name'
  user.companyName = ''
  user.phone = ''
  user.companyPhone = ''
  user.rateRemains = 100*10000
  user.rateLimit = 100*10000
  user.promo = req.param 'promo'

  if user.email.length is 0 or user.password.length is 0 or user.name.length is 0
    res.send 
      code: 400
      message: ''
    return

  crypto = require 'crypto'
  sha256 = crypto.createHash('sha256')
  user.password = sha256.update(user.password).digest('hex')
  
  pool.getConnection (cErr, db) ->
    if cErr
      db.release()
      res.send
        code: 500
        message: '이용자가 많거나 서버 점검중입니다. 문제가 지속될 경우 고객센터로 연락바랍니다.'
      throw cErr 
      return
    db.query """
    SELECT COUNT(*) as `c` FROM `users` WHERE `email` = ?
    """, [user.email], (e0, r0) ->
      if e0
        db.release()
        res.send
          code: 500
          message: '이용자가 많거나 서버 점검중입니다. 문제가 지속될 경우 고객센터로 연락바랍니다.'
        throw e0 
        return
      if r0[0].c
        db.release()
        res.send
          code: 400
          message: '이미 가입된 이메일 주소입니다.'
        return
      else
        db.query """
        INSERT INTO `users` SET ?, `createdAt` = NOW()
        """, user, (err, r1) ->
          db.release()
          throw err if err
          if r1.insertId
            req.three.id = r1.insertId
            req.three.name = user.name
            req.three.email = user.email
            activity.create req, req.three.id, '회원가입을 축하합니다.'
            activity.create req, req.three.id, '로그인됨'
            res.send 
              code: 200
              message: '환영합니다! 가입이 완료되었습니다.'
              id: req.three.id
            return
          else
            res.send 
              code: 500
              message: '다시 시도해주세요. 문제가 지속될 경우 고객센터로 연락바랍니다.'
            return

exports.signin = (req, res) ->
  user = {}
  user.email = req.param 'email'
  user.password = req.param 'password'

  if user.email.length is 0 or user.password.length is 0
    res.send 
      code: 400
      message: ''
    return

  crypto = require 'crypto'
  sha256 = crypto.createHash('sha256')
  user.password = sha256.update(user.password).digest('hex')
  
  pool.getConnection (cErr, db) ->
    if cErr
      db.release()
      res.send
        code: 500
        message: '이용자가 많거나 서버 점검중입니다. 문제가 지속될 경우 고객센터로 연락바랍니다.'
      throw cErr 
      return
    db.query """
    SELECT * FROM `users`
    WHERE `email` = ?
    """, [user.email], (e0, r0) ->
      if e0
        db.release()
        res.send
          code: 500
          message: '이용자가 많거나 서버 점검중입니다. 문제가 지속될 경우 고객센터로 연락바랍니다.'
        throw e0 
        return
      db.release()
      if r0.length
        if r0[0].password is user.password
          req.three.id = r0[0].id
          req.three.name = r0[0].name
          req.three.email = r0[0].email

          activity.create req, req.three.id, '로그인됨'
          res.send 
            code: 200
            id: req.three.id
          return
        else
          # req.three.wrongPassword = 0 if req.three.wrongPassword is undefined
          # req.three.wrongPassword++
          activity.create req, r0[0].id, "로그인 시도, 비밀번호 틀림"
          res.send 
            code: 400
            message: '비밀번호가 틀립니다.'
          return
      else
        res.send 
          code: 400
          message: '가입되지 않은 이름입니다.'
        return

exports.signout = (req, res) ->
  req.three = {}
  res.redirect '/'