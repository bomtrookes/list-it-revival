module Admin
  # Admin-only page for creating and managing logins for friends.
  class UsersController < ApplicationController
    before_action :require_admin!
    before_action :set_user, only: [:edit, :update, :destroy]

    def index
      load_users
    end

    def new
      @user = User.new(password: generate_password)
    end

    def create
      @user = User.new(user_params)
      if @user.save
        @created_password = user_params[:password]
        flash.now[:notice] = "Login created for @#{@user.username}."
        load_users
        render :index
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      attrs = user_params.to_h
      attrs.delete("password") if attrs["password"].blank?
      attrs.delete("admin") if @user == current_user # don't lock yourself out
      if @user.update(attrs)
        redirect_to admin_users_path, notice: "Updated @#{@user.username}."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path, alert: "You can't delete your own account."
      elsif @user.demo?
        redirect_to admin_users_path, alert: "The demo account can't be deleted. Reset it with bin/rails demo:reset."
      else
        @user.destroy
        redirect_to admin_users_path, notice: "Deleted @#{@user.username}."
      end
    end

    private

    def load_users
      @show_sample = params[:sample] == "1"
      @sample_count = User.where(sample: true).count
      scope = @show_sample ? User.all : User.where(sample: false)
      @users = scope.includes(:lists).order(admin: :desc, demo: :asc, sample: :asc, created_at: :desc)
    end

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:username, :email, :password, :admin)
    end

    def generate_password
      SecureRandom.alphanumeric(12)
    end
  end
end
