# frozen_string_literal: true

class Api::V1::Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include ResponseHandler
  include ExceptionHandler
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  def get_google_oauth2_url
    strategy = OmniAuth::Strategies::GoogleOauth2.new(
      nil,
      ENV['GOOGLE_CLIENT_ID'],
      ENV['GOOGLE_CLIENT_SECRET'],
      {
        redirect_uri: ENV["GOOGLE_BACKEND_CALLBACK_URL"],
        scope: "email,profile"
      }
    )

    # Build URL login
    login_url = strategy.client.auth_code.authorize_url(
      redirect_uri: ENV['GOOGLE_BACKEND_CALLBACK_URL'],
      scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile',
      response_type: "code",
      access_type: "offline",
      prompt: "consent"
    )

    render_response(message: "Get google oauth2 url successfully",
                    data: { url: login_url },
                    status: 200)
  end

  def callback
    code = params[:code]
    client = OAuth2::Client.new(
      ENV['GOOGLE_CLIENT_ID'],
      ENV['GOOGLE_CLIENT_SECRET'],
      site: 'https://accounts.google.com',
      token_url: '/o/oauth2/token',
      authorize_url: '/o/oauth2/auth'
    )
    token = client.auth_code.get_token(code, redirect_uri: ENV['GOOGLE_BACKEND_CALLBACK_URL'])
    response = token.get('https://www.googleapis.com/oauth2/v2/userinfo')
    account_infor = JSON.parse(response.body)
    raise ValidationError, "Some thing went wrong. Please try again later!" if account_infor.nil?
    user = AccountUser.find_or_initialize_by(email: account_infor["email"])
    if user.new_record?
      user.password = SecureRandom.hex(10)
      user.skip_confirmation!
      user.save!
    end
    sign_in(resource_name, user)
    render_response(data: {
      user: ActiveModelSerializers::SerializableResource.new(user, serializer: AccountUserSerializer),
      refresh_token: RefreshTokenService.issue(user.id)
    },
                    message: "Login successful",
                    status: 201)
  end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end

end
