# frozen_string_literal: true

class UpdatePostForm
  include ActiveModel::Model
  include CustomValidateForm

  attr_accessor :user_id,
                :title,
                :content,
                :image_url

  validates :title,
            presence: { message: "Title can't be blank" },
            length: { maximum: 255, message: "Title is too long (maximum is 255 characters)" },
            allow_blank: true

  def initialize(attributes = {})
    super(attributes)
    validate!
  end
end
