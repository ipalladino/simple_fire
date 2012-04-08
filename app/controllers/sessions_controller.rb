class SessionsController < ApplicationController
  def new
  end
  
  def create
    session[:password] = params[:password]
    flash[:notice] = "Successfully logged in"
    if(params[:previous_page] != nil && params[:previous_page] != "")
      redirect_to "/" + params[:previous_page]
    else
      redirect_to "/ecards"
    end
  end
  
  def destroy
      reset_session
      flash[:notice] = "Successfully logged out";
      redirect_to "/login_form"
  end
  
end
