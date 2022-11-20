class WelcomeController < ApplicationController
  def index
    @signed_in = false
    if cookies[:myjwt] 
      token = cookies[:myjwt]
      begin
        @decoded_token = JWT.decode token, Rails.configuration.x.oauth.jwt_secret, true, { algorithm: 'HS256' }
        @res = RestClient.get('http://localhost:3000/messages', {AUTHORIZATION: 'Bearer '+token })
        @signed_in = true
      rescue JWT::DecodeError
        @signed_in = false
        @message = "Unable to get messages."
        @authurl = build_auth_url
      rescue RestClient::ExceptionWithResponse
        @message = "Unable to get messages."
        @signed_in = false
        @authurl = build_auth_url
      end
    else 
      @authurl = build_auth_url
    end
  end

  def oauthcallback
    client_id = Rails.configuration.x.oauth.client_id = 'E9FDB985-9173-4E01-9D73-AC2D60D1DC8E'
    client_secret = Rails.configuration.x.oauth.client_secret = 'this_really_should_be_a_long_random_alphanumeric_value_but_this_still_works_dont_use_this_in_prod'
    idp_address = Rails.configuration.x.oauth.idp_address = 'http://localhost:9011/'
    redirect_uri = 'http://localhost:4000/oauth2-callback'

    client = OAuth2::Client.new(client_id, client_secret, site: idp_address, token_url: '/oauth2/token')
    #@token = client.auth_code.get_token(code: params[:code] :headers => {'Authorization' => 'Basic some_password'})
    token = client.auth_code.get_token(params[:code], 'redirect_uri': redirect_uri)
    cookies[:myjwt] = { value: token.to_hash[:access_token], httponly: true }
    redirect_to root_path
  end
  def build_auth_url
    client_id = Rails.configuration.x.oauth.client_id = 'E9FDB985-9173-4E01-9D73-AC2D60D1DC8E'
    client_secret = Rails.configuration.x.oauth.client_secret = 'this_really_should_be_a_long_random_alphanumeric_value_but_this_still_works_dont_use_this_in_prod'
    idp_address = Rails.configuration.x.oauth.idp_address = 'http://localhost:9011/'
 
    client = OAuth2::Client.new(client_id, client_secret, site: idp_address, authorize_url: '/oauth2/authorize')
    redirect_uri = 'http://localhost:4000/oauth2-callback'
    client.auth_code.authorize_url(redirect_uri: redirect_uri)
  end
end
