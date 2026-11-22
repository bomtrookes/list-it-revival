# The fake community from the original 2022 project (users, lists, items, votes and pins),
# so the site and the demo have something to look at. Lists credited to @bomtrookes go to
# Tom's real account if it already exists.
class SampleCommunity
  def self.loaded?
    User.where(sample: true).exists?
  end

  def self.load!
    existing_ids = User.pluck(:id)
    ActiveRecord::Base.transaction do
      load Rails.root.join("db/seeds/sample_community.rb")
      User.where.not(id: existing_ids).where(admin: false, demo: false).update_all(sample: true)
    end
  end
end
