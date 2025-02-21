require 'spec_helper'
require 'sharepoint-ruby'
require 'sharepoint-token-auth'
require 'logger'


RSpec.describe Sharepoint::Site do
  before(:all) do
    # Silence the logger for tests
    Logger.new('/dev/null')
  end

  let(:server_url) { 'proofgov.sharepoint.com' }
  let(:site_name) { 'dev-wes' }
  let(:access_token) { '' }
  let(:client_id) { '' }
  let(:client_secret) { '' }
  let(:application_id) { '' }
  
  describe 'Token authentication' do
    let(:site) { described_class.new(server_url, site_name) }
    
    it 'authenticates using token' do
      site.session = Sharepoint::TokenAuth::Session.new(site)
      expect { 
        site.session.authenticate_with_token(
          client_id: client_id,
          client_secret: client_secret,
          application_id: application_id
        )
      }.not_to raise_error

      #puts "Session: #{site.session.inspect}"
      expect(site.session.access_token).to be_a(String)
      expect(site.session.access_token).not_to be_empty

      response = site.query(:get, '')
      puts "Response: #{response.inspect}"
      expect(response).not_to be_nil
      expect(response).to have_key('d')

      # test with get request to lists
      response = site.query(:get, 'lists')

      expect(response).to have_key('d')  # Should have 'd' key regardless of list count
      expect(response['d']).to have_key('results')  # Should have 'results' key even if empty
      
      lists = site.lists
      puts "Lists response: #{lists.inspect}"
      # No assertion about list count - it could be empty or not
      if lists.any?
        expect(lists.first).to be_a(Sharepoint::List)
      end
    end
  end
end 