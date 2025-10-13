# frozen_string_literal: true

class Post < ApplicationRecord
  include RemoveCacheAfterCommitting
  has_many :comments
  validates :title,
            uniqueness: { case_sensitive: true, message: "Title must be unique" }
  acts_as_paranoid

  # Elasticsearch
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  settings index: {
    number_of_shards: 2,
    analysis: {
      analyzer: {
        my_vietnamese_analyzer: {
          tokenizer: "standard",
          filter: %w[lowercase asciifolding]
        }
      }
    }
  } do
    mappings dynamic: false do
      indexes :title, type: :text, analyzer: :standard do
        indexes :keyword, type: :keyword
      end
      indexes :content, type: :text, analyzer: :standard do
        indexes :keyword, type: :keyword
      end
      indexes :user_id, type: :integer
      indexes :updated_at, type: :date
      indexes :created_at, type: :date
    end
  end

  private

  def as_indexed_json(options = {})
    {
      id: id,
      user_id: user_id,
      title: title,
      content: content,
      image_url: image_url,
      created_at: created_at,
      updated_at: updated_at,
      deleted_at: deleted_at
    }
  end

end
