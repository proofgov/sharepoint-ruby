require 'curb'
require 'cgi'
require 'logger'

module Sharepoint
  module TokenAuth
    class Session
      attr_accessor :site
      attr_reader :client_id, :client_secret, :application_id, :access_token

      def initialize site
        @site     = site
        @logger = defined?(Rails) ? Rails.logger : Logger.new($stdout)
      end

      def authenticate_with_token(client_id:, client_secret:, application_id:)
        @client_id = client_id
        @client_secret = client_secret
        @application_id = application_id
 

        url = "https://login.microsoftonline.com/#{@application_id}/oauth2/v2.0/token"
        
        # Convert form data to URL-encoded string
        form_data = [
          "grant_type=client_credentials",
          "client_id=#{CGI.escape(client_id)}",
          "client_secret=#{CGI.escape(client_secret)}",
          "scope=https://graph.microsoft.com/.default"
        ].join('&')

        curl = Curl::Easy.new(url)
        curl.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        curl.post(form_data)
        

        
        # Parse the response to get the access token
        response = JSON.parse(curl.body)
       
        @access_token = response['access_token']
        #@logger.info "Access token: #{@access_token}"
        
        # Set the access token in the site
        #@site.oauth_token = @access_token

        true
      end

      def cookie
        String.new
      end


      def curl curb
        curb.headers['Authorization'] = "Bearer #{@access_token}"
      end
    end
  end
end
