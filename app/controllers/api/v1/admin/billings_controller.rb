class Api::V1::Admin::BillingsController < Api::V1::Admin::BaseAdminController
  def index
    page = params[:page] ||= 1
    billings = Billing.all.page(page).per(5)
    render_response(
      data: {
        billings: ActiveModelSerializers::SerializableResource.new(billings, each_serializer: Admin::BillingSerializer)
      },
      message: "Get all billings sucessfully",
      status: 200,
      meta: pagination_meta(billings)
    )
  end
end
