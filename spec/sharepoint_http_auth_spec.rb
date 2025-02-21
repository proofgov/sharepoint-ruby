require 'spec_helper'
require 'sharepoint-ruby'
require 'sharepoint-http-auth'


RSpec.describe Sharepoint::Site do


  let(:server_url) { 'proofgov.sharepoint.com' }
  let(:site_name) { 'dev-wes' }
  let(:username) { '' }
  let(:password) { '' }
  
  describe 'HTTP authentication' do
    let(:site) { described_class.new(server_url, site_name) }
    
    

    context 'with live SharePoint server', :vcr do
      it 'successfully authenticates with valid credentials' do
        site.session = Sharepoint::HttpAuth::Session.new(site)



        expect { 
          site.session.authenticate(username, password)
        }.not_to raise_error

        expect(site.session.cookie).not_to be_nil

        #form digest
        # digest = site.form_digest
        # puts "Digest: #{digest.inspect}"
        # expect(digest).not_to be_nil


        begin
          site_info = site.query(:get, '')
          #puts "Site info response: #{site_info.inspect}"
          expect(site_info).to have_key('d')
        rescue => e
         # puts "Site info request failed: #{e.message}"
        
          raise e
        end
  

        # # test with get request to lists
        # response = site.query(:get, 'lists')

        # expect(response).to have_key('d')  # Should have 'd' key regardless of list count
        # expect(response['d']).to have_key('results')  # Should have 'results' key even if empty
        
        # lists = site.lists
        # puts "Lists response: #{lists.inspect}"
        # # No assertion about list count - it could be empty or not
        # if lists.any?
        #     expect(lists.first).to be_a(Sharepoint::List)
        # end

        #puts "END with live SharePoint server': Authenticating with username: #{username} and password: #{password}"
      end
    end
  end
end 