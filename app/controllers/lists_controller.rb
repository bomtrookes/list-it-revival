class ListsController < ApplicationController
  before_action :set_user, only: [:new, :create, :publish, :article, :show, :destroy]
  before_action :find_list, only: [:show, :edit, :update, :destroy, :publish, :article]
  before_action :authorize_list!, only: [:edit, :update, :destroy, :publish, :article]

  def index
    # search
    if params[:query].present?
      top_lists = List.published_lists.global_search(params[:query])
      @top_lists = top_lists.sort_by {|list| list.votes.size }.reverse!
      search_lists = List.published_lists.search_list(params[:query])
      @search_lists = search_lists.sort_by {|list| list.votes.size }.reverse!
      search_users = User.search_user(params[:query])
      @search_users = search_users.sort_by {|user| user.lists.size }.reverse!
      search_tags = ActsAsTaggableOn::Tag.where("name ILIKE ?", "#{params[:query]}%")
      @search_tags = search_tags.sort_by {|tag| tagged_lists(tag).size }.reverse!
    else
      @top_lists = List.ordered_published_lists.includes(:user, :items, :votes, :tags, photo_attachment: :blob)
      @search_lists = []
      @search_users = []
      @search_tags = []
    end
  end

  def new
    @list = List.new
    @item = Item.new
  end

  def create
    @list = List.new(list_params)
    @list.user = current_user
    if @list.save
      redirect_to user_list_path(user_id: current_user, id: @list)
    else
      render :new, status: :unprocessable_entity
    end
  end

  # read individual lists
  def show
    # Drafts are only visible to their owner (and admins)
    return redirect_to(root_path, alert: "That list isn't published yet.") if !@list.published && !can_manage?(@list)

    @item = Item.new
    @related_lists = @list.find_related_tags
    @following = current_user.followings.find_by(id: @user.id)
    @fav = current_user.favourite_lists.find_by(list_id: @list.id)
    @vote = current_user.votes.find_by(list_id: @list.id)
  end

  def edit
  end

  def update
    # @list.update(list_params)
    # redirect_to @list
    if @list.update(list_params)
      respond_to do |format|
        format.html { redirect_to user_list_path(user_id: current_user, id: @list) }
        format.text { render partial: "lists", locals: { title: @list, tag_list: @tag_list }, formats: [:html] }
      end
      flash[:notice] = "Updated!"
    else
      flash[:notice] = "Invalid"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @list.destroy

    redirect_to user_path(current_user)
  end

  def publish
    @list.published = true
    @list.save
    redirect_to user_path(@user)
  end

  def article
    if @list.article == false
      @list.article = true
    else
      @list.article = false
    end
    @list.save
    redirect_to user_list_path(user_id: current_user, id: @list)
  end

  # Drag-and-drop order of a user's published lists on their profile
  def sort
    user = User.find(params[:user_id])
    return head(:forbidden) unless user == current_user || current_user.admin?

    ids = Array(params[:ids]).map(&:to_i)
    lists = user.lists.where(id: ids).index_by(&:id)
    List.transaction do
      ids.each_with_index { |id, index| lists[id]&.update_column(:position, index + 1) }
    end
    head :no_content
  end

  def tagged
    if params[:tag].present?
      @lists = List.published_lists.tagged_with(params[:tag]).sort_by {|list| list.votes.size }.reverse!
      @tag = params[:tag]
    else
      @lists = List.all
    end
  end

  private

  def find_list
    @list = List.find(params[:id])
  end

  def list_params
    params.require(:list).permit(:title, :id, :tag_list, :photo, :article)
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def authorize_list!
    require_owner!(@list)
  end

  def tagged_lists(tag)
    List.tagged_with(tag)
  end

end
