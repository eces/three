jQuery ->
  items = $ 'li.item-trigger'
  items.hammer().on 'tap', (e) ->
    $this = $(this)
    $next = $this.next('li.item')
    $this.toggleClass 'item-active'
    $next.toggleClass 'hide'
  true