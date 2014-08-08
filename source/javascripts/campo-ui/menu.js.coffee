clearMenu = ->
  $('.menu.active').removeClass('active')

$(document).on('click', '[data-toggle=menu]', (event) ->
  event.preventDefault()
  event.stopPropagation()
  $(this).closest('.menu').addClass('active')
).on('click', clearMenu)
