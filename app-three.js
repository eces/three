// Generated by CoffeeScript 1.6.3
(function(){var e,t,n,r,i,s,o,u,a,f,l;n=require("express");u={};u.user=require("./routes/user");u.app=require("./routes/app");u.board=require("./routes/board");u.post=require("./routes/post");u.message=require("./routes/message");u.resource=require("./routes/resource");u.feedback=require("./routes/feedback");u.report=require("./routes/report");r=require("http");i=require("path");s=require("./db.js").pool;l=require("client-sessions");a="@3aosJ3W30CS@OqgKcgi8Ax70lg;XGsH6;WW`Mc_VGP>G:ocbBhNPR;maPL6[[/[";String.prototype.endsWith=function(e){return this.substr(this.length-e.length)===e};String.prototype.startsWith=function(e){return this.substr(0,e.length)===e};e=n();module.exports=e;e.set("port",process.env.PORT||3010);e.use(l({cookieName:"three-session",requestKey:"three",secret:a,duration:864e5,activeDuration:3e5,cookie:{ephemeral:!1,httpOnly:!1,secure:!1}}));e.use(function(e,t,n){var r,i;r=e.three.error;i=e.three.success;delete e.three.error;delete e.three.success;t.locals.error=r!==void 0?r:"";t.locals.message=i!==void 0?i:"";t.locals.signed=e.three.id!==void 0?!0:!1;if(t.locals.signed){t.locals.three={};+(t.locals.three.id=e.three.id);t.locals.three.email=e.three.email;t.locals.three.name=e.three.name}t.locals.moment=require("moment");t.locals.moment.lang("ko");return n()});e.use(n.logger("dev"));e.use(n.bodyParser());e.use(n.methodOverride());e.use(n.cookieParser(a));e.use(n["static"](i.join(__dirname,"public")));e.engine("jade",require("jade").__express);e.use(e.router);o=function(e,t,n){if(e.three.id!==void 0)n();else{e.three.error="로그인 해주세요.";t.redirect("/")}};t=function(e,t,n){var r;r=e.param("userId");if(r===void 0||!isFinite(r))t.send(404);else{n();s.getConnection(function(e,t){if(e){t.release();console.log("[Error] decrementRate: req.path");return}return t.query("UPDATE `users` SET `rateRemains` = `rateRemains`-1\nWHERE `id` = ?",[+r],function(e,n){t.release();if(e)throw e})})}};"development"===e.get("env")&&e.use(n.errorHandler());e.get("/",function(e,t,n){t.locals.uri="/#";return t.render("index.jade")});e.post("/users/subscribe",function(e,t,n){return u.user.subscribe(e,t,n)});e.get("/users/:userId",function(e,t,n){t.locals.uri="/users";return u.user.index(e,t,n)});e.post("/users",function(e,t,n){return u.user.signup(e,t,n)});e.put("/users",o,function(e,t,n){return t.send(503)});e.get("/session",function(e,t,n){if(e.three.id!==void 0)return t.redirect("/users/"+e.three.id);t.locals.uri="/session";return u.user.form(e,t,n)});e.post("/session",function(e,t,n){return u.user.signin(e,t,n)});e.get("/session/destroy",o,function(e,t,n){return u.user.signout(e,t,n)});e.get("/apps",function(e,t,n){t.locals.uri="/apps";return e.three.id?u.app.list(e,t,n):u.app.index(e,t,n)});e.post("/apps",o,function(e,t,n){return u.app.create(e,t,n)});e.get("/apps/:appId",o,function(e,t,n){t.locals.uri="/apps";return u.app.find(e,t,n)});e.put("/apps/:appId",o,function(e,t,n){return u.app.update(e,t,n)});e["delete"]("/apps/:appId",o,function(e,t,n){return u.app["delete"](e,t,n)});e.get("/boards",function(e,t,n){t.locals.uri="/boards";return e.three.id?u.board.list(e,t,n):u.board.index(e,t,n)});e.post("/boards",o,function(e,t,n){return u.board.create(e,t,n)});e.get("/boards/:boardId",o,function(e,t,n){t.locals.uri="/boards";return u.board.find(e,t,n)});e.get("/boards/:boardId/preview",o,function(e,t,n){t.locals.uri="/boards";return u.board.preview(e,t,n)});e.post("/boards/:boardId/posts",o,function(e,t,n){return u.post.create(e,t,n)});e.put("/boards/:boardId",function(e,t,n){return u.board.update(e,t,n)});e.get("/boards/:boardId/posts",o,function(e,t,n){t.locals.uri="/boards";return u.post.list(e,t,n)});e.put("/boards/:boardId/posts/:postId",o,function(e,t,n){return u.post.update(e,t,n)});e["delete"]("/boards/:boardId/posts/:postId",o,function(e,t,n){return u.post["delete"](e,t,n)});e.get("/boards/:boardId/posts/:postId",o,function(e,t,n){t.locals.uri="/boards";return u.post.find(e,t,n)});e["delete"]("/boards/:boardId",o,function(e,t,n){return u.board["delete"](e,t,n)});e.get("/messages",function(e,t,n){t.locals.uri="/messages";return e.three.id?u.message.list(e,t,n):u.message.index(e,t,n)});e.get("/resources",function(e,t,n){t.locals.uri="/resources";return e.three.id?u.resource.list(e,t,n):u.resource.index(e,t,n)});e.get("/feedbacks",function(e,t,n){t.locals.uri="/feedbacks";return e.three.id?u.feedback.list(e,t,n):u.feedback.index(e,t,n)});e.get("/reports",function(e,t,n){t.locals.uri="/reports";return e.three.id?u.report.list(e,t,n):u.report.index(e,t,n)});e.get("/v1/users/:userId/debug",t,function(e,t,n){return t.send(200)});e.get("/v1/users/:userId/apps/:appId/boards/:boardId",t,function(e,t,n){return u.board.view(e,t,n)});e.get("/v1/users/:userId/apps/:appId/boards/:boardId",t,function(e,t,n){});f=r.createServer(e);f.listen(e.get("port"),function(){return console.log("[app.js] Express server listening on port "+e.get("port"))})}).call(this);