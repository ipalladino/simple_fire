class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def admin?
    session[:password] == 'leapforlove'
  end
end
