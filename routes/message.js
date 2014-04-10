// Generated by CoffeeScript 1.6.3
(function(){var e,t,n,r,i;n=require("../db.js").pool;e=require("../activity.js");r=require("url");t=require("fs");i="ko en zh-CN zh-TW ja".split(" ");exports.index=function(e,t,n){return t.render("message/index.jade")};exports.list=function(e,t,r){var i;i=+e.three.id;return n.getConnection(function(e,n){if(e){n.release();t.send(500);throw e}return n.query("SELECT `messages`.*, `apps`.`platform` as `appPlatform`, `apps`.`name` as `appName`\nFROM `messages`, `apps`\nWHERE `messages`.`userId` = ?\n  AND `messages`.`appId` = `apps`.`id`\nORDER BY `apps`.`appId`, `apps`.`identifier` ASC",[+i],function(e,r){n.release();if(e){t.send(500);throw e}return t.render("message/list.jade",{messages:r})})})};exports.create=function(e,t,r){var i,s;s=+e.three.id;i={appId:0,userId:s,identifier:"",name:e.param("name"),defaultLang:"en"};return n.getConnection(function(e,n){if(e){n.release();t.send(200,{code:500,message:"다시 시도해주세요."});throw e}return n.query("INSERT INTO `messages`\nSET ?, `createdAt` = NOW(), `updatedAt` = NOW()",[i],function(e,r){n.release();if(e){t.send(200,{code:500,message:"다시 시도해주세요."});throw e}return t.send(200,{code:200,id:r.insertId})})})};exports.find=function(e,t,r){var s,o;o=+e.three.id;s=e.param("messageId");if(!isFinite(s)){t.send(404);return}return n.getConnection(function(n,r){if(n){r.release();t.send(500);throw n}return r.query("SELECT * FROM `apps`\nWHERE `userId` = ?",[o],function(n,u){if(n){r.release();t.send(500);throw n}return r.query("SELECT `messages`.*\nFROM `messages`\nWHERE `messages`.`id` = ?\n  AND `messages`.`userId` = ?",[s,o],function(n,s){var o;r.release();if(n){t.send(500);throw n}if(s.length){o=s[0].appId;return t.render("message/item.jade",{apps:u,message:s[0],languages:i,url:"http://"+e.headers.host+"/v1/users/"+e.three.id+"/apps/"+o+"/messages/"+s[0].identifier})}return t.send(404)})})})};exports.update=function(e,r,s){var o,u,a,f;f=+e.three.id;a=+e.param("messageId");o=+e.param("appId");u={appId:o,userId:f,identifier:e.param("identifier"),ko:e.param("ko"),en:e.param("en"),"zh-CN":e.param("zh-CN"),"zh-TW":e.param("zh-TW"),ja:e.param("ja"),name:e.param("name"),defaultLang:e.param("lang")};if(!isFinite(o)){r.send(200,{code:400,message:"앱 아이디를 찾을 수 없습니다."});return}if(!isFinite(a)){r.send(200,{code:400,message:"게시판 아이디를 찾을 수 없습니다."});return}/^[a-z0-9\-\_]+$/i.test(u.identifier)||r.send(200,{code:400,message:"식별자 형식이 잘못되었습니다. URI 규칙을 따릅니다."});return n.getConnection(function(n,s){if(n){s.release();r.send(200,{code:500,message:"다시 시도해주세요."});throw n}return s.query("SELECT COUNT(*) as `c`, `id`\nFROM `messages`\nWHERE `userId` = ?\n  AND `appId` = ?\n  AND `identifier` = ?",[f,o,u.identifier],function(n,l){var c,h,p,d,v,m,g,y,b;if(n){s.release();r.send(200,{code:500,message:"다시 시도해주세요."});throw n}if(l[0].id===a||l[0].c===0){for(y=0,b=i.length;y<b;y++){d=i[y];c=e.files[d];console.log("accepted",c);if(c!==void 0){if(c.size>1048576){s.release();r.send(200,{code:500,message:"업로드 할 파일이 제한용량(1MB)보다 큽니다."});return}h=Date.now();m="./uploads/"+f+"/"+o+"/"+h+".jpg";if(!t.existsSync("./uploads/"+f+"/"+o)){t.existsSync("./uploads/"+f)||t.mkdirSync("./uploads/"+f);t.mkdirSync("./uploads/"+f+"/"+o)}g=c.path;p=t.createReadStream(g);v=t.createWriteStream(m);p.pipe(v);p.on("end",function(){return t.unlinkSync(g)});u[d]="http://"+e.headers.host+"/v1/users/"+f+"/apps/"+o+"/files/"+h}}return s.query("UPDATE `messages`\nSET ?, `updatedAt` = NOW()\nWHERE `id` = ?\n  AND `userId` = ?",[u,a,f],function(e,t){s.release();if(e){r.send(200,{code:500,message:"다시 시도해주세요."});throw e}return r.send(200,{code:200,timestamp:Date.now()})})}r.send(200,{code:400,message:"해당 앱에 같은 식별자를 가진 중복된 메시지가 있습니다. \n업데이트 취소."})})})};exports.sendfile=function(e,n,r){var i,s,o;o=+e.three.id;i=+e.param("appId");s=e.param("filename")+".jpg";return t.exists("./uploads/"+o+"/"+i+"/"+s,function(e){console.log("./uploads/"+o+"/"+i+"/"+s,e);return e?n.sendfile("./uploads/"+o+"/"+i+"/"+s):n.send(404)})};exports["delete"]=function(t,r,i){var s,o;o=+t.three.id;s=+t.param("messageId");if(!isFinite(s)){r.send(200,{code:400,message:"메시지 아이디를 찾을 수 없습니다."});return}return n.getConnection(function(n,i){if(n){i.release();r.send(200,{code:500,message:"다시 시도해주세요."});throw n}return i.query("DELETE FROM `messages`\nWHERE `id` = ?\n  AND `userId` = ?",[s,o],function(n,u){i.release();if(n){r.send(200,{code:500,message:"다시 시도해주세요."});throw n}if(u.affectedRows){e.create(t,o,"메시지 #"+s+" 삭제");return r.send(200,{code:200,timestamp:Date.now()})}r.send(200,{code:500,message:"다시 시도해주세요."});throw n})})};exports.view=function(e,t,i){var s,o,u,a;s=e.param("appId");a=e.param("userId");u=e.param("messageIdentifier");o=e.param("lang");isFinite(s)||t.send(400);return n.getConnection(function(e,n){if(e){n.release();t.send(500);throw e}return n.query("SELECT * FROM `messages`\nWHERE `appId` = ?\n  AND `userId` = ?\n  AND `identifier` = ?",[s,a,u],function(e,i){var s,u,a;n.release();if(e){t.send(500);throw e}if(i.length){u=i[0].defaultLang;o===void 0&&(o=u);s=i[0][o];if(s===void 0||s.length===0)s=i[0][u];if(s.startsWith("http")){a=r.parse(s);if(a.protocol!==null&&a.host!==null){t.redirect(302,s);return}}return t.send(200,s)}return t.send(404)})})}}).call(this);