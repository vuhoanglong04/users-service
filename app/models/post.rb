# frozen_string_literal: true

class Post < ApplicationRecord
  has_many :comments
  validates :title,
            uniqueness: { case_sensitive: true, message: "Title must be unique" }

  acts_as_paranoid
end
