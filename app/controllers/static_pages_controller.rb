class StaticPagesController < ApplicationController
  def index
    if current_user
      redirect_to "/dashboard"
    end
    render 'index_demo' if request.host =~ /demo/
  end
  def home
    render 'index'
  end
  def about
      render :layout => 'application_sidebar'
  end
  def public_map
      @events = Legacy::LegacyEvent.all
      render :layout => 'application_sidebar'
  end
  def privacy
  end
  def terms
  end      
  def signup
  end
  def new_incident
    render 'new_incident_demo' if request.host =~ /demo/
  end
  def request_incident
    @users = User.where(admin:true)
    @users.each do |user| 
      InvitationMailer.send_incident_request(params, user.email).deliver_now
    end
    flash[:notice] = "Your request has been received"
    redirect_to "/"
  end
  def redeploy
  end
  def donate
    redirect_to "https://www.patreon.com/crisiscleanup"
  end

  def contact
  end

  def voad
      render :layout => 'application_sidebar'
  end

  def volunteer
      render :layout => 'application_sidebar'
  end

  def government
      render :layout => 'application_sidebar'
  end

  def survivor
      render :layout => 'application_sidebar'
  end

  def training
      render :layout => 'application_sidebar'
  end
end
