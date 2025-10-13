# frozen_string_literal: true

class CreatePostForm
  include ActiveModel::Model
  include CustomValidateForm

  attr_accessor :user_id,
                :title,
                :content,
                :image_url

  validates :user_id,
            presence: { message: "User must be present" }

  validates :title,
            presence: { message: "Title can't be blank" },
            length: { maximum: 255, message: "Title is too long (maximum is 255 characters)" }

  validates :content,
            presence: { message: "Content can't be blank" }

  validates :image_url,
            presence: { message: "Main image can't be blank" }

  def initialize(attributes = {})
    super(attributes)
    validate!
  end
end
