class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  #@@offline = true
  before_filter :landing_check
  

  private
  def landing_check
  	if (APP_CONFIG['app_offline']) 
  		redirect_to :landing and return if (request.env['PATH_INFO'] != "/landing")
  	end
     
  end
end
