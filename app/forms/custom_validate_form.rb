# frozen_string_literal: true

module CustomValidateForm
  def validate!
    raise ValidationError.new("Validation failed", errors) unless valid?
  end
end
