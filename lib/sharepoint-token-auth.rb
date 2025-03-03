require 'curb'
require 'cgi'
require 'logger'

module Sharepoint
  module TokenAuth
    class Session
      attr_accessor :site, :name
      attr_reader :client_id, :client_secret, :application_id, :access_token, :app_site_id

      def initialize site, name
        @site     = site
        @name     = name
        @logger = defined?(Rails) ? Rails.logger : Logger.new($stdout)
      end

      def authenticate_with_token(client_id:, client_secret:, application_id:)
        # Validate required parameters
        validate_params(
          client_id: client_id,
          client_secret: client_secret,
          application_id: application_id
        )

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
        
        # Check for empty response body
        if curl.body.nil? || curl.body.empty?
          raise SharepointError.new("Empty response received from authentication endpoint")
        end
        
        # Parse the response to get the access token
        response = JSON.parse(curl.body)
        @access_token = response['access_token']

        if not @access_token
          raise SharepointError.new("Error response received in authentication: #{response}")
        end
        url = "https://graph.microsoft.com/v1.0/sites/#{@site.server_url}:/sites/#{@name}"    

        

        curl = Curl::Easy.new(url)
        curl.headers['Authorization'] = "Bearer #{@access_token}"
        curl.headers['Accept'] = "application/json;odata.metadata=minimal"
        
        curl.get
        response = JSON.parse(curl.body)

        @app_site_id = response['id']


            
      end


      def cookie
        String.new
      end

      def curl curb
        curb.headers['Authorization'] = "Bearer #{@access_token}"
      end


      private

      def validate_params(client_id:, client_secret:, application_id:)
        missing_params = []
        
        missing_params << 'client_id' if client_id.nil? || client_id.empty?
        missing_params << 'client_secret' if client_secret.nil? || client_secret.empty?
        missing_params << 'application_id' if application_id.nil? || application_id.empty?
        
        if missing_params.any?
          raise SharepointError.new("Missing required parameters: #{missing_params.join(', ')}")
        end
      end
    end
  end
end
