class StaticPagesController < ApplicationController
  def home
  end

  def help
  end

  def about
  end

  def contact
  end

  def landing
  	render :layout => 'landing_page'
  end
end
