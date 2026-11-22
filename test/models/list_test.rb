require "test_helper"

class ListTest < ActiveSupport::TestCase
  test "search matches partial words and plurals" do
    user = User.create!(username: "searcher", email: "s@example.com", password: "password123")
    list = user.lists.create!(title: "Films everyone should see once", published: true)
    assert_includes List.global_search("film"), list
    assert_includes List.global_search("Fil"), list
  end
end
