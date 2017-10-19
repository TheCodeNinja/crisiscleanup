module Worker
  class InvitationListsController < ApplicationController
    include ApplicationHelper
    def create
        organization = params[:organization] || current_user.legacy_organization.id
        emails = params[:email_addresses].gsub(/\s+/, "").split(",")
        used_emails = check_user_emails emails

        valid_emails = emails - used_emails
    	list = InvitationList.new(valid_emails.join(","), current_user, organization)
    	if list.valid?
    		if list.ready.present?  
    			list.ready.each do |inv|
    				InvitationMailer.send_invitation(inv, request.base_url).deliver_now
                    RequestInvitation.invited!(inv.invitee_email)
    			end
    		end
        end  
        # if list.rejected.present? then WRITE ERROR HANDLING end
        notice = ""
        unless valid_emails.empty?
            notice += "Invitation sent to " + valid_emails.join(",")
        end
        unless used_emails.empty?
            notice += " Invitation not sent to existing emails #{used_emails.join(",")}".html_safe
        end
        flash[:notice] = notice
    	redirect_to current_user.admin ? admin_path : worker_dashboard_path
    end
  end
end
