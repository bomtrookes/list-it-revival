class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @lists = List.followings_lists(current_user.followings.ids).includes(:user, :items, :votes, :tags, photo_attachment: :blob) if current_user
  end

end
