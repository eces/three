// Generated by CoffeeScript 1.6.3
(function(){var e,t,n;e=require("../db.js").pool;n=[{id:"list-light",description:"iOS7 스타일 공지사항/리스트형 게시판 테마"},{id:"list-light-block",description:"밝은 디자인 앱에 어울리는 공지사항/리스트형 게시판 테마"},{id:"list-light-card",description:"밝은 디자인 앱에 어울리는 FAQ/카드형 게시판 테마"},{id:"list-calm-card",description:"은은한 회색 배경을 가진 FAQ/카드형 게시판 테마"},{id:"list-dark-card",description:"어두운 디자인 앱에 어울리는 FAQ/카드형 게시판 테마"}];t="ko en zh-CN zh-TW ja".split(" ");exports.index=function(e,t,n){return t.render("board/index.jade")};exports.list=function(t,n,r){var i;i={id:+t.three.id};return e.getConnection(function(e,t){if(e){t.release();n.send(500);throw e}return t.query("SELECT `boards`.*, `apps`.`name` as `appName`, `apps`.`platform` as `appPlatform`\nFROM `boards`, `apps`\nWHERE `boards`.`userId` = ? \n  AND `boards`.`appId` = `apps`.`id`",[i.id],function(e,r){t.release();if(e){n.send(500);throw e}return n.render("board/list.jade",{boards:r})})})};exports.create=function(t,n,r){var i;i={name:t.param("name"),viewType:"list",appId:0,defaultLang:"ko",userId:+t.three.id};if(i.name.trim().length===0){n.send(200,{code:400,message:"게시판 이름은 1글자 이상이어야 합니다."});return}return e.getConnection(function(e,t){if(e){t.release();n.send(200,{code:500,message:"다시 시도해주세요."});throw e}return t.query("INSERT INTO `boards`\nSET ?, `updatedAt` = NOW()",[i],function(e,r){t.release();if(e){n.send(200,{code:500,message:"다시 시도해주세요."});throw e}return n.send(200,{code:200,id:r.insertId})})})};exports.find=function(r,i,s){var o;o={id:+r.param("boardId")};if(!isFinite(o.id)){i.send(404);return}return e.getConnection(function(e,s){if(e){s.release();i.send(500);throw e}return s.query("SELECT * FROM `boards`\nWHERE `id` = ?",[o.id],function(e,u){s.release();return u.length?s.query("SELECT `id`, `name`, `identifier` FROM `apps`\nWHERE `userId` = ?",[+r.three.id],function(e,a){s.release();if(e){i.send(500);throw e}return i.render("board/item.jade",{board:u[0],apps:a,views:n,languages:t,url:"http://threesomeplace.com/v1/users/"+r.three.id+"/apps/"+u[0].appId+"/boards/"+o.id})}):i.send(404)})})};exports.update=function(t,n,r){var i,s;s=t.param("boardId");if(!isFinite(s)){({code:400,message:"게시판 아이디를 찾을 수 없습니다."});return}i={name:t.param("name"),viewType:t.param("viewType"),appId:t.param("appId"),defaultLang:t.param("defaultLang")};if(i.name.trim().length===0){n.send(200,{code:400,message:"게시판 이름은 1글자 이상이어야 합니다."});return}if(!isFinite(i.appId)){n.send(200,{code:400,message:"앱 아이디를 찾을 수 없습니다."});return}return e.getConnection(function(e,r){if(e){r.release();n.send(200,{code:500,message:"다시 시도해주세요."});throw e}return r.query("SELECT COUNT(*) as `c` FROM `apps`\nWHERE `id` = ?\n  AND `userId` = ?",[+i.appId,+t.three.id],function(e,o){if(e){r.release();n.send(200,{code:500,message:"다시 시도해주세요."});throw e}if(o[0].c!==0)return r.query("UPDATE `boards`\nSET ?, `updatedAt` = NOW()\nWHERE `id` = ?\n  AND `userId` = ?",[i,+s,+t.three.id],function(e,t){r.release();if(e){n.send(200,{code:500,message:"다시 시도해주세요."});throw e}return n.send(200,{code:200,timestamp:Date.now()})});r.release();n.send(200,{code:400,message:"연결할 앱을 찾을 수 없습니다."})})})};exports["delete"]=function(e,t,n){return t.send(501)};exports.preview=function(t,n,r){var i,s;s={id:+t.three.id};i={id:+t.param("boardId")};return e.getConnection(function(e,t){if(e){t.release();n.send(500);throw e}return t.query("SELECT `id` as `bid`, `userId` as `uid`, `appId` as `aid` FROM `boards`\nWHERE `boards`.`id` = ?\n  AND `boards`.`userId` = ?",[i.id,s.id],function(e,r){var i,s,o;t.release();if(e){n.send(500);throw e}if(r.length){i=r[0].aid;o=r[0].uid;s=r[0].bid;return n.render("board/preview.jade",{url:"/v1/users/"+o+"/apps/"+i+"/boards/"+s})}return n.send(404)})})};exports.view=function(t,n,r){var i,s,o,u,a,f;i=t.param("appId");f=t.param("userId");s=t.param("boardId");u=t.param("lang");a=!1;if(s.endsWith(".json")){a=!0;s=s.substr(0,s.length-5)}isFinite(s)||n.send(404,"게시판 아이디가 올바르지 않습니다.");o=t.param("enableItemPreview")==="true"?!0:!1;return e.getConnection(function(e,t){if(e){t.release();n.send(200,"다시 시도해주세요.");throw e}return t.query("SELECT * FROM `boards` WHERE `id` = ?",[s],function(e,r){if(e){t.release();n.send(200,"다시 시도해주세요.");throw e}if(r.length){u===void 0&&(u=r[0].defaultLang);return t.query("SELECT `posts`.* FROM `posts`\nWHERE `posts`.`boardId` = ?\n  AND `lang` = ?\n  AND `posts`.`publishAt` < NOW()\nORDER BY `publishAt` DESC",[s,u],function(e,i){var s;if(e){t.release();n.send(200,"다시 시도해주세요.");throw e}t.release();s="";switch(r[0].viewType){case"list-light":s="list-light";break;case"list-light-block":s="list-light-block";break;case"list-light-card":s="list-light-card";break;case"list-calm-card":s="list-calm-card";break;case"list-dark-card":s="list-dark-card";break;default:s="list-light"}return a?n.send({board:r[0],posts:i}):n.render("board/"+s+".jade",{board:r[0],posts:i,enableItemPreview:o})})}t.release();return n.send(200,"게시판을 찾을 수 없습니다.")})})}}).call(this);