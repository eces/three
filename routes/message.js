// Generated by CoffeeScript 1.6.3
(function(){var e,t;t=require("../db.js").pool;e=require("../activity.js");exports.index=function(e,t,n){return t.render("message/index.jade")};exports.list=function(e,t,n){var r;r=+e.three.id;return t.render("message/list.jade")}}).call(this);