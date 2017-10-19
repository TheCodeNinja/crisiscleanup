
module Pages
  class WorkerContactPage < BaseWorkerPage

    def click_dashboard_link
      find('.has-dropdown').hover
      click_link "Dashboard"
    end

    def click_contacts_link
      find('.has-dropdown').hover
      click_link "Contacts"
    end

  end
end
