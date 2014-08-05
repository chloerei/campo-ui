(function() {
  $(document).on('click', '[data-toggle=left-nav]', function() {
    var leftNav;
    leftNav = $($(this).data('target'));
    if (!leftNav.find('.left-nav-mask').length) {
      leftNav.prepend($('<div class="left-nav-mask"></div>'));
    }
    leftNav.addClass('active');
    return $('body').addClass('noscroll');
  }).on('click', '.left-nav .left-nav-mask', function() {
    $(this).closest('.left-nav').removeClass('active');
    return $('body').removeClass('noscroll');
  });

}).call(this);
