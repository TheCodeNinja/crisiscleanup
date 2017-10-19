module Worker
  class TemporaryPasswordsController < ApplicationController
    include ApplicationHelper
    def create
        random_pw = random_password
        @temporary_password = TemporaryPassword.new(password: random_pw, password_confirmation: random_pw) 
        @temporary_password.created_by = current_user.id
        @temporary_password.legacy_organization_id = current_user.legacy_organization.id
        @temporary_password.expires = DateTime.now + 30.minutes
        if @temporary_password.save
            flash[:notice] = "Temporary password successfully created. Password is #{random_pw}"
            flash[:temporary_password] = "Temporary password successfully created. Password is #{random_pw}"

         	redirect_to worker_dashboard_path
         	return
        else
            flash[:alert] = "Temporary password not created. Make sure password and password confirmation are identical, and at least 6 characters long."
            flash[:temporary_password] = "Temporary password not created. Make sure password and password confirmation are identical, and at least 6 characters long."
            redirect_to worker_dashboard_path
            return
        end 
    end

    def authorize
      temporary_passwords = TemporaryPassword.all

      if temporary_passwords and params[:password].length >= 6 and  params[:password] == params[:password_confirmation]
        temporary_passwords.each do |temp|
          obj = temp.authenticate(params[:password])
          if obj
              list = InvitationList.new(params[:email], obj.created_by, obj.legacy_organization_id)
              if list.valid?
                if list.ready.present?  
                  list.ready.each do |inv|
                    if obj.expires > DateTime.now.utc
                      InvitationMailer.send_invitation(inv, request.base_url).deliver_now
                    end
                  end
                end
              end  
              # if list.rejected.present? then WRITE ERROR HANDLING end
              flash[:notice] = "Invitation sent to #{params[:email]}"
              redirect_to "/login"
              return
          end
        end
      end
      flash[:alert] = "Could not find a matching temporary password and organization."
      redirect_to new_worker_temporary_password_path
    end

    def new
    end
  end
end
