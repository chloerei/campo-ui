(function() {
  var Validation;

  Validation = (function() {
    function Validation(form) {
      this.form = form;
      this.form.attr('novalidate', 'novalidate');
      this.inputs = this.form.find('input, select, textare').not(':submit, :reset, :image, [disabled], [formnovalidate]');
      this.installValidators();
      if (this.willValidate()) {
        this.bindEvents();
      }
    }

    Validation.prototype.installValidators = function() {
      var prepareMessage;
      prepareMessage = this.prepareMessage;
      return this.inputs.each(function() {
        var input, validators;
        input = $(this);
        validators = [];
        $.each(Validation.validators, function(name, validator) {
          if (validator.match(input)) {
            validators.push(validator);
            if (validator.install) {
              return validator.install(input);
            }
          }
        });
        if (validators.length) {
          input.data('validation-validators', validators);
          return prepareMessage(input);
        }
      });
    };

    Validation.prototype.willValidate = function() {
      return $.grep(this.inputs, function(element) {
        return $(element).data('validation-validators');
      }).length > 0;
    };

    Validation.prototype.prepareMessage = function(input) {
      var message;
      message = $("<div class='input-message'></div>");
      return input.closest('.input').append(message);
    };

    Validation.prototype.bindEvents = function() {
      var validation;
      validation = this;
      this.form.on('input', 'input, select, textarea', function() {
        return validation.validateInput($(this));
      });
      this.form.on('submit', function(event) {
        if (!validation.valid()) {
          return event.preventDefault();
        }
      });
      this.form.on('invalid.validation', 'input, select, textarea', function() {
        return validation.showInputInvalid($(this));
      });
      this.form.on('pending.validation', 'input, select, textarea', function() {
        return validation.showInputPending($(this));
      });
      return this.form.on('valid.validation', 'input, select, textarea', function() {
        return validation.showInputValid($(this));
      });
    };

    Validation.prototype.validate = function() {
      var validation;
      validation = this;
      return this.inputs.each(function() {
        var input;
        input = $(this);
        if (!input.data('validation-validated')) {
          return validation.validateInput(input);
        }
      });
    };

    Validation.prototype.valid = function() {
      this.validate();
      return $.grep(this.inputs, function(element) {
        return $(element).data('validation-errors').length || $(element).data('validation-remote-pending');
      }).length === 0;
    };

    Validation.prototype.validateInput = function(input) {
      var validators;
      if (validators = input.data('validation-validators')) {
        input.data('validation-errors', []);
        $.each(validators, function(index, validator) {
          return validator.validate(input);
        });
        input.data('validation-validated', true);
        if (input.data('validation-errors').length) {
          return input.trigger('invalid.validation');
        } else {
          if (input.data('validation-remote-pending')) {
            return input.trigger('pending.validation');
          } else {
            return input.trigger('valid.validation');
          }
        }
      }
    };

    Validation.prototype.showInputInvalid = function(input) {
      input.closest('.input').removeClass('pending').addClass('error');
      return input.siblings('.input-message').text(input.data('validation-errors')[0]);
    };

    Validation.prototype.showInputPending = function(input) {
      input.closest('.input').removeClass('error').addClass('pending');
      return input.siblings('.input-message').text('Checking...');
    };

    Validation.prototype.showInputValid = function(input) {
      input.closest('.input').removeClass('error pending');
      return input.siblings('.input-message').text('');
    };

    return Validation;

  })();

  $.extend(Validation, {
    messages: {
      required: 'This field is requird.',
      maxlength: function(count) {
        return "Please enter no more than " + count + " characters.";
      },
      number: 'Please enter a valid number.',
      max: function(max) {
        return "Please enter a value less than or equal to " + max + ".";
      },
      min: function(min) {
        return "Please enter a value greater than or equal to " + min + ".";
      },
      email: 'Please enter a valid email address.',
      patten: function(patten) {
        return "Please enter a value match patten: " + patten + ".";
      }
    },
    validators: {
      required: {
        match: function(input) {
          return input.attr('required');
        },
        validate: function(input) {
          if (input.val().trim().length === 0) {
            return input.data('validation-errors').push(input.data('validation-message-required') || Validation.messages.required);
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
          input.data('validation-maxlength', maxlength);
          count = input.val().length;
          counter = $("<div class='input-counter'>" + count + " / " + maxlength + "</div>");
          input.after(counter);
          return input.on('input', function() {
            count = input.val().length;
            return counter.text("" + count + " / " + maxlength);
          });
        },
        validate: function(input) {
          if (input.val().length > input.data('validation-maxlength')) {
            return input.data('validation-errors').push(input.data('validation-message-maxlength') || Validation.messages.maxlength(input.data('validation-maxlength')));
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
            input.data('validation-errors').push(input.data('validation-message-number') || Validation.messages.number);
          }
          if (input.attr('max') && parseFloat(input.val()) > parseFloat(input.attr('max'))) {
            input.data('validation-errors').push(input.data('validation-message-max') || Validation.messages.max(input.attr('max')));
          }
          if (input.attr('min') && parseFloat(input.val()) < parseFloat(input.attr('min'))) {
            return input.data('validation-errors').push(input.data('validation-message-min') || Validation.messages.min(input.attr('min')));
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
            return input.data('validation-errors').push(input.data('validation-message-patten') || Validation.messages.patten(input.attr('patten')));
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
            return input.data('validation-errors').push(input.data('validation-message-email') || Validation.messages.email);
          }
        }
      },
      remote: {
        match: function(input) {
          return input.data('validation-remote');
        },
        validate: function(input) {
          var ajax, data, _ref;
          if (input.val() === '' && input[0].validity.valid) {
            return;
          }
          if ((_ref = input.data('validation-remote-ajax')) != null) {
            _ref.abort();
          }
          input.data('validation-remote-pending', true);
          data = {};
          data[input.attr('name')] = input.val();
          ajax = $.ajax({
            url: input.data('validation-remote'),
            dataType: 'json',
            data: data,
            success: function(data) {
              if (!data.valid) {
                return input.data('validation-errors').push(data.message);
              }
            },
            error: function(xhr, status) {
              return input.data('validation-errors').push(status);
            },
            complete: function() {
              input.data('validation-remote-pending', false);
              if (input.data('validation-errors').length) {
                return input.trigger('invalid.validation');
              } else {
                return input.trigger('valid.validation');
              }
            }
          });
          return input.data('validation-remote-ajax', ajax);
        }
      }
    }
  });

  $.fn.validate = function() {
    return this.each(function() {
      var form;
      form = $(this);
      if (!form.data('validation')) {
        return form.data('validation', new Validation(form));
      }
    });
  };

  $(function() {
    return $('form:not([novalidate])').validate();
  });

}).call(this);
