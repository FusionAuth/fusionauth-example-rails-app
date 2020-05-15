class WelcomeController < ApplicationController
  def index
    @signed_in = false
    if cookies[:myjwt] 
      token = cookies[:myjwt]
      @decoded_token = JWT.decode token, Rails.configuration.x.oauth.jwt_secret, true, { algorithm: 'HS256' }
      @signed_in = true
    else 
      client_id = Rails.configuration.x.oauth.client_id = '0ef466ba-0505-4150-9b34-da0895a98cae'
      client_secret = Rails.configuration.x.oauth.client_secret = 'hBWwAt32AQlfXV_pm93dkAFxd51WJhcPpfFp5_xZN6I'
      idp_address = Rails.configuration.x.oauth.idp_address = 'http://localhost:9011/'
  
      client = OAuth2::Client.new(client_id, client_secret, site: idp_address, authorize_url: '/oauth2/authorize')
      redirect_uri = 'http://localhost:4000/oauth2-callback'
      @authurl = client.auth_code.authorize_url(redirect_uri: redirect_uri)
    end
  end
  def oauthcallback
    client_id = Rails.configuration.x.oauth.client_id = '0ef466ba-0505-4150-9b34-da0895a98cae'
    client_secret = Rails.configuration.x.oauth.client_secret = 'hBWwAt32AQlfXV_pm93dkAFxd51WJhcPpfFp5_xZN6I'
    idp_address = Rails.configuration.x.oauth.idp_address = 'http://localhost:9011/'
    redirect_uri = 'http://localhost:4000/oauth2-callback'

    client = OAuth2::Client.new(client_id, client_secret, site: idp_address, token_url: '/oauth2/token')
    #@token = client.auth_code.get_token(code: params[:code] :headers => {'Authorization' => 'Basic some_password'})
    token = client.auth_code.get_token(params[:code], 'redirect_uri': redirect_uri)
    cookies[:myjwt] = { value: token.to_hash[:access_token], httponly: true }
    redirect_to root_path
  end
end
