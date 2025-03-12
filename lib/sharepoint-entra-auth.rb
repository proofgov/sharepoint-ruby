require 'curb'
require 'cgi'
require 'logger'
require 'securerandom'
require 'jwt'

module Sharepoint
  module EntraAuth
    class Session
      attr_accessor :site
      attr_reader :client_id, :private_key, :cert_hash, :access_token, :app_site_id

      def initialize(site, client_id, private_key, cert_hash)
        @site        = site
        @client_id   = client_id
        @private_key = private_key
        @cert_hash   = cert_hash
        @logger = defined?(Rails) ? Rails.logger : Logger.new($stdout)
      end

      def name
        site.name
      end

      def authenticate(tenant_id, sharepoint_subdomain)
        # Validate required parameters
        validate_params(
          client_id: client_id,
          private_key: private_key,
          cert_hash: cert_hash,
          tenant_id: tenant_id
        )

        url = "https://login.microsoftonline.com/#{tenant_id}/oauth2/v2.0/token"
        current_unix_time = Time.now.to_i

        # built with the help of https://learn.microsoft.com/en-us/entra/identity-platform/certificate-credentials
        payload = {
          "aud": url,
          "exp": current_unix_time + 5*60,
          "iss": client_id,             # "issuer"
          "jti": SecureRandom.uuid,     # "JWT ID - must be unique"
          "nbf": current_unix_time - 1, # "not before time"
          "sub": client_id,             # subject
          "iat": current_unix_time      # issued at
        }

        extra_headers = {
          "x5t#S256": cert_hash, # Base64url-encoded SHA-256 thumbprint of the X.509 certificate's DER encoding.
          # calculated with `openssl x509 -in stiletto.crt -noout -fingerprint -sha256 | sed "s/sha256 Fingerprint=//" | sed "s/://g" | xxd -r -p | openssl enc -base64`
          # based on an answer from https://stackoverflow.com/questions/36163093/how-do-we-generate-a-base64-encoded-sha256-hash-of-subjectpublickeyinfo-of-an-x
        }

        token = JWT.encode(payload, private_key, 'PS256', extra_headers)

        # Convert form data to URL-encoded string
        form_data = [
          'grant_type=client_credentials',
          "client_id=#{CGI.escape(client_id)}",
          'client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
          "client_assertion=#{token}",
          "scope=https://#{sharepoint_subdomain}.sharepoint.com/.default"
          # "scope=https://proofgov.sharepoint.com/.default"
        ].join('&')

        curl = Curl::Easy.new(url)
        curl.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        curl.post(form_data)
        # Parse the response to get the access token
        response = JSON.parse(curl.body)

        if curl.response_code.to_i > 299
          logger.error("Error in token derivation: #{response}")
        end

        @access_token = response['access_token']

        if not @access_token
          raise SharepointError.new("Error response received in authentication: #{response}")
        end
      end

      def resolve_site_id
        url = "https://graph.microsoft.com/v1.0/sites/#{@site.server_url}:/sites/#{name.gsub(/^sites\//, '')}"

        curl = Curl::Easy.new(url)
        curl.headers['Authorization'] = "Bearer #{@access_token}"
        curl.headers['Accept'] = 'application/json;odata.metadata=minimal'

        curl.get
        response = JSON.parse(curl.body)

        @app_site_id = response['id']
      end

      def cookie
        String.new
      end

      private

      def validate_params(client_id:, private_key:, cert_hash:, tenant_id:)
        missing_params = []

        missing_params << 'client_id' if client_id.nil? || client_id.empty?
        missing_params << 'private_key' if not private_key
        missing_params << 'cert_hash' if cert_hash.nil? || cert_hash.empty?
        missing_params << 'tenant_id' if tenant_id.nil? || tenant_id.empty?

        if missing_params.any?
          raise SharepointError.new("Missing required parameters: #{missing_params.join(', ')}")
        end
      end
    end
  end
end
