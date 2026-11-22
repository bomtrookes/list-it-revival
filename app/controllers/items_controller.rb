class ItemsController < ApplicationController
  before_action :find_item, only: [:update, :destroy]

  def create
    list = List.find(params[:item][:list_id])
    return require_owner!(list) unless can_manage?(list)

    @item = list.items.new(item_params)
    flash[:alert] = @item.errors.full_messages.to_sentence unless @item.save
    redirect_to user_list_path(user_id: list.user, id: list)
  end

  def update
    return require_owner!(@item.list) unless can_manage?(@item.list)

    if @item.update(item_params)
      respond_to do |format|
        format.html { redirect_to user_list_path(user_id: @item.list.user, id: @item.list), notice: "Updated!" }
        format.text { render partial: "lists/item_infos", locals: { item: @item, list: @item.list }, formats: [:html] }
      end
    else
      message = @item.errors.full_messages.to_sentence
      respond_to do |format|
        format.html { redirect_to user_list_path(user_id: @item.list.user, id: @item.list), alert: message }
        format.text { render plain: message, status: :unprocessable_entity }
      end
    end
  end

  # Drag-and-drop ranking of the items in a list
  def sort
    list = List.find(params[:list_id])
    return head(:forbidden) unless can_manage?(list)

    ids = Array(params[:ids]).map(&:to_i)
    items = list.items.where(id: ids).index_by(&:id)
    Item.transaction do
      ids.each_with_index { |id, index| items[id]&.update_column(:position, index + 1) }
    end
    head :no_content
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
