(function() {
  var FormValidator;

  FormValidator = (function() {
    function FormValidator(form) {
      var validators, _validateInput;
      this.form = form;
      this.form.attr('novalidate', 'novalidate');
      this.inputs = this.form.find('input, select, textare').not(':submit, :reset, :image, [disabled]');
      validators = this.validators;
      this.inputs.each(function() {
        var count, counter, input, maxlength, message, _ref;
        input = $(this);
        $.each(validators, function(name, validator) {
          if (validator.match(input)) {
            if (!input.data('validators')) {
              input.data('validators', []);
            }
            return input.data('validators').push(validator);
          }
        });
        if ((_ref = input.data('validators')) != null ? _ref.length : void 0) {
          input.wrap("<div class='input'></div>");
          message = $("<div class='input-message'></div>");
          input.after(message);
          if (maxlength = input.attr('maxlength')) {
            input.attr('maxlength', null);
            input.data('maxlength', maxlength);
            message.addClass('no-icon');
            count = input.val().length;
            counter = $("<div class='input-counter'>" + count + " / " + maxlength + "</div>");
            message.before(counter);
            return input.on('input', function() {
              count = input.val().length;
              return counter.text("" + count + " / " + maxlength);
            });
          }
        }
      });
      _validateInput = this.validateInput;
      this.form.on('input', 'input, select, textarea', function() {
        return _validateInput($(this));
      });
      this.form.on('submit', (function(_this) {
        return function(event) {
          _this.validateForm();
          if (!_this.validatePass()) {
            return event.preventDefault();
          }
        };
      })(this));
    }

    FormValidator.prototype.validateForm = function() {
      var _validateInput;
      _validateInput = this.validateInput;
      return this.inputs.each(function() {
        return _validateInput($(this));
      });
    };

    FormValidator.prototype.validatePass = function() {
      return $.grep(this.inputs, function(element) {
        return $(element).data('validate-message');
      }).length === 0;
    };

    FormValidator.prototype.validateInput = function(input) {
      var validators;
      if (validators = input.data('validators')) {
        input.data('validate-message', null);
        $.each(validators, function(index, validator) {
          var message;
          if (message = validator.validate(input)) {
            input.data('validate-message', message);
            return false;
          }
        });
        if (input.data('validate-message')) {
          input.closest('.input').addClass('error');
          return input.siblings('.input-message').text(input.data('validate-message'));
        } else {
          input.closest('.input').removeClass('error');
          return input.siblings('.input-message').text('');
        }
      }
    };

    FormValidator.prototype.validators = {
      required: {
        match: function(input) {
          return input.attr('required');
        },
        validate: function(input) {
          if (input.val().trim().length === 0) {
            return input.data('required-message') || "Can't be blank.";
          }
        }
      },
      maxlength: {
        match: function(input) {
          return input.attr('maxlength');
        },
        validate: function(input) {
          if (input.val().length > input.data('maxlength')) {
            return input.data('maxlength-message') || ("Can't over " + (input.data('maxlength')) + " Character.");
          }
        }
      }
    };

    return FormValidator;

  })();

  $.fn.validate = function() {
    this.each(function() {
      var form;
      form = $(this);
      if (!form.data('formValidator')) {
        return form.data('formValidator', new FormValidator(form));
      } else {
        return form.data('formValidator');
      }
    });
    return this;
  };

  $(function() {
    return $('form:not([novalidate])').validate();
  });

}).call(this);
