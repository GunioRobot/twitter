require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'index'" do
    describe "for non-signed in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice] =~ /sign in/i
      end
    end

    describe "for signed in users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        second_user = (Factory(:user, :name => "testing", :email => "testing@gmail.com"))
        third_user = (Factory(:user, :name => "testing1", :email => "testing1@gmail.com"))

        @users = [@user, second_user, third_user]
        30.times do
          @users << Factory(:user, :email => Factory.next(:email))
        end
      end

      it "should be successful" do
        get :index
        response.should be_successful
      end

      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end

      it "should show every user" do
        get :index
        @users.each do |user|
        response.should have_selector("li", :content => user.name)
        end
      end

      it "should have an element for every user" do
        get :index
        @users[0..2].each do |user|
        response.should have_selector("li", :content => user.name)
        end
      end

      it "should paginate every user" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2", :content => "2")
        response.should have_selector("a", :href => "/users?page=2", :content => "Next")
      end

    end
  end

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
      response.should have_selector("title", :content => @user.name)
    end

    it "should have the user name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end

    it "should have the right image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end

    it "should show the users microposts" do
      mp1 = Factory(:micropost, :user => @user, :content => "micropost1")
      mp2 = Factory(:micropost, :user => @user, :content => "micropost2")
      get :show, :id => @user
      response.should have_selector("span.content", :content => mp1.content)
      response.should have_selector("span.content", :content => mp2.content)
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
    describe "failure" do
      before(:each) do
      @attr = { :name => "", :email => "", :password => "", :password_confirmation => "" }
      end

      it "should not create a user" do
      lambda do
        post :create, :user => @attr
      end.should_not change(User, :count)
      end

      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Twitter | Sign Up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
    end

    describe "success" do
      before(:each) do
        @attr = { :name => "Kegan Quimby", :email => "keganquimby@gmail.com", :password => "foobar", :password_confirmation => "foobar" }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to show the user" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end

      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome to twitter/i
      end

      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit user")
    end

    it "should have a link to change gravatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url, :content => "change")
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    describe "failure" do
      before(:each) do
        @attr = { :name => "", :email => "", :password => "", :password_confirmation => "" }
      end

      it "should render edit page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector('title', :content => "Edit user")
      end
    end

    describe "success" do
      before(:each) do
        @attr = { :name => "NewName", :email => "NewName@gmail.com", :password => "foobar", :password_confirmation => "foobar" }
      end

      it "should change the users attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should == @attr[:name]
        @user.email.should == @attr[:email]
      end

      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /update/
      end
    end
  end

  describe "authentication of edit/update" do
    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-signed in users" do
      it "should redirect to sign in" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to update" do
        put :update, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed in users" do
      before(:each) do
        wrong_user = Factory(:user, :email => "wrongemail@gmail.com")
        test_sign_in(wrong_user)
      end

      it "should require matching users to update" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end

      it "should require matching users to edit" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
    end
  end

  describe "DELETE 'destroy'" do
    before(:each) do
      @user = Factory(:user)
    end
    describe "non signed in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe "non admin user" do
      it "shouldnt allow delete" do
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end

    describe "admin user" do
      before(:each) do
        admin = Factory(:user, :email => "admin@gmail.com", :admin => true)
        test_sign_in(admin)
      end

      it "should allow delete" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
    end
  end
end
