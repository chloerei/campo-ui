class Validation
  constructor: (@form) ->
    # Disable html5 validate
    @form.attr('novalidate', 'novalidate')
    @inputs = @form.find('input, select, textare').not(':submit, :reset, :image, [disabled], [formnovalidate]')

    @installValidators()
    @bindEvents() if @willValidate()

  installValidators: ->
    prepareMessage = @prepareMessage

    @inputs.each ->
      input = $(this)
      validators = []
      # Install validators
      $.each Validation.validators, (name, validator) ->
        if validator.match(input)
          validators.push validator

          if validator.install
            validator.install(input)

      if validators.length
        input.data 'validators', validators
        prepareMessage(input)

  willValidate: ->
    $.grep(@inputs, (element) -> $(element).data('validators').length ).length > 0

  prepareMessage: (input) ->
    message = $("<div class='input-message'></div>")
    input.closest('.input').append(message)

  bindEvents: ->
    validation = this

    @form.on 'input', 'input, select, textarea', ->
      validation.validateInput $(this)

    @form.on 'submit', (event) ->
      if not validation.valid()
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
  messages:
    required: 'This field is requird.'
    maxlength: (count) -> "Please enter no more than #{count} characters."
    number: 'Please enter a valid number.'
    max: (max) -> "Please enter a value less than or equal to #{max}."
    min: (min) -> "Please enter a value greater than or equal to #{min}."
    email: 'Please enter a valid email address.',
    patten: (patten) -> "Please enter a value match patten: #{patten}.",

  validators:
    required:
      # check whether input need this validator
      match: (input) ->
        input.attr('required')

      # excute validate. return null if valid, otherwise return message.
      validate: (input) ->
        if input.val().trim().length is 0
          input.data('errors').push Validation.messages.required

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
          input.data('errors').push Validation.messages.maxlength(input.data('maxlength'))

    number:
      match: (input) ->
        input.attr('type') is 'number'

      validate: (input) ->
        if input.val() is '' and input[0].validity.valid
          return

        unless /^-?\d+(\.\d+)?$/.test input.val()
          input.data('errors').push Validation.messages.number

        if input.attr('max') and parseFloat(input.val()) > parseFloat(input.attr('max'))
          input.data('errors').push Validation.messages.max(input.attr('max'))

        if input.attr('min') and parseFloat(input.val()) < parseFloat(input.attr('min'))
          input.data('errors').push Validation.messages.min(input.attr('min'))

    patten:
      match: (input) ->
        input.attr('patten')

      validate: (input) ->
        if input.val() is '' and input[0].validity.valid
          return

        patten = new RegExp("^#{input.attr('patten')}$")
        unless patten.test input.val()
          input.data('errors').push Validation.messages.patten(input.attr('patten'))

    email:
      match: (input) ->
        input.attr('type') is 'email'

      validate: (input) ->
        if input.val() is '' and input[0].validity.valid
          return

        unless /^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/.test input.val()
          input.data('errors').push Validation.messages.email

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
