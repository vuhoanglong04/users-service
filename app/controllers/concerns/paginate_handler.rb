# frozen_string_literal: true

module PaginateHandler
  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      current_count: collection.count,
      per_page: collection.limit_value,
      is_first_page: collection.first_page?,
      is_last_page: collection.last_page?
    }
  end
end
