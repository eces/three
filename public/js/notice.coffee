jQuery ->
  items = $ '.item-trigger'
  items.hammer().on 'tap', (e) ->
    $this = $(this)
    $next = $this.next('.item')
    $this.toggleClass 'item-active'
    $next.toggleClass 'hide'
  true