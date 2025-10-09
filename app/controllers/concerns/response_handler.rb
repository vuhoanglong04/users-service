# app/controllers/concerns/response_handler.rb
module ResponseHandler
  extend ActiveSupport::Concern

  def render_response(data: nil, message: nil, errors: nil, status: nil, meta: nil)
    http_status = status || default_status(errors)

    response_body = {
      status: response_status(http_status, errors),
      message: message || default_message(http_status),
      errors: errors.present? ? errors : nil,
      data: data,
      meta: meta
    }

    render json: response_body.compact, status: http_status
  end

  private

  def response_status(http_status, errors)
    return "error" if http_status.to_s.start_with?("5")
    return "fail" if errors.present? || http_status.to_s.start_with?("4")
    "success"
  end

  def default_message(code)
    Rack::Utils::HTTP_STATUS_CODES[code] || 'Unknown Status'
  end

  def default_status(errors)
    errors.present? ? :unprocessable_entity : :ok
  end

  def elasticsearch_pagination_meta(page, per_page, total_count)
    total_pages = (total_count / per_page.to_f).ceil

    {
      current_page: page,
      next_page: page < total_pages ? page + 1 : nil,
      prev_page: page > 1 ? page - 1 : nil,
      total_pages: total_pages,
      total_count: total_count,
      per_page: per_page,
      is_first_page: page == 1,
      is_last_page: page >= total_pages
    }
  end
end
