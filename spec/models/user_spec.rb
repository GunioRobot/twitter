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
    @attr = { :name => "Kegan Quimby", :email => "keganquimby@gmail.com" }
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
    no_name_user.should_not be_valid
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
      invalid_email_user.should be_valid
    end
  end

  it "should reject duplicate emails" do
    User.create!(@attr)
    duplicate_email_user = User.new!(@attr)
    duplicate_email_user.should_not be_valid
  end

  it "should reject same email with different case" do
    upcase_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcase_email))
    upcase_email_user = User.new(@attr)
    upcase_email_user.should_not be_valid
  end    

end
