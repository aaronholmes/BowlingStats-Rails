require 'spec_helper'

describe "Static Pages" do
  describe "Home Page" do
    it "should have the content 'Welcome'" do
      visit '/static_pages/home'
      page.should have_content('Welcome')
    end
  end
  
  describe "About page" do
    it "should have the content 'About Us'" do
      visit '/static_pages/about'
      page.should have_content('About Us')
    end
  end
end
