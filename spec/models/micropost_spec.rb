require 'spec_helper'

describe Micropost do
  before(:each) do
    @user = Factory(:user)
    @attr = { :content => "blah blah no one cares" }
  end

  it "should create a new instance given valid attributes" do
    @user.microposts.create!(@attr)
  end

  describe "user associations" do
    before(:each) do
      @micropost = @user.microposts.create(@attr)
    end

    it "should have a user attribute" do
      @micropost.should respond_to(:user)
    end

    it "should have the right associated user" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end
  end

  describe "validations" do
    it "should have a user" do
      Micropost.new(@attr).should_not be_valid
    end

    it "shouldn't be blank" do
      @user.microposts.build(:content => " ").should_not be_valid
    end

    it "should be no more than 140 chars" do
      @user.microposts.build(:content => "a" * 141).should_not be_valid     
    end
  end
end
