# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :post
  has_ancestry
  acts_as_paranoid
end
