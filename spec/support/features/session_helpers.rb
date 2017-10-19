module Features
  module SessionHelpers
  	def sign_in_with_admin
      org = FactoryGirl.create(:legacy_organization)
	  org_event = FactoryGirl.create(:legacy_organization_event, legacy_organization_id: org.id)
	  FactoryGirl.create(:admin, email: "Admin@aol.com", password: "blue32blue32", legacy_organization_id: org.id)

      visit "/login"
      fill_in 'Email', with: "Admin@aol.com"
      fill_in 'Password', with: "blue32blue32"
      click_button 'Log in'
  	end

    def sign_in_with_user
      org = FactoryGirl.create(:legacy_organization)
      event = FactoryGirl.create(:legacy_event)
      org.legacy_events << event
      #org_event = FactoryGirl.create(:legacy_organization_event, legacy_organization_id: org.id, legacy_event_id: 1)
      email = "Gary@aol.com"
	    user = FactoryGirl.create(:user, email: email, password: "blue32blue32", legacy_organization_id: org.id)

      visit "/login"
      fill_in 'Email', with: email
      fill_in 'Password', with: "blue32blue32"
      click_button 'Log in'
      user
    end

    def sign_in_with(email, password)
      visit "/login"
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Log in'
    end

    def create_incident
      org = FactoryGirl.create(:legacy_organization)
	    org_event = FactoryGirl.create(:legacy_organization_event, legacy_organization_id: org.id)
    end
  end
end
