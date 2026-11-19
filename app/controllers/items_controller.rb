class ItemsController < ApplicationController
  before_action :find_item, only: [:update, :destroy]

  def create
    list = List.find(params[:item][:list_id])
    return require_owner!(list) unless can_manage?(list)

    @item = list.items.new(item_params)
    flash[:notice] = "Invalid" unless @item.save
    redirect_to user_list_path(user_id: list.user, id: list)
  end

  def update
    return require_owner!(@item.list) unless can_manage?(@item.list)

    if @item.update(item_params)
      respond_to do |format|
        format.html { redirect_to user_list_path(user_id: @item.list.user, id: @item.list) }
        format.text { render partial: "lists/item_infos", locals: { item: @item, list: @item.list }, formats: [:html] }
      end
      flash[:notice] = "Updated!"
    else
      flash[:notice] = "Invalid"
      redirect_to user_list_path(user_id: @item.list.user, id: @item.list)
    end
  end

  def destroy
    return require_owner!(@item.list) unless can_manage?(@item.list)

    @item.destroy
    redirect_back fallback_location: user_list_path(user_id: @item.list.user, id: @item.list)
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :photo)
  end

  def find_item
    @item = Item.find(params[:id])
  end
end
