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
  let(:client_id) { '' }
  let(:client_secret) { '' }
  let(:application_id) { '' }
  
  describe 'Token authentication' do
    let(:site) { described_class.new(server_url, site_name) }
    
    it 'authenticates using token' do
      site.session = Sharepoint::TokenAuth::Session.new(site,site_name)
      expect { 
        site.session.authenticate_with_token(
          client_id: client_id,
          client_secret: client_secret,
          application_id: application_id
        )
      }.not_to raise_error

      expect(site.session.access_token).to be_a(String)
      expect(site.session.access_token).not_to be_empty

      lists = site.query :get, 'lists'
      expect(lists).not_to be_empty

    end
  end
end 
