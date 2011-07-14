class UsersController < ApplicationController
  
  def show
    @user = User.find(params[:id])
    @title = @user.name
  end

  def new
    @title = "Sign Up"
    @user = User.new    
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:succcess] = "Welcome to Twitter!"
      redirect_to @user
    else
      @title = "Sign Up"
      render 'new'
    end
  end

end

