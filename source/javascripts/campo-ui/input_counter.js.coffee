$.fn.inputCounter = ->
  this.each ->
    input = $(this)
    limit = input.data('counter')
    count = input.find('input, textarea').val().length
    counter = $("<div class='input-counter'>#{count} / #{limit}</div>")
    input.append(counter)

    input.on 'input', 'input, textarea', ->
      count = input.find('input, textarea').val().length
      counter.text("#{ count } / #{limit}")
      input.toggleClass('error', count > limit)
