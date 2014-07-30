(function() {
  $(document).on('click', '.left-nav .left-nav-toggle', function() {
    $(this).closest('.left-nav').addClass('active');
    return $('body').addClass('noscroll');
  }).on('click', '.left-nav .left-nav-mask', function() {
    $(this).closest('.left-nav').removeClass('active');
    return $('body').removeClass('noscroll');
  });

}).call(this);
