# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe User do

  before(:each) do
    @attr = { 
      :name => "Kegan Quimby", 
      :email => "keganquimby@gmail.com", 
      :password => "foobar",
      :password_confirmation => "foobar"
      }
  end

  it "should create a new user given attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  it "should require an email" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[keganquimby@gmail.com KEGAN_QUIMBY@gmail.com kegan.quimby@gmail.com kegan.quimby@cisunix.unh.edu]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid  
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[keganquimby@gmail,com kegan_at_gmail.com kegan.quimby@gmail.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate emails" do
    User.create!(@attr)
    duplicate_email_user = User.new(@attr)
    duplicate_email_user.should_not be_valid
  end

  it "should reject same email with different case" do
    upcase_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcase_email))
    upcase_email_user = User.new(@attr)
    upcase_email_user.should_not be_valid
  end  

  describe "password validations" do
    it "should require a password" do
      blank_password = User.new(@attr.merge(:password => "", :password_confirmation => ""))
      blank_password.should_not be_valid
    end

    it "should require matching pw confirmation" do
      no_match = User.new(@attr.merge(:password_confirmation => "thisdoesntmatch"))
      no_match.should_not be_valid
    end

    it "should reject short passwords" do
      short_pw = "a" * 5
      short_pw_user = User.new(@attr.merge(:password => short_pw, :password_confirmation => short_pw))
      short_pw_user.should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      long_pw = @attr.merge(:password => long, :password_confirmation => long)
      User.new(long_pw).should_not be_valid
    end
  end  

  describe "password encryption" do
    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do
      it "should be true if passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end
        
      it "should be false if they dont match" do
        @user.has_password?("nomatch").should be_false
      end
    end

    describe "password authentication" do
    
      it "should return nil on mismatch" do
        mismatch_user = User.authenticate(@attr[:email], "wrongpass")
        mismatch_user.should be_nil
      end
      
      it "should return nil for an email address with no user" do
        no_email_user = User.authenticate("noemail@gmail.com", @attr[:password])
        no_email_user.should be_nil
      end
  
      it "should return user for match" do
        correct_user = User.authenticate(@attr[:email], @attr[:password])
        correct_user.should == @user
      end
    end
  end

  describe "admin attribute" do
    before(:each) do
      @user = User.create!(@attr)
    end

    it "should response to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin" do
      @user.should_not be_admin
    end

    it "should be convertable to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end

  describe "micropost associations" do
    before(:each) do
      @user = User.create(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)      
    end

    it "should have a micropost attribute" do
      @user.should respond_to(:microposts)
    end

    it "should have the right posts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end

    it "should destroy microposts upon user being deleted" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end

    describe "status feed" do

      it "should have a feed" do
        @user.should respond_to(:feed)
      end

      it "should include the user's microposts" do
        @user.feed.include?(@mp1).should be_true
        @user.feed.include?(@mp2).should be_true
      end

      it "should not include a different user's microposts" do
        mp3 = Factory(:micropost, :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.include?(mp3).should be_false
      end
    end
  end
end
end
