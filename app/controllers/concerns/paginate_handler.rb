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

  def es_pagination_meta(results, page, per_page)
    total_count =
      if results.dig('hits', 'total').is_a?(Hash)
        results.dig('hits', 'total', 'value')
      else
        results.dig('hits', 'total')
      end

    records = results.dig('hits', 'hits') || []
    total_pages = (total_count.to_f / per_page).ceil

    {
      current_page: page,
      next_page: page < total_pages ? page + 1 : nil,
      prev_page: page > 1 ? page - 1 : nil,
      total_pages: total_pages,
      total_count: total_count,
      current_count: records.size,
      per_page: per_page,
      is_first_page: page == 1,
      is_last_page: page >= total_pages
    }
  end
end
