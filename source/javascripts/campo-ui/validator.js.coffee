class Validator
  constructor: (@form) ->
    # Disable html5 validate
    @form.attr('novalidate', 'novalidate')
    @inputs = @form.find('input, select, textare').not(':submit, :reset, :image, [disabled]')

    validators = @validators

    @inputs.each ->
      input = $(this)
      # Install validators
      $.each validators, (name, validator) ->
        if validator.match(input)
          if !input.data('validators')
            input.data('validators', [])
          input.data('validators').push validator

      # Prepare message div
      if input.data('validators')?.length
        input.wrap("<div class='input'></div>")
        message = $("<div class='input-message'></div>")
        input.after(message)

        if maxlength = input.attr('maxlength')
          input.attr('maxlength', null)
          input.data('maxlength', maxlength)
          message.addClass('no-icon')
          count = input.val().length
          counter = $("<div class='input-counter'>#{count} / #{maxlength}</div>")
          message.before(counter)

          input.on 'input', ->
            count = input.val().length
            counter.text("#{count} / #{maxlength}")

    _validateInput = @validateInput
    @form.on 'input', 'input, select, textarea', ->
      _validateInput $(this)

    @form.on 'submit', (event) =>
      if not @valid()
        event.preventDefault()

  validateForm: ->
    _validateInput = @validateInput
    @inputs.each ->
      input = $(this)
      if not input.data('validated')
        _validateInput(input)

  valid: ->
    @validateForm()
    $.grep(@inputs, (element) -> $(element).data('validate-message')).length == 0

  validateInput: (input) ->
    if validators = input.data('validators')
      input.data('validate-message', null)

      $.each validators, (index, validator) ->
        if message = validator.validate(input)
          input.data('validate-message', message)
          false

      input.data('validated', true)

      # update message
      if input.data('validate-message')
        input.closest('.input').addClass('error')
        input.siblings('.input-message').text(input.data('validate-message'))
      else
        input.closest('.input').removeClass('error')
        input.siblings('.input-message').text('')

  validators:
    required:
      # check whether input need this validator
      match: (input) ->
        input.attr('required')

      # excute validate. return null if valid, otherwise return message.
      validate: (input) ->
        if input.val().trim().length is 0
          input.data('required-message') || "Can't be blank."

    maxlength:
      match: (input) ->
        input.attr('maxlength')

      validate: (input) ->
        if input.val().length > input.data('maxlength')
          input.data('maxlength-message') || "Can't over #{input.data('maxlength')} Character."

$.fn.validate = ->
  this.each ->
    form = $(this)
    if not form.data 'validator'
      form.data 'validator', new Validator(form)
  this

$ ->
  $('form:not([novalidate])').validate()
