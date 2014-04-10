// Generated by CoffeeScript 1.6.3
(function(){jQuery(function(){var e,t,n,r,i,s,o,u,a,f,l,c;c="ko en zh-CN zh-TW ja".split(" ");moment.lang("ko");l={};l.signin=function(e){var t,n,r;t=$(e);n=t.find("#input10").val().trim();r=t.find("#input11").val().trim();if(n.length===0){alert("이메일 주소를 입력해주세요.");return}if(r.length===0){alert("비밀번호를 입력해주세요.");return}return $.ajax({url:"/session",method:"post",data:{email:n,password:r},success:function(e,t,n){return e.code===200?location.href="/users/"+e.id:alert(e.message+" "+e.code)},error:function(e,t,n){return alert("다시 시도해주세요.")}})};l.signup=function(e){var t,n,r,i,s,o;t=$(e);n=t.find("#input20").val().trim();i=t.find("#input21").val().trim();s=t.find("#input22").val().trim();r=t.find("#input23").val().trim();o=t.find("#input24").val().trim();if(n.length===0||n.indexOf("@")===-1){alert("이메일 주소를 입력해주세요.");return}if(i.length===0){alert("비밀번호를 입력해주세요.");return}if(i!==s){alert("두 개의 비밀번호가 일치하지 않습니다.");return}if(r.length===0){alert("이름을 입력해주세요.");return}return $.ajax({url:"/users",method:"post",data:{email:n,password:i,name:r,promo:o},success:function(e,t,n){return e.code===200?location.href="/users/"+e.id:alert(e.message+" "+e.code)},error:function(e,t,n){return alert("다시 시도해주세요.")}})};l.createApp=function(e,t){var n,r;n=$(t.target);r=prompt("추가할 앱 이름을 적어주세요. (1글자 이상)");r=r.trim();if(r.length===0)return;return $.ajax({url:"/apps",method:"post",data:{name:r},success:function(e,t,n){return e.code===200?location.href="/apps/"+e.id:alert(e.message+" "+e.code)},error:function(e,t,n){return alert("다시 시도해주세요.")}})};l.updateApp=function(e){var t,n,r,i,s;t=$(e);r=t.data("app-id");i=t.find("#input20").val().trim();n=t.find("#input21").val().trim();s=t.find("#input23").val().trim();return $.ajax({url:"/apps/"+r,method:"put",data:{name:i,identifier:n,platform:s},success:function(e,n,r){return e.code===200?t.find("button[type=submit]").html(moment(e.timestamp).format("LT")+" 완료"):alert(e.message+" "+e.code)},error:function(e,t,n){return alert("다시 시도해주세요.")}})};l.createBoard=function(e,t){var n;n=prompt("추가할 게시판 이름을 적어주세요. (1글자 이상)");n=n.trim();if(n.length===0)return;return $.ajax({url:"/boards",method:"post",data:{name:n},success:function(e,t,n){return e.code===200?location.href="/boards/"+e.id:alert(e.message+" "+e.code)},error:function(e,t,n){return alert("다시 시도해주세요.")}})};l.updateBoard=function(e){var t,n,r,i,s,o;t=$(e);i=t.data("board-id");n=t.find("#input20").val().trim();s=t.find("#input21").val().trim();o=t.find("input[name=input22]:checked").val().trim();r=t.find("#input24").val().trim();return $.ajax({url:"/boards/"+i,method:"put",data:{name:s,appId:n,viewType:o,defaultLang:r},success:function(e,n,r){return e.code===200?t.find("button[type=submit]").html(moment(e.timestamp).format("LT")+" 완료"):alert(e.message+" "+e.code)},error:function(e,t,n){return alert("다시 시도해주세요.")}})};l.createPost=function(e,t){var n,r;n=$(t.target).data("board-id");r=$(t.target).data("board-default-lang");return $.ajax({url:"/boards/"+n+"/posts",method:"post",data:{subject:"제목없음",lang:r},success:function(e,t,r){return e.code===200?location.href="/boards/"+n+"/posts/"+e.id:alert(e.message+" "+e.code)},error:function(e,t,n){return alert("다시 시도해주세요.")}})};l.updatePost=function(e){var t,n,r,i,s,o,u,a;t=$(e);n=t.data("board-id");o=t.data("post-id");a=t.find("#input20").val().trim();r=t.find("#input21").code();i=t.find("#input22").val().trim();u=t.find("#input23").val();s=moment(u).format("YYYY-MM-DD HH:mm:ss");if(s==="Invalid date"){alert("게시일의 날짜가 잘못되었습니다.\n\n입력된 값: "+u+"\n바른 형식: "+moment().format("YYYY-MM-DD HH:mm:ss"));return}return $.ajax({url:"/boards/"+n+"/posts/"+o,method:"put",data:{subject:a,body:r,lang:i,publishAt:u},success:function(e,n,r){return e.code===200?t.find("button[type=submit]").html(moment(e.timestamp).format("LT")+" 완료"):alert(e.message+" "+e.code)},error:function(e,t,n){return alert("다시 시도해주세요.")}})};l.deletePost=function(e,t){var n,r,i;n=$(t.target);r=n.data("board-id");i=n.data("post-id");return $.ajax({url:"/boards/"+r+"/posts/"+i,method:"delete",success:function(e,t,n){var r;if(e.code===200){r=$("tr[data-post-id="+i+"]");r.css({opacity:.3});return r.find("a,button").remove()}return alert(e.message+" "+e.code)},error:function(e,t,n){return alert("다시 시도해주세요.")}})};l.previewPost=function(e,t){var n,r,i,s,o,u;r=$("iframe.preview");s=r.contents().find("content .list");i=s.find(".item-preview");n=s.find(".item-preview-content");u=$("#input20").val().trim();o=$("#input21").code();i.show();i.find(".item-preview-title").html(u);i.find(".item-preview-subtitle").html(moment().format("MM/DD"));return n.html(o)};l.createMessage=function(e,t){var n;n=prompt("메시지 이름을 적어주세요. (1글자 이상)");n=n.trim();if(n.length===0)return;return $.ajax({url:"/messages",method:"post",data:{name:n},success:function(e,t,n){return e.code===200?location.href="/messages/"+e.id:alert(e.message+" "+e.code)},error:function(e,t,n){return alert("다시 시도해주세요.")}})};l.updateMessage=function(e){var t,n,r,i,s,o,u,a,f,l,h,p;t=$(e);f=t.data("message-id");i=t.find("#input20").val().trim();l=t.find("#input21").val().trim();o=t.find("#input22").val().trim();a=t.find("#input24").val().trim();if(i==="0"){alert("연결된 앱이 없습니다. 앱을 선택해주세요.");t.find("#input20").focus();return}if(o.length===0){alert("식별자는 1글자 이상이어야 합니다.");t.find("#input22").focus();return}if(!/^[a-z0-9\-\_]+$/i.test(o)){alert("식별자 형식이 잘못되었습니다. URI 규칙을 따릅니다.");t.find("#input22").focus();return}s=new FormData;s.append("appId",i);s.append("name",l);s.append("identifier",o);s.append("lang",a);for(h=0,p=c.length;h<p;h++){u=c[h];r=$("#"+u);s.append(u,$("#"+u).val());if(r.is(":disabled")){n=r.prev().prev();s.append(u,n[0].files[0])}}return $.ajax({url:"/messages/"+f,method:"put",data:s,cache:!1,contentType:!1,processData:!1,success:function(e,n,r){if(e.code===200){t.find("button[type=submit]").html(moment(e.timestamp).format("LT")+" 완료");return location.reload()}return alert(e.message+" "+e.code)},error:function(e,t,n){return alert("다시 시도해주세요.")}})};l.deleteMessage=function(e,t){var n,r;n=$(t.target);r=n.data("message-id");return $.ajax({url:"/messages/"+r,method:"delete",success:function(e,t,n){var i;if(e.code===200){i=$("tr[data-message-id="+r+"]");i.css({opacity:.3});return i.find("a,button").remove()}return alert(e.message+" "+e.code)},error:function(e,t,n){return alert("다시 시도해주세요.")}})};l.signBeta=function(e,t){var n,r;n=$(t.target);r=prompt("감사합니다 !\n\n이메일 주소를 남겨주시면 순차적으로 가입링크를 보내드리겠습니다.");if(r.length===0)return!1;if(r.indexOf("@")===-1){r=prompt("이메일 주소를 다시 확인해주세요.");if(r.length===0)return!1;if(r.indexOf("@")===-1)return!1}return $.ajax({url:"/users/subscribe",method:"post",data:{email:r},success:function(e,t,r){return e.code===200?n.html("곧 연락드리겠습니다. 감사합니다!"):alert(e.message+" "+e.code)},error:function(e,t,n){return alert("다시 시도해주세요.")}})};ko.applyBindings(l);f=$("[data-toggle~=summernote]");f.length&&f.summernote({height:200,focus:!0,lang:"ko-KR"});i=$("[data-toggle~=navigation]");if(i.length){r=$("div.document-menu");e=r.find("a.active");e.parent().is("h6")&&(e=e.parent());o=e.prev();s=e.next();n=i.find("a");t=i.find("span");if(o.is(".end"))n.filter(":even").html("");else{o.is("a")||(o.is("h6")?o=o.find("a"):o.is("hr")&&(o=o.prev()));n.filter(":even").attr("href",o.attr("href"));t.filter(":even").html(" "+o.text())}console.log(s);if(s.is(".end"))n.filter(":odd").html("");else{s.is("a")||(s.is("h6")?s=s.find("a"):s.is("hr")&&(s=s.next().find("a")));n.filter(":odd").attr("href",s.attr("href"));t.filter(":odd").html(s.text()+" ")}console.log(o,s)}a=$("[data-toggle~=submission]");a.length&&a.bind("change",function(e){var t;t=$(this).next().next();t.html("");t.attr("placeholder","파일이 선택되었습니다 - 전송을 누르면 파일을 업로드하여 이 곳에 URL을 채웁니다.");return t.attr("disabled","disabled")});!0;u=$("[data-toggle~=previewMessage]");if(u.length){u.bind("mouseenter",function(e){var t,n;n=$(this);t=$("#previewFrame");t.attr("src",n.data("url"));return t.show()});return u.bind("mouseleave",function(e){var t;t=$("#previewFrame");return t.hide()})}})}).call(this);