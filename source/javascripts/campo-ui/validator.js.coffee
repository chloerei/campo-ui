class Validation
  constructor: (@form) ->
    # Disable html5 validate
    @form.attr('novalidate', 'novalidate')
    @inputs = @form.find('input, select, textare').not(':submit, :reset, :image, [disabled], [formnovalidate]')
    @needValidation = false

    @installValidators()
    @bindEvents() if @needValidation

  installValidators: ->
    prepareMessage = @prepareMessage
    needValidation = false

    @inputs.each ->
      input = $(this)
      inputValidators = []
      # Install validators
      $.each Validation.validators, (name, validator) ->
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
    validation = this
    @form.on 'input', 'input, select, textarea', ->
      validation.validateInput $(this)

    @form.on 'submit', (event) =>
      if not @valid()
        event.preventDefault()

    @form.on 'invalid.validator', 'input, select, textarea', ->
      validation.showInputInvalid($(this))

    @form.on 'pending.validator', 'input, select, textarea', ->
      validation.showInputPending($(this))

    @form.on 'valid.validator', 'input, select, textarea', ->
      validation.showInputValid($(this))

  validate: ->
    validation = this
    @inputs.each ->
      input = $(this)
      if not input.data('validated')
        validation.validateInput(input)

  valid: ->
    @validate()
    $.grep(@inputs, (element) -> $(element).data('errors').length ).length == 0

  validateInput: (input) ->
    if validators = input.data('validators')
      input.data('errors', [])

      $.each validators, (index, validator) ->
        validator.validate(input)

      input.data('validated', true)

      if input.data('errors').length
        input.trigger('invalid.validator')
      else
        if input.data('validate-remote-pending')
          input.trigger('pending.validator')
        else
          input.trigger('valid.validator')

  showInputInvalid: (input) ->
    input.closest('.input').removeClass('pending').addClass('error')
    input.siblings('.input-message').text(input.data('errors')[0])

  showInputPending: (input) ->
    input.closest('.input').removeClass('error').addClass('pending')
    input.siblings('.input-message').text('Checking...')

  showInputValid: (input) ->
    input.closest('.input').removeClass('error pending')
    input.siblings('.input-message').text('')

$.extend Validation,
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

    remote:
      match: (input) ->
        input.data('validate-remote')

      validate: (input) ->
        if input.val() is '' and input[0].validity.valid
          return

        input.data('validate-remote-ajax')?.abort()
        input.data('validate-remote-pending', true)
        data = {}
        data[input.attr('name')] = input.val()

        ajax = $.ajax
          url: input.data('validate-remote')
          dataType: 'json'
          data: data
          success: (data) ->
            if !data.valid
              input.data('errors').push data.message
          error: (xhr, status) ->
            input.data('errors').push status
          complete: ->
            input.data('validate-remote-pending', false)
            if input.data('errors').length
              input.trigger('invalid.validator')
            else
              input.trigger('valid.validator')

        input.data 'validate-remote-ajax', ajax

$.fn.validate = ->
  this.each ->
    form = $(this)
    if not form.data 'validation'
      form.data 'validation', new Validation(form)

$ ->
  $('form:not([novalidate])').validate()
