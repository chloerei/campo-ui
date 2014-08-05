$(document).on('click', '[data-toggle=left-nav]', ->
  leftNav = $($(this).data('target'))
  unless leftNav.find('.left-nav-mask').length
    leftNav.prepend($('<div class="left-nav-mask"></div>'))
  leftNav.addClass('active')
  $('body').addClass('noscroll')
).on('click', '.left-nav .left-nav-mask', ->
  $(this).closest('.left-nav').removeClass('active')
  $('body').removeClass('noscroll')
)
