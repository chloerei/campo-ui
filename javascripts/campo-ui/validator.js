(function() {
  var Validator;

  Validator = (function() {
    function Validator(form) {
      this.form = form;
      this.form.attr('novalidate', 'novalidate');
      this.inputs = this.form.find('input, select, textare').not(':submit, :reset, :image, [disabled], [formnovalidate]');
      this.needValidation = false;
      this.installValidators();
      if (this.needValidation) {
        this.bindEvents();
      }
    }

    Validator.prototype.installValidators = function() {
      var needValidation, prepareMessage, validators;
      validators = this.validators;
      prepareMessage = this.prepareMessage;
      needValidation = false;
      this.inputs.each(function() {
        var input, inputValidators;
        input = $(this);
        inputValidators = [];
        $.each(validators, function(name, validator) {
          if (validator.match(input)) {
            inputValidators.push(validator);
            if (validator.install) {
              return validator.install(input);
            }
          }
        });
        if (inputValidators.length) {
          needValidation = true;
          input.data('validators', inputValidators);
          return prepareMessage(input);
        }
      });
      return this.needValidation = needValidation;
    };

    Validator.prototype.prepareMessage = function(input) {
      var message;
      message = $("<div class='input-message'></div>");
      return input.closest('.input').append(message);
    };

    Validator.prototype.bindEvents = function() {
      var validator;
      validator = this;
      this.form.on('input', 'input, select, textarea', function() {
        return validator.validateInput($(this));
      });
      return this.form.on('submit', (function(_this) {
        return function(event) {
          if (!_this.valid()) {
            return event.preventDefault();
          }
        };
      })(this));
    };

    Validator.prototype.validateForm = function() {
      var validator;
      validator = this;
      return this.inputs.each(function() {
        var input;
        input = $(this);
        if (!input.data('validated')) {
          return validator.validateInput(input);
        }
      });
    };

    Validator.prototype.valid = function() {
      this.validateForm();
      return $.grep(this.inputs, function(element) {
        return $(element).data('errors').length;
      }).length === 0;
    };

    Validator.prototype.validateInput = function(input) {
      var formValidator, validators;
      formValidator = this;
      if (validators = input.data('validators')) {
        input.data('errors', []);
        $.each(validators, function(index, validator) {
          return validator.validate.call(formValidator, input);
        });
        input.data('validated', true);
        return this.showInputError(input);
      }
    };

    Validator.prototype.showInputError = function(input) {
      if (input.data('errors').length) {
        input.closest('.input').removeClass('pending').addClass('error');
        return input.siblings('.input-message').text(input.data('errors')[0]);
      } else {
        if (input.data('validate-remote-pending')) {
          input.closest('.input').removeClass('error').addClass('pending');
          return input.siblings('.input-message').text('Checking...');
        } else {
          input.closest('.input').removeClass('error pending');
          return input.siblings('.input-message').text('');
        }
      }
    };

    Validator.prototype.validators = {
      required: {
        match: function(input) {
          return input.attr('required');
        },
        validate: function(input) {
          if (input.val().trim().length === 0) {
            return input.data('errors').push("Can't be blank.");
          }
        }
      },
      maxlength: {
        match: function(input) {
          return input.attr('maxlength');
        },
        install: function(input) {
          var count, counter, maxlength;
          maxlength = input.attr('maxlength');
          input.attr('maxlength', null);
          input.data('maxlength', maxlength);
          count = input.val().length;
          counter = $("<div class='input-counter'>" + count + " / " + maxlength + "</div>");
          input.after(counter);
          return input.on('input', function() {
            count = input.val().length;
            return counter.text("" + count + " / " + maxlength);
          });
        },
        validate: function(input) {
          if (input.val().length > input.data('maxlength')) {
            return input.data('errors').push("Can't over " + (input.data('maxlength')) + " Character.");
          }
        }
      },
      number: {
        match: function(input) {
          return input.attr('type') === 'number';
        },
        validate: function(input) {
          if (input.val() === '' && input[0].validity.valid) {
            return;
          }
          if (!/^-?\d+(\.\d+)?$/.test(input.val())) {
            input.data('errors').push("Should be a number.");
          }
          if (input.attr('max') && parseFloat(input.val()) > parseFloat(input.attr('max'))) {
            input.data('errors').push("Should less than " + (input.attr('max')) + ".");
          }
          if (input.attr('min') && parseFloat(input.val()) < parseFloat(input.attr('min'))) {
            return input.data('errors').push("Should larger than " + (input.attr('min')) + ".");
          }
        }
      },
      patten: {
        match: function(input) {
          return input.attr('patten');
        },
        validate: function(input) {
          var patten;
          if (input.val() === '' && input[0].validity.valid) {
            return;
          }
          patten = new RegExp("^" + (input.attr('patten')) + "$");
          if (!patten.test(input.val())) {
            return input.data('errors').push("Should match " + (input.attr('patten')) + ".");
          }
        }
      },
      email: {
        match: function(input) {
          return input.attr('type') === 'email';
        },
        validate: function(input) {
          if (input.val() === '' && input[0].validity.valid) {
            return;
          }
          if (!/^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/.test(input.val())) {
            return input.data('errors').push("Should be a Email.");
          }
        }
      },
      remote: {
        match: function(input) {
          return input.data('validate-remote');
        },
        validate: function(input) {
          var ajax, data, validator, _ref;
          if (input.val() === '' && input[0].validity.valid) {
            return;
          }
          validator = this;
          if ((_ref = input.data('validate-remote-ajax')) != null) {
            _ref.abort();
          }
          input.data('validate-remote-pending', true);
          data = {};
          data[input.attr('name')] = input.val();
          ajax = $.ajax({
            url: input.data('validate-remote'),
            dataType: 'json',
            data: data,
            success: function(data) {
              if (!data.valid) {
                return input.data('errors').push(data.message);
              }
            },
            error: function(xhr, status) {
              return input.data('errors').push(status);
            },
            complete: function() {
              input.data('validate-remote-pending', false);
              return validator.showInputError(input);
            }
          });
          return input.data('validate-remote-ajax', ajax);
        }
      }
    };

    return Validator;

  })();

  $.fn.validate = function() {
    return this.each(function() {
      var form;
      form = $(this);
      if (!form.data('validator')) {
        return form.data('validator', new Validator(form));
      }
    });
  };

  $(function() {
    return $('form:not([novalidate])').validate();
  });

}).call(this);
