require 'spec_helper'

describe "LayoutLinks" do

  describe "when not signed in" do
    it "should have a sign in link" do
      visit root_path
      response.should have_selector("a", :href => signin_path, :content => "Sign in")
    end
  end

  describe "when signed in" do
    before(:each) do
      @user = Factory(:user)
      visit signin_path
      fill_in :email, :with => @user.email
      fill_in :password, :with => @user.password
      click_button
    end

    it "should have a signout link" do
      visit root_path
      response.should have_selector("a", :href => signout_path, :content => "Sign out")
    end
  
    it "should have a profile link" do
      visit root_path
      response.should have_selector("a", :href => user_path(@user), :content => "Profile")
    end
  end

  it "should have  home page at '/'" do
    get '/'
    response.should have_selector("title", :content => "Home")
  end 

  it "should have contact page at '/contact'" do
    get '/contact'
    response.should have_selector("title", :content => "Contact")
  end

  it "should have about page at '/about'" do
    get '/about'
    response.should have_selector("title", :content => "About")
  end

  it "should have help page at /help" do
    get '/help'
    response.should have_selector("title", :content => "Help")
  end

  it "should have a signup page at /signup" do
    get '/signup'
    response.should have_selector("title", :content => "Sign Up")
  end 

end
