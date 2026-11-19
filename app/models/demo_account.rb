# The shared demo account that visitors use via "Try the demo".
# DemoAccount.reset! wipes whatever visitors did with it and puts back starter content.
class DemoAccount
  USERNAME = "demo".freeze

  STARTER_LISTS = [
    {
      title: "Films everyone should see once",
      tags: "films, classics",
      items: [
        ["Spirited Away", "Hand-drawn wonder from Studio Ghibli."],
        ["The Godfather", "An offer you can't refuse."],
        ["Paddington 2", "Somehow the most wholesome film ever made."]
      ]
    },
    {
      title: "Best snacks for a long train ride",
      tags: "food, travel",
      items: [
        ["Salt and vinegar crisps", "Non-negotiable."],
        ["Clementines", "Easy to peel, smells great."],
        ["Flapjack", "Fuel for the whole journey."]
      ]
    }
  ].freeze

  def self.user
    User.demo_user
  end

  def self.reset!
    demo = User.find_or_initialize_by(demo: true)
    demo.assign_attributes(
      username: USERNAME,
      email: User::DEMO_EMAIL,
      bio: "This is the demo account. Have a look around, make a list, vote and pin. Everything resets regularly.",
      avatar: nil,
      admin: false
    )
    demo.password = SecureRandom.hex(24) # nobody logs in with a password; "Try the demo" signs in directly
    demo.save!

    User.transaction do
      demo.lists.destroy_all
      demo.votes.destroy_all
      demo.favourite_lists.destroy_all
      Follow.where(follower_id: demo.id).or(Follow.where(followed_id: demo.id)).delete_all

      STARTER_LISTS.each do |data|
        list = demo.lists.create!(title: data[:title], published: true, tag_list: data[:tags])
        data[:items].each { |name, description| list.items.create!(name: name, description: description) }
      end

      # Follow a handful of active users so the feed has something in it
      others = User.where(demo: false).joins(:lists).where(lists: { published: true }).distinct.limit(8)
      others.each { |user| Follow.create!(follower_id: demo.id, followed_id: user.id) }
    end

    demo
  end
end
