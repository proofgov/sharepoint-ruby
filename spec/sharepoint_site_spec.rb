require 'spec_helper'
require 'sharepoint-ruby'
require 'sharepoint-token-auth'
require 'sharepoint-http-auth'
require 'logger'

RSpec.describe Sharepoint::Site do
  let(:server_url) { 'proofgov.sharepoint.com' }
  let(:site_name) { 'dev-wes' }
  let(:site) { described_class.new(server_url, site_name) }
  let(:username) { 'redpatch@proofgov.com' }
  let(:password) { 'werwasfasdfpoupasd343!' }
  
  before(:all) do
    @logger = defined?(Rails) ? Rails.logger : Logger.new($stdout)
  end


  describe '#query' do


    context 'with username/password authentication' do

      it 'authenticates with username/password' do
        # Set up username/password authentication


        site = Sharepoint::Site.new(server_url, site_name)
        site.verbose = @verbose
    
        site.session = Sharepoint::HttpAuth::Session.new(site) 
        site.session.authenticate(username, password)




        puts "Attempting authentication..."
        begin
            puts "Session before auth: #{site.session.inspect}"
            result = site.session.authenticate(username, password)
            expect(result).to be_truthy
        #   puts "Session after auth: #{site.session.inspect}"
        #   puts "Cookie after auth: #{site.session.cookie.inspect}"
        #   puts "Authentication completed successfully"
        rescue => e
          puts "Authentication failed: #{e.class} - #{e.message}"
          puts "Session state: #{site.session.inspect}"
          puts e.backtrace.join("\n")
          raise e
        end
      end


      it 'raises an error with invalid credentials' do
        site = Sharepoint::Site.new(server_url, site_name)
        site.verbose = @verbose
    
        site.session = Sharepoint::HttpAuth::Session.new(site) 
       # puts "Testing with invalid credentials..."
        begin
          result = site.session.authenticate('wrong_user', 'wrong_pass')
          puts "Invalid authentication unexpectedly succeeded result: #{result.inspect}"
          expect(result).to be_falsey
          puts "Invalid authentication unexpectedly succeeded"
        rescue => e
          puts "Expected authentication failure: #{e.class} - #{e.message}"
          expect(e).to be_a(Sharepoint::SharepointError)
          expect(e.message).to match(/401/)
        end
      end
    end

    context 'when response includes an error' do
      it 'raises an error for invalid endpoint' do
        expect { 
          site.query(:get, 'invalid_endpoint') 
        }.to raise_error(Sharepoint::SharepointError, /404/)
      end
    end
  end
end 