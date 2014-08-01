(function() {
  $.fn.inputCounter = function() {
    return this.each(function() {
      var count, counter, input, limit;
      input = $(this);
      limit = input.data('counter');
      count = input.find('input, textarea').val().length;
      counter = $("<div class='input-counter'>" + count + " / " + limit + "</div>");
      input.append(counter);
      return input.on('input', 'input, textarea', function() {
        count = input.find('input, textarea').val().length;
        counter.text("" + count + " / " + limit);
        return input.toggleClass('error', count > limit);
      });
    });
  };

}).call(this);
