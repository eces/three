// Generated by CoffeeScript 1.6.3
(function(){jQuery(function(){var e;e=$("li.item-trigger");e.hammer().on("tap",function(e){var t,n;n=$(this);t=n.next("li.item");n.toggleClass("item-active");return t.toggleClass("hide")});return!0})}).call(this);