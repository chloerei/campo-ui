class Validator
  constructor: (@form) ->
    # Disable html5 validate
    @form.attr('novalidate', 'novalidate')
    @inputs = @form.find('input, select, textare').not(':submit, :reset, :image, [disabled], [formnovalidate]')
    @needValidation = false

    @installValidators()
    @bindEvents() if @needValidation

  installValidators: ->
    validators = @validators
    prepareMessage = @prepareMessage
    needValidation = false

    @inputs.each ->
      input = $(this)
      inputValidators = []
      # Install validators
      $.each validators, (name, validator) ->
        if validator.match(input)
          inputValidators.push validator

          if validator.install
            validator.install(input)

      if inputValidators.length
        needValidation = true
        input.data('validators', inputValidators)
        prepareMessage(input)

    @needValidation = needValidation

  prepareMessage: (input) ->
    message = $("<div class='input-message'></div>")
    input.closest('.input').append(message)

  bindEvents: ->
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
    $.grep(@inputs, (element) -> $(element).data('errors').length ).length == 0

  validateInput: (input) ->
    if validators = input.data('validators')
      input.data('errors', [])

      $.each validators, (index, validator) ->
        validator.validate(input)

      input.data('validated', true)

      # update message
      if input.data('errors').length
        input.closest('.input').addClass('error')
        input.siblings('.input-message').text(input.data('errors')[0])
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
          input.data('errors').push "Can't be blank."

    maxlength:
      match: (input) ->
        input.attr('maxlength')

      install: (input) ->
        # Disable html5 validator
        maxlength = input.attr('maxlength')
        input.attr('maxlength', null)
        input.data('maxlength', maxlength)

        # Install counter
        count = input.val().length
        counter = $("<div class='input-counter'>#{count} / #{maxlength}</div>")
        input.after(counter)

        input.on 'input', ->
          count = input.val().length
          counter.text("#{count} / #{maxlength}")

      validate: (input) ->
        if input.val().length > input.data('maxlength')
          input.data('errors').push "Can't over #{input.data('maxlength')} Character."

    number:
      match: (input) ->
        input.attr('type') is 'number'

      validate: (input) ->
        if input.val() is '' and input[0].validity.valid
          return

        unless /^-?\d+(\.\d+)?$/.test input.val()
          input.data('errors').push "Should be a number."

        if input.attr('max') and parseFloat(input.val()) > parseFloat(input.attr('max'))
          input.data('errors').push "Should less than #{input.attr('max')}."

        if input.attr('min') and parseFloat(input.val()) < parseFloat(input.attr('min'))
          input.data('errors').push "Should larger than #{input.attr('min')}."

    patten:
      match: (input) ->
        input.attr('patten')

      validate: (input) ->
        if input.val() is '' and input[0].validity.valid
          return

        patten = new RegExp("^#{input.attr('patten')}$")
        unless patten.test input.val()
          input.data('errors').push "Should match #{input.attr('patten')}."

    email:
      match: (input) ->
        input.attr('type') is 'email'

      validate: (input) ->
        if input.val() is '' and input[0].validity.valid
          return

        unless /^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/.test input.val()
          input.data('errors').push "Should be a Email."

$.fn.validate = ->
  this.each ->
    form = $(this)
    if not form.data 'validator'
      form.data 'validator', new Validator(form)

$ ->
  $('form:not([novalidate])').validate()
