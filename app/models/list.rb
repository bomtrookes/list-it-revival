class List < ApplicationRecord
  belongs_to :user

  include HasPhoto

  has_many :items, -> { ordered }, dependent: :destroy
  has_many :favourite_lists, dependent: :destroy
  has_many :favoriters, through: :favourite_lists, source: :user
  has_many :votes, dependent: :destroy
  has_many :voters, through: :votes, source: :user

  # gem tags
  acts_as_taggable_on :tags

  validates :title, presence: true, length: { minimum: 2 }
  validates :user_id, presence: true
  validates :published, inclusion: [true, false]

  # Search Users, Lists, Tags
  include PgSearch::Model
  pg_search_scope :global_search,
    against: [:title],
    associated_against: {
      user: [:username],
      tags: [:name]
    },
    using: { tsearch: { prefix: true, dictionary: "english" } }

  pg_search_scope :search_list, against: [:title], using: { tsearch: { prefix: true, dictionary: "english" } }
  pg_search_scope :search_tag, associated_against: { tags: [:name] }, using: { tsearch: { prefix: true } }

  def self.ordered_published_lists
    where('published = ?', true).left_joins(:votes).group(:id).order('COUNT(votes.id) DESC')
  end

  def self.published_lists
    where('published = ?', true)
  end

  def self.followings_lists(following)
    where(user_id: following, published: true).order('created_at DESC')
  end

  # A user's profile order: lists they've arranged by dragging, with newer unarranged lists on top
  def self.newest_published(user)
    where(user_id: user, published: true).profile_order
  end

  def self.profile_order
    order(Arel.sql("lists.position ASC NULLS FIRST, lists.created_at DESC"))
  end

end
