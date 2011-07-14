require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'show'" do
    before(:each) do
      @user = Factory(:user)
    end

    it "should render" do
      get :show, :id => @user
      response.should be_success
    end

    it "should show the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end

    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title", @user.name)
    end

    it "should have the user name" do
      get :show, :id => @user
      response.should have_selector("h1", @user.name)
    end

    it "should have the right image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
    
    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign Up")
    end
  end

  describe "POST 'create'" do
    describe failure do 
      before(:each) do
      @attr => { :name => "", :email => "", :password => "", :password_confirmation => "" }
      end

      it "should not create a user" do
      lambda do
        :post => create, :user => @attr
      end.should_not change(User, :count)
      end
    
      it "should have the right title" do
        :post => create, :user => @attr
        response_should have_selector("title", :content => "Sign Up")
      end

      it "should render the 'new' page" do
        :post => create, :user => @attr
        response_should render_template('new'
      end
    end
  end

end
