// Generated by CoffeeScript 1.6.3
(function(){var e,t,n;t=require("../db.js").pool;e=require("../activity.js");n="ko en zh-CN zh-TW ja".split(" ");exports.list=function(e,n,r){var i,s;s={id:+e.three.id};i={id:e.param("boardId")};if(!isFinite(i.id)){n.send(400);return}return t.getConnection(function(e,t){if(e){t.release();n.send(500);throw e}return t.query("SELECT `boards`.*, `apps`.`name` as `appName`, `apps`.`platform` as `appPlatform`\nFROM `boards`, `apps`\nWHERE `boards`.`userId` = ? \n  AND `boards`.`id` = ?\n  AND `boards`.`appId` = `apps`.`id`",[+s.id,+i.id],function(e,r){t.release();if(e){n.send(500);throw e}return t.query("SELECT * FROM `posts`\nWHERE `boardId` = ?\nORDER BY `publishAt` DESC",[+i.id],function(e,t){return n.render("post/index.jade",{posts:t,board:r[0]})})})})};exports.create=function(e,n,r){var i;i={subject:e.param("subject"),body:"",lang:e.param("lang"),boardId:e.param("boardId")};if(!isFinite(i.boardId)){n.send(200,{code:400,message:"게시판 아이디를 찾을 수 없습니다."});return}return t.getConnection(function(e,t){if(e){t.release();n.send(200,{code:500,message:"다시 시도해주세요."});throw e}return t.query("INSERT INTO `posts`\nSET ?, `createdAt` = NOW(), `updatedAt` = NOW(), `publishAt` = DATE_ADD(NOW(), INTERVAL 24 HOUR)",[i],function(e,r){t.release();if(e){n.send(200,{code:500,message:"다시 시도해주세요."});throw e}return n.send(200,{code:200,id:r.insertId})})})};exports.find=function(e,r,i){var s,o;s={id:+e.param("boardId")};o={id:+e.param("postId")};if(!isFinite(s.id)||!isFinite(o.id)){r.send(404);return}return t.getConnection(function(t,i){if(t){i.release();r.send(500);throw t}return i.query("SELECT `posts`.*, `boards`.`appId` as `appId`, `boards`.`name` as `boardName`\nFROM `boards`, `posts`\nWHERE `boards`.`userId` = ? \n  AND `boards`.`id` = ?\n  AND `posts`.`boardId` = `boards`.`id`\n  AND `posts`.`id` = ?",[+e.three.id,+s.id,+o.id],function(t,o){var u;i.release();if(t){r.send(500);throw t}if(o.length){u=o[0].appId;s.name=o[0].boardName;return r.render("post/item.jade",{board:s,post:o[0],languages:n,url:"/v1/users/"+e.three.id+"/apps/"+u+"/boards/"+s.id+"?enableItemPreview=true&lang="+o[0].lang})}return r.send(404)})})};exports.update=function(e,n,r){var i,s,o;i=+e.param("boardId");s=+e.param("postId");o={subject:e.param("subject"),body:e.param("body"),publishAt:e.param("publishAt"),lang:e.param("lang")};if(!isFinite(i)){n.send(200,{code:400,message:"게시판 아이디를 찾을 수 없습니다."});return}if(!isFinite(s)){n.send(200,{code:400,message:"게시글 아이디를 찾을 수 없습니다."});return}return t.getConnection(function(t,r){if(t){r.release();n.send(200,{code:500,message:"다시 시도해주세요."});throw t}return r.query("SELECT COUNT(*) as `c`\nFROM `boards`\nWHERE `userId` = ?\n  AND `id` = ?",[+e.three.id,i],function(e,t){if(e){r.release();n.send(200,{code:500,message:"다시 시도해주세요."});throw e}return t[0].c?r.query("UPDATE `posts`\nSET ?, `updatedAt` = NOW()\nWHERE `id` = ?\n  AND `boardId` = ?",[o,s,i],function(e,t){r.release();if(e){n.send(200,{code:500,message:"다시 시도해주세요."});throw e}return n.send(200,{code:200,timestamp:Date.now()})}):n.send(403)})})};exports["delete"]=function(n,r,i){var s,o;s=+n.param("boardId");o=+n.param("postId");if(!isFinite(s)){r.send(200,{code:400,message:"게시판 아이디를 찾을 수 없습니다."});return}if(!isFinite(o)){r.send(200,{code:400,message:"게시글 아이디를 찾을 수 없습니다."});return}return t.getConnection(function(t,i){if(t){i.release();r.send(200,{code:500,message:"다시 시도해주세요."});throw t}return i.query("SELECT COUNT(*) as `c`\nFROM `boards`\nWHERE `userId` = ?\n  AND `id` = ?",[+n.three.id,s],function(t,u){if(t){i.release();r.send(200,{code:500,message:"다시 시도해주세요."});throw t}return u[0].c?i.query("DELETE FROM `posts`\nWHERE `id` = ?\n  AND `boardId` = ?",[o,s],function(t,o){i.release();if(t){r.send(200,{code:500,message:"다시 시도해주세요."});throw t}if(o.affectedRows){e.create(n.three.id,"게시판 #"+s+", 글 삭제"+e.getUserString(n));return r.send(200,{code:200,timestamp:Date.now()})}r.send(200,{code:500,message:"다시 시도해주세요."});throw t}):r.send(200,{code:403,message:"권한이 없습니다."})})})}}).call(this);