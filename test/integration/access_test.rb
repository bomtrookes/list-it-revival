require "test_helper"

class AccessTest < ActionDispatch::IntegrationTest
  test "public sign-up is closed" do
    post "/users", params: { user: { email: "new@example.com", password: "password123", username: "newbie" } }
    assert_response :not_found
    assert_not User.exists?(email: "new@example.com")
  end

  test "admin can create a login" do
    sign_in create_user(admin: true)
    get new_admin_user_path
    assert_response :success

    post admin_users_path, params: { user: { username: "friend", email: "friend@example.com", password: "secret123" } }
    assert_response :success
    assert_match "secret123", response.body
    assert User.find_by(email: "friend@example.com").valid_password?("secret123")
  end

  test "non-admins cannot reach the admin page" do
    sign_in create_user
    get admin_users_path
    assert_redirected_to root_path
    post admin_users_path, params: { user: { username: "sneaky", email: "sneaky@example.com", password: "secret123" } }
    assert_not User.exists?(email: "sneaky@example.com")
  end

  test "admin cannot delete themselves" do
    admin = create_user(admin: true)
    sign_in admin
    delete admin_user_path(admin)
    assert User.exists?(admin.id)
  end

  test "visitors can try the demo and it resets" do
    DemoAccount.reset!
    post demo_session_path
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success

    demo = User.demo_user
    get edit_user_registration_path
    assert_redirected_to user_path(demo)

    demo.lists.create!(title: "Visitor graffiti", published: true)
    DemoAccount.reset!
    assert_not demo.reload.lists.exists?(title: "Visitor graffiti")
    assert_equal DemoAccount::STARTER_LISTS.size, demo.lists.count
  end

  test "users can only change their own lists" do
    owner = create_user
    list = owner.lists.create!(title: "Mine", published: true)
    item = list.items.create!(name: "Thing")

    sign_in create_user
    patch user_list_path(owner, list), params: { list: { title: "Hacked" } }
    delete user_list_path(owner, list)
    delete list_item_path(list, item)
    post items_path, params: { item: { name: "Spam", list_id: list.id } }

    assert_equal "Mine", list.reload.title
    assert Item.exists?(item.id)
    assert_equal 1, list.items.count
  end

  test "drafts are hidden from other users" do
    owner = create_user
    draft = owner.lists.create!(title: "Secret draft", published: false)
    sign_in create_user
    get user_list_path(owner, draft)
    assert_redirected_to root_path
  end
end
