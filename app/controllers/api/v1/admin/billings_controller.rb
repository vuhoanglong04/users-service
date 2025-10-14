class Api::V1::Admin::BillingsController < Api::V1::Admin::BaseAdminController
  def index
    page = params[:page].to_i >= 1 ? params[:page].to_i : 1
    per_page = 5
    query = params[:query].to_s.strip

    cache_key = [
      "billing_page=#{page}",
      "per_page=#{per_page}",
      "query=#{query}",
    ].compact.join("&")

    Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      results = Billing.search(
        {
          from: (page - 1) * per_page,
          size: per_page,
          query: query.present? ?
                   {
                     bool: {
                       should: [
                         { multi_match: { query: query, fields: %w[status payment_method patient.first_name patient.last_name patient.email patient.emergency_contact] } }
                       ]
                     }
                   } :
                   { match_all: {} }
        }
      )

      meta = es_pagination_meta(results.response, page, per_page)

      serialized_billings = ActiveModelSerializers::SerializableResource.new(
        results.records,
        each_serializer: Admin::BillingSerializer
      ).as_json

      {
        data: { billings: serialized_billings },
        meta: meta
      }
    end.then do |cached_response|
      render_response(
        data: cached_response[:data],
        message: "Get all billings successfully",
        status: 200,
        meta: cached_response[:meta]
      )
    end
  end
end
