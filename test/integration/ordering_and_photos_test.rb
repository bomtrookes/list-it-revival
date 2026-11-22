require "test_helper"

class OrderingAndPhotosTest < ActionDispatch::IntegrationTest
  setup do
    @owner = create_user
    @list = @owner.lists.create!(title: "Best things", published: true)
    @items = %w[One Two Three].map { |name| @list.items.create!(name: name) }
  end

  test "new items go to the bottom" do
    assert_equal %w[One Two Three], @list.reload.items.map(&:name)
  end

  test "owner can reorder items and the order is shown to everyone" do
    sign_in @owner
    patch sort_list_items_path(@list), params: { ids: @items.reverse.map(&:id) }, as: :json
    assert_response :no_content
    assert_equal %w[Three Two One], @list.reload.items.map(&:name)

    sign_out @owner
    sign_in create_user
    get user_list_path(@owner, @list)
    assert_response :success
    assert_operator response.body.index("Three"), :<, response.body.index("One")
  end

  test "others cannot reorder someone else's items" do
    sign_in create_user
    patch sort_list_items_path(@list), params: { ids: @items.reverse.map(&:id) }, as: :json
    assert_response :forbidden
    assert_equal %w[One Two Three], @list.reload.items.map(&:name)
  end

  test "owner can reorder their lists on their profile" do
    other = @owner.lists.create!(title: "Second list", published: true)
    sign_in @owner
    patch sort_user_lists_path(@owner), params: { ids: [@list.id, other.id] }, as: :json
    assert_response :no_content
    assert_equal [@list.id, other.id], List.newest_published(@owner).ids

    patch sort_user_lists_path(@owner), params: { ids: [other.id, @list.id] }, as: :json
    assert_equal [other.id, @list.id], List.newest_published(@owner).ids
  end

  test "others cannot reorder someone else's lists" do
    sign_in create_user
    patch sort_user_lists_path(@owner), params: { ids: [@list.id] }, as: :json
    assert_response :forbidden
  end

  test "photos must be images under the size limit" do
    @list.photo.attach(io: StringIO.new("not an image"), filename: "notes.txt", content_type: "text/plain")
    assert_not @list.valid?
    assert_match "JPEG", @list.errors[:photo].first

    big = @owner.lists.new(title: "Big photo")
    big.photo.attach(io: StringIO.new("x" * (HasPhoto::MAX_SIZE + 1)), filename: "big.jpg", content_type: "image/jpeg")
    assert_not big.valid?
    assert_match "too big", big.errors[:photo].first
  end

  test "list pages show resized photos" do
    png = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==")
    @list.photo.attach(io: StringIO.new(png), filename: "dot.png", content_type: "image/png")
    @list.save!
    sign_in @owner
    get user_list_path(@owner, @list)
    assert_response :success
    assert_match "/rails/active_storage/representations/", response.body
  end
end
