# // Some general UI pack related JS
# // Extend JS String with repeat method
# String.prototype.repeat = function(num) {
#   return new Array(num + 1).join(this);
# };

jQuery ->
  # $(':checkbox').checkbox()
  # $(':radio').radio()
  # $('select').selectpicker
  #   style: 'btn btn-inverse'
  #   menuStyle: 'dropdown'

  __languages__ = 'ko en zh-CN zh-TW ja'.split(' ')

  moment.lang 'ko'
  # $('.datetimepicker').datetimepicker {
  #   format: 'yyyy-MM-dd HH:mm:ss'
  #   language: 'ko-KR'
  # }

  view = {}
  view.signin = (f) ->
    $f = $ f
    e = $f.find('#input10').val().trim()
    p = $f.find('#input11').val().trim()
    if e.length is 0
      alert '이메일 주소를 입력해주세요.'
      return
    if p.length is 0
      alert '비밀번호를 입력해주세요.'
      return
    $.ajax
      url: '/session'
      method: 'post'
      data:
        email: e
        password: p
      success: (d, s, x) ->
        if d.code is 200
          location.href = '/users/' + d.id
        else
          alert d.message + ' ' + d.code
      error: (x, s, d) ->
        alert '다시 시도해주세요.'
  view.signup = (f) ->
    $f = $ f
    e = $f.find('#input20').val().trim()
    p1 = $f.find('#input21').val().trim()
    p2 = $f.find('#input22').val().trim()
    n = $f.find('#input23').val().trim()
    promo = $f.find('#input24').val().trim()
    if e.length is 0 or e.indexOf('@') is -1
      alert '이메일 주소를 입력해주세요.'
      return
    if p1.length is 0
      alert '비밀번호를 입력해주세요.'
      return
    if p1 isnt p2
      alert '두 개의 비밀번호가 일치하지 않습니다.'
      return
    if n.length is 0
      alert '이름을 입력해주세요.'
      return
    $.ajax
      url: '/users'
      method: 'post'
      data:
        email: e
        password: p1
        name: n
        promo: promo
      success: (d, s, x) ->
        if d.code is 200
          location.href = '/users/' + d.id
        else
          alert d.message + ' ' + d.code
      error: (x, s, d) ->
        alert '다시 시도해주세요.'
  view.createApp = (data, event) ->
    $this = $ event.target
    n = prompt '추가할 앱 이름을 적어주세요. (1글자 이상)'
    n = n.trim()
    if n.length is 0
      # alert '앱 이름은 1글자 이상이어야 합니다.'
      return
    $.ajax
      url: '/apps'
      method: 'post'
      data:
        name: n
      success: (d, s, x) ->
        if d.code is 200
          location.href = '/apps/' + d.id
        else
          alert d.message + ' ' + d.code
      error: (x, s, d) ->
        alert '다시 시도해주세요.'
  view.updateApp = (f) ->
    $f = $ f
    id = $f.data 'app-id'
    n = $f.find('#input20').val().trim()
    i = $f.find('#input21').val().trim()
    p = $f.find('#input23').val().trim()
    
    $.ajax
      url: '/apps/' + id
      method: 'put'
      data:
        name: n
        identifier: i
        platform: p
      success: (d, s, x) ->
        if d.code is 200
          $f.find('button[type=submit]').html moment(d.timestamp).format('LT') + ' 완료'
        else
          alert d.message + ' ' + d.code
      error: (x, s, d) ->
        alert '다시 시도해주세요.'
  # view.board =
  #   viewType: ko.observable 'list-light'
  view.createBoard = (data, event) ->
    n = prompt '추가할 게시판 이름을 적어주세요. (1글자 이상)'
    n = n.trim()
    if n.length is 0
      # alert '앱 이름은 1글자 이상이어야 합니다.'
      return
    $.ajax
      url: '/boards'
      method: 'post'
      data:
        name: n
      success: (d, s, x) ->
        if d.code is 200
          location.href = '/boards/' + d.id
        else
          alert d.message + ' ' + d.code
      error: (x, s, d) ->
        alert '다시 시도해주세요.'
  view.updateBoard = (f) ->
    $f = $ f
    id = $f.data 'board-id'
    appId = $f.find('#input20').val().trim()
    name = $f.find('#input21').val().trim()
    viewType = $f.find('input[name=input22]:checked').val().trim()
    defaultLang = $f.find('#input24').val().trim()
    
    $.ajax
      url: '/boards/' + id
      method: 'put'
      data:
        name: name
        appId: appId
        viewType: viewType
        defaultLang: defaultLang
      success: (d, s, x) ->
        if d.code is 200
          $f.find('button[type=submit]').html moment(d.timestamp).format('LT') + ' 완료'
        else
          alert d.message + ' ' + d.code
      error: (x, s, d) ->
        alert '다시 시도해주세요.'
  view.createPost = (data, event) ->
    boardId = $(event.target).data 'board-id'
    lang = $(event.target).data 'board-default-lang'
    $.ajax
      url: "/boards/#{boardId}/posts"
      method: 'post'
      data:
        subject: '제목없음'
        lang: lang
      success: (d, s, x) ->
        if d.code is 200
          location.href = "/boards/#{boardId}/posts/#{d.id}"
        else
          alert d.message + ' ' + d.code
      error: (x, s, d) ->
        alert '다시 시도해주세요.'
  view.updatePost = (f) ->
    $f = $ f
    bid = $f.data 'board-id'
    pid = $f.data 'post-id'
    subject = $f.find('#input20').val().trim()
    # body = $f.find('#input21').val()
    body = $f.find('#input21').code()
    lang = $f.find('#input22').val().trim()
    publishAt = $f.find('#input23').val()

    mm = moment(publishAt).format('YYYY-MM-DD HH:mm:ss')
    # console.log mm
    if mm is 'Invalid date'
      alert "게시일의 날짜가 잘못되었습니다.\n\n입력된 값: #{publishAt}\n바른 형식: #{moment().format('YYYY-MM-DD HH:mm:ss')}"
      return
    # publishAt = mm.toISOString()
    
    $.ajax
      url: '/boards/' + bid + '/posts/' + pid
      method: 'put'
      data:
        subject: subject
        body: body
        lang: lang
        publishAt: publishAt
      success: (d, s, x) ->
        if d.code is 200
          $f.find('button[type=submit]').html moment(d.timestamp).format('LT') + ' 완료'
        else
          alert d.message + ' ' + d.code
      error: (x, s, d) ->
        alert '다시 시도해주세요.'

  # view.deletePostId = null
  # view.deletePostTimeout = null
  view.deletePost = (data, event) ->
    $this = $ event.target
    bid = $this.data 'board-id'
    pid = $this.data 'post-id'
    $.ajax
      url: '/boards/' + bid + '/posts/' + pid
      method: 'delete'
      success: (d, s, x) ->
        if d.code is 200
          $item = $("tr[data-post-id=#{pid}]")
          $item.css
            opacity: 0.3
          $item.find('a,button').remove()
        else
          alert d.message + ' ' + d.code
      error: (x, s, d) ->
        alert '다시 시도해주세요.'
  view.previewPost = (data, event) ->
    $f = $ 'iframe.preview'
    $list = $f.contents().find 'content .list'
    $item = $list.find '.item-preview'
    $content = $list.find '.item-preview-content'
    subject = $('#input20').val().trim()
    # body = $('#input21').val()
    body = $('#input21').code()
    $item.show()
    # .addClass('item-active')
    $item.find('.item-preview-title').html(subject)
    $item.find('.item-preview-subtitle').html moment().format('MM/DD')
    $content.html(body)
    # .show()
    
  # view.viewBoard = (data, event) ->
  #   $this = $ event.target
  #   bid = $this.data 'board-id'
  #   # redirect to real page
  #   location.href = '/boards/' + bid + '/preview'
  view.createMessage = (data, event) ->
    n = prompt '메시지 이름을 적어주세요. (1글자 이상)'
    n = n.trim()
    if n.length is 0
      return
    $.ajax
      url: '/messages'
      method: 'post'
      data:
        name: n
      success: (d, s, x) ->
        if d.code is 200
          location.href = '/messages/' + d.id
        else
          alert d.message + ' ' + d.code
      error: (x, s, d) ->
        alert '다시 시도해주세요.'
  # 
  view.updateMessage = (f) ->
    $f = $ f
    mid = $f.data 'message-id'
    appId = $f.find('#input20').val().trim()
    name = $f.find('#input21').val().trim()
    identifier = $f.find('#input22').val().trim()
    lang = $f.find('#input24').val().trim()

    if appId is '0'
      alert '연결된 앱이 없습니다. 앱을 선택해주세요.'
      $f.find('#input20').focus()
      return

    if identifier.length is 0
      alert '식별자는 1글자 이상이어야 합니다.'
      $f.find('#input22').focus()
      return
    if not /^[a-z0-9\-\_]+$/i.test(identifier)
      alert '식별자 형식이 잘못되었습니다. URI 규칙을 따릅니다.'
      $f.find('#input22').focus()
      return

    # data =
    #   appId: appId
    #   name: name
    #   identifier: identifier
    #   lang: lang
    data = new FormData
    data.append 'appId', appId
    data.append 'name', name
    data.append 'identifier', identifier
    data.append 'lang', lang

    for l in __languages__
      # data[l] = $('#'+l).val()
      $lang = $('#'+l)
      data.append l, $('#'+l).val()
      if $lang.is(':disabled')
        $file = $lang.prev().prev()
        data.append l, $file[0].files[0]
    # return
    $.ajax
      url: '/messages/' + mid
      method: 'put'
      data: data
      cache: false
      contentType: false
      processData: false
      success: (d, s, x) ->
        if d.code is 200
          $f.find('button[type=submit]').html moment(d.timestamp).format('LT') + ' 완료'
          location.reload()
        else
          alert d.message + ' ' + d.code
      error: (x, s, d) ->
        alert '다시 시도해주세요.'
  # 
  view.deleteMessage = (data, event) ->
    $this = $ event.target
    mid = $this.data 'message-id'
    $.ajax
      url: '/messages/' + mid
      method: 'delete'
      success: (d, s, x) ->
        if d.code is 200
          $item = $("tr[data-message-id=#{mid}]")
          $item.css
            opacity: 0.3
          $item.find('a,button').remove()
        else
          alert d.message + ' ' + d.code
      error: (x, s, d) ->
        alert '다시 시도해주세요.'

  view.signBeta = (data, event) ->
    $this = $ event.target
    e = prompt '감사합니다 !\n\n이메일 주소를 남겨주시면 순차적으로 가입링크를 보내드리겠습니다.'
    return false if e.length is 0
    
    if e.indexOf('@') is -1
      e = prompt '이메일 주소를 다시 확인해주세요.'
      return false if e.length is 0
      if e.indexOf('@') is -1
        return false
    $.ajax
      url: '/users/subscribe'
      method: 'post'
      data: 
        email: e
      success: (d, s, x) ->
        if d.code is 200
          $this.html '곧 연락드리겠습니다. 감사합니다!'
        else
          alert d.message + ' ' + d.code
      error: (x, s, d) ->
        alert '다시 시도해주세요.'
  ko.applyBindings view
  # mixpanel.track 'Test'

  $summernotes = $('[data-toggle~=summernote]')
  if $summernotes.length
    $summernotes.summernote
      height: 200
      focus: true
      lang: 'ko-KR'
      # toolbar: [
      #   # ['style', ['style']]
      #   ['style', ['bold', 'italic', 'underline', 'clear']]
      #   ['fontsize', ['fontsize']]
      #   ['color', ['color']]
      #   ['para', ['ul', 'ol', 'paragraph']]
      #   ['height', ['height']]
      #   # ['insert', ['picture', 'link']]
      #   ['insert', ['picture', 'link']]
      #   ['table', ['table']]
      #   ['help', ['help']]
      # ]

  $navigations = $ '[data-toggle~=navigation]'
  if $navigations.length
    # get current by a.active
    $menu = $ 'div.document-menu'
    $cur = $menu.find('a.active')
    if $cur.parent().is('h6')
      $cur = $cur.parent()
    $prev = $cur.prev()
    $next = $cur.next()

    $elemLinks = $navigations.find 'a'
    $elemLabels = $navigations.find 'span'

    # fill prev and next

    if $prev.is('.end')
      $elemLinks.filter(':even').html ''
    else 
      if not $prev.is('a')
        if $prev.is('h6')
          $prev = $prev.find 'a'
        else if $prev.is('hr')
          $prev = $prev.prev()
      $elemLinks.filter(':even').attr 'href', $prev.attr 'href'
      # aware of white spaces
      $elemLabels.filter(':even').html ' ' + $prev.text()

    console.log $next
    if $next.is('.end')
      $elemLinks.filter(':odd').html ''
    else
      if not $next.is('a')
        if $next.is('h6')
          $next = $next.find 'a'
        else if $next.is('hr')
          $next = $next.next().find 'a'
      $elemLinks.filter(':odd').attr 'href', $next.attr 'href'
      # aware of white spaces
      $elemLabels.filter(':odd').html $next.text() + ' '

    console.log $prev, $next

  $submissions = $ '[data-toggle~=submission]'
  if $submissions.length
    $submissions.bind 'change', (e) ->
      $textarea = $(this).next().next()
      $textarea.html ''
      $textarea.attr 'placeholder', '파일이 선택되었습니다 - 전송을 누르면 파일을 업로드하여 이 곳에 URL을 채웁니다.'
      $textarea.attr 'disabled', 'disabled'
  true

# (function($) {

#   // Add segments to a slider
#   $.fn.addSliderSegments = function (amount, orientation) {    
#     return this.each(function () {
#       if (orientation == "vertical") {
#         var output = ''
#           , i;
#         for (i = 1; i <= amount - 2; i++) {
#           output += '<div class="ui-slider-segment" style="top:' + 100 / (amount - 1) * i + '%;"></div>';
#         };
#         $(this).prepend(output);
#       } else {
#         var segmentGap = 100 / (amount - 1) + "%"
#           , segment = '<div class="ui-slider-segment" style="margin-left: ' + segmentGap + ';"></div>';
#         $(this).prepend(segment.repeat(amount - 2));
#       }
#     });
#   };

#   $(function() {
  
#     // Todo list
#     $(".todo").on('click', 'li', function() {
#       $(this).toggleClass("todo-done");
#     });

#     // Custom Selects
#     $("select[name='huge']").selectpicker({style: 'btn-hg btn-primary', menuStyle: 'dropdown-inverse'});
#     $("select[name='herolist']").selectpicker({style: 'btn-primary', menuStyle: 'dropdown-inverse'});
#     $("select[name='info']").selectpicker({style: 'btn-info'});

#     // Tooltips
#     $("[data-toggle=tooltip]").tooltip("show");

#     // Tags Input
#     $(".tagsinput").tagsInput();

#     // jQuery UI Sliders
#     var $slider = $("#slider");
#     if ($slider.length) {
#       $slider.slider({
#         min: 1,
#         max: 5,
#         value: 2,
#         orientation: "horizontal",
#         range: "min"
#       }).addSliderSegments($slider.slider("option").max);
#     }

#     var $verticalSlider = $("#vertical-slider");
#     if ($verticalSlider.length) {
#       $verticalSlider.slider({
#         min: 1,
#         max: 5,
#         value: 3,
#         orientation: "vertical",
#         range: "min"
#       }).addSliderSegments($verticalSlider.slider("option").max, "vertical");
#     }

#     // Placeholders for input/textarea
#     $(":text, textarea").placeholder();

#     // Focus state for append/prepend inputs
#     $('.input-group').on('focus', '.form-control', function () {
#       $(this).closest('.input-group, .form-group').addClass('focus');
#     }).on('blur', '.form-control', function () {
#       $(this).closest('.input-group, .form-group').removeClass('focus');
#     });

#     // Make pagination demo work
#     $(".pagination").on('click', "a", function() {
#       $(this).parent().siblings("li").removeClass("active").end().addClass("active");
#     });

#     $(".btn-group").on('click', "a", function() {
#       $(this).siblings().removeClass("active").end().addClass("active");
#     });

#     // Disable link clicks to prevent page scrolling
#     $(document).on('click', 'a[href="#fakelink"]', function (e) {
#       e.preventDefault();
#     });

#     // Switch
#     $("[data-toggle='switch']").wrap('<div class="switch" />').parent().bootstrapSwitch();

#         // Typeahead
#     if($('#typeahead-demo-01').length) {
#       $('#typeahead-demo-01').typeahead({
#         name: 'states',
#         limit: 4,
#         local: ["Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut",
#         "Delaware","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky",
#         "Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri",
#         "Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Dakota",
#         "North Carolina","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina",
#         "South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming"]
#       });
#     }  

#     // make code pretty
#     window.prettyPrint && prettyPrint();
    
#   });
  
# })(jQuery);