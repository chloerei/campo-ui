$(document).on('click', '.left-nav .left-nav-toggle', ->
  $(this).closest('.left-nav').addClass('active')
  $('body').addClass('noscroll')
).on('click', '.left-nav .left-nav-mask', ->
  $(this).closest('.left-nav').removeClass('active')
  $('body').removeClass('noscroll')
)
