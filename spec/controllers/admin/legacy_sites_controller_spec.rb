require 'rails_helper'
require 'spec_helper'

RSpec.describe Admin::LegacySitesController, :type => :controller do

	before do |example|
	  org = FactoryGirl.create :legacy_organization 
	  FactoryGirl.create :legacy_event
	  @admin = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: true) 
	  @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false) 
	end

	describe "Get #index" do
		context "with an admin user" do
			it "renders the index view" do
				allow(controller).to receive(:current_user).and_return(@admin)
				get :index
				expect(should).to render_template :index
			end

			it "populates an array of LegacySites" do
				allow(controller).to receive(:current_user).and_return(@admin)
				mock_geocoding!
				@site = FactoryGirl.create :legacy_site, legacy_event_id: Legacy::LegacyEvent.first.id
				get :index 
				assigns(:sites).should eq([@site])
			end
		end

		context "without an admin user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(@user)
				get :index
				expect(should).to redirect_to "/dashboard"
			end
		end

		context "without a user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(nil)
				get :index
				expect(should).to redirect_to "/login"
			end
		end
	end

	describe "Get #new" do
		context "with an admin user" do
			it "renders the new view" do
				allow(controller).to receive(:current_user).and_return(@admin)
				get :new
				expect(should).to render_template :new
			end

			it "returns a new legacy site" do
				allow(controller).to receive(:current_user).and_return(@admin)
				get :new
				assigns(:site).name.should eq(nil)
			end
		end

		context "without an admin user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(@user)
				get :new
				expect(should).to redirect_to "/dashboard"
			end
		end

		context "without a user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(nil)
				get :new
				expect(should).to redirect_to "/login"
			end
		end

	end

	describe "Post #create" do
		context "with an admin user" do
			it "creates a new site" do
				allow(controller).to receive(:current_user).and_return(@admin)
				mock_geocoding!
				expect {
					post :create, legacy_legacy_site: FactoryGirl.attributes_for(:legacy_site, legacy_event_id: Legacy::LegacyEvent.first.id)
				}.to change(Legacy::LegacySite, :count).by(1)
			end

			it "redirects to the site index" do
				allow(controller).to receive(:current_user).and_return(@admin)
				mock_geocoding!
				post :create, legacy_legacy_site: FactoryGirl.attributes_for(:legacy_site, legacy_event_id: Legacy::LegacyEvent.first.id)
				response.should redirect_to :admin_legacy_sites
			end
		end

		context "without an admin user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(@user)
				post :create
				expect(should).to redirect_to "/dashboard"
			end
		end

		context "without a user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(nil)
				post :create
				expect(should).to redirect_to "/login"
			end
		end
	end

	describe "Get #edit" do
		context "with an admin user" do
			it "renders the edit view with the correct site" do
				allow(controller).to receive(:current_user).and_return(@admin)
				mock_geocoding!
				site = FactoryGirl.create :legacy_site, legacy_event_id: Legacy::LegacyEvent.first.id
				get :edit, id: site
				expect(should).to render_template :edit
			end

			it "assigns the requested site to @site" do
				allow(controller).to receive(:current_user).and_return(@admin)
				mock_geocoding!
				site = FactoryGirl.create :legacy_site, legacy_event_id: Legacy::LegacyEvent.first.id
				get :edit, id: site
				expect(should).to render_template :edit
			end
		end

		context "without an admin user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(@user)
				mock_geocoding!
				site = FactoryGirl.create :legacy_site, legacy_event_id: Legacy::LegacyEvent.first.id
				get :edit, id: site
				expect(should).to redirect_to "/dashboard"
			end
		end

		context "without a user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(nil)
				mock_geocoding!
				site = FactoryGirl.create :legacy_site, legacy_event_id: Legacy::LegacyEvent.first.id
				get :edit, id: site
				expect(should).to redirect_to "/login"
			end
		end

	end
	describe "Put #update" do
		context "with an admin user" do
			it "locates the correct site" do
				allow(controller).to receive(:current_user).and_return(@admin)
				mock_geocoding!
				site = FactoryGirl.create :legacy_site, legacy_event_id: Legacy::LegacyEvent.first.id
				put :update, id: site, legacy_legacy_site: FactoryGirl.attributes_for(:legacy_site, legacy_event_id: Legacy::LegacyEvent.first.id)
		      	assigns(:site).should eq(site)  
			end
			context "with correct attributes" do
				it "changes the site's attributes" do
					mock_geocoding!
					@site = FactoryGirl.create :legacy_site, legacy_event_id: Legacy::LegacyEvent.first.id
					allow(controller).to receive(:current_user).and_return(@admin)
					put :update, id: @site, legacy_legacy_site: FactoryGirl.attributes_for(:legacy_site, name: "ZZ", legacy_event_id: Legacy::LegacyEvent.first.id)
					@site.reload
					@site.name.should eq("ZZ")
				end

				it "redirects the updated site" do
					mock_geocoding!
					@site = FactoryGirl.create :legacy_site, legacy_event_id: Legacy::LegacyEvent.first.id
					allow(controller).to receive(:current_user).and_return(@admin)
					put :update, id: @site, legacy_legacy_site: FactoryGirl.attributes_for(:legacy_site, case_label: "ZZ", legacy_event_id: Legacy::LegacyEvent.first.id)
					expect(response).to redirect_to :admin_legacy_sites
				end
			end
		end

		context "without an admin user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(@user)
				mock_geocoding!
				site = FactoryGirl.create :legacy_site, legacy_event_id: Legacy::LegacyEvent.first.id
				put :update, id: site
				expect(should).to redirect_to "/dashboard"
			end
		end

		context "without a user" do
			it "redirects to login" do
				allow(controller).to receive(:current_user).and_return(nil)
				mock_geocoding!
				site = FactoryGirl.create :legacy_site, legacy_event_id: Legacy::LegacyEvent.first.id
				post :create, id: site
				expect(should).to redirect_to "/login"
			end
		end
	end

end