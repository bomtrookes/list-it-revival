# The fake community from the original 2022 project (users, lists, items, votes and pins),
# so the site and the demo have something to look at. Lists credited to @bomtrookes go to
# Tom's real account if it already exists.
class SampleCommunity
  def self.loaded?
    User.where(sample: true).exists?
  end

  # Loading the samples and resetting the demo both write tags. Running them at the
  # same time (e.g. the demo-reset container kicking in mid-load) deadlocks Postgres,
  # so both take the same advisory lock and wait for each other instead.
  LOCK_KEY = 5_478_271

  def self.with_lock
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute("SELECT pg_advisory_xact_lock(#{LOCK_KEY})")
      yield
    end
  end

  def self.load!
    with_lock do
      return if loaded? # someone else finished loading while we waited
      existing_ids = User.pluck(:id)
      load Rails.root.join("db/seeds/sample_community.rb")
      User.where.not(id: existing_ids).where(admin: false, demo: false).update_all(sample: true)
    end
  end
end
