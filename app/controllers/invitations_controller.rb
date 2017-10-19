class InvitationsController < ApplicationController
  include ApplicationHelper
  before_filter :check_token

  def activate
    @invitation = Invitation.select("invitations.*, legacy_organizations.name as org_name")
      .where(token:params[:token])
      .where('expiration > ?', DateTime.now)
      .joins("JOIN legacy_organizations ON legacy_organizations.id = invitations.organization_id")
      .first
    unless @invitation
      if Invitation.where(token:params)
        flash[:notice] = 'This account has already been activated. If a friend forwarded an activation email, you may not share it. To get your own, ask him/her to invite you from the Dashboard. Otherwise, Login or Request a New Password.'.html_safe
      else
        flash[:notice] =  "Either this invitation has expired, does not exist, or your account has already been activated. Please request a new invitation.".html_safe
      end
      redirect_to root_path
    end
  end

  def sign_up
    inv = Invitation.where(token:params[:token]).first
    # make sure passwords match
    if params["user"]["password"] != params["user"]["password_confirmation"]
      flash[:notice] = "Passwords do not match"
      redirect_to :back
      return
    end

    if params["user"]["password"].length < 8
      flash[:notice] = "Passwords not long enough"
      redirect_to :back
      return
    end
    @user = User.new(email: params["user"]["email"],
                     password: params["user"]["password"],
                     name: params["user"]["name"],
                     role: params["user"]["role"],
                     mobile: params["user"]["mobile"],
                     legacy_organization_id:inv.organization_id,
                     referring_user_id:inv.user_id,
                     accepted_terms: params["user"]["accepted_terms"]
                    )

    if @user.save
      RequestInvitation.user_created!(params["user"]["email"])
      flash[:notice] = "Invitation accepted. Please log in."
      redirect_to "/login"
      return
    else
      redirect_to :back
    end
  end
end
