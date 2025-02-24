require 'spec_helper'
require 'sharepoint-ruby'
require 'sharepoint-http-auth'


RSpec.describe Sharepoint::Site do


  let(:server_url) { 'proofgov.sharepoint.com' }
  let(:site_name) { 'sites/dev-wes' }
  let(:username) { '' }
  let(:password) { '' }
  
  describe 'HTTP authentication' do
    let(:site) { described_class.new(server_url, site_name) }
    
    

    context 'with live SharePoint server', :vcr do
      it 'successfully authenticates with valid credentials' do
        #site.session = Sharepoint::HttpAuth::Session.new(site)



        expect { 
          site.session.authenticate(username, password)
        }.not_to raise_error

        expect(site.session.cookie).not_to be_nil

        #form digest
        digest = site.form_digest
        expect(digest).not_to be_nil
      end

      it 'unsuccessfully authenticates with invalid credentials' do
        expect { 
          site.session.authenticate('invalid_username', 'invalid_password')
        }.to raise_error(Sharepoint::Session::AuthenticationFailed)
      end
    end
  end
end 
