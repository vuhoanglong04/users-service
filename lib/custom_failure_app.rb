class CustomFailureApp < Devise::FailureApp
  def respond
    json_api_error_response
  end

  private

  def json_api_error_response
    http_status = 401
    response_body = {
      status: "error",
      message: i18n_message.sub(/\A\w/) { |c| c.upcase } || "Authentication failed",
    }.compact

    self.status = http_status
    self.content_type = "application/json"
    self.response_body = response_body.to_json
  end
end
