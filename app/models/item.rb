class Item < ApplicationRecord
  include HasPhoto

  belongs_to :list

  validates :name, presence: true, length: { minimum: 1 }
  validates :list_id, presence: true
  validates :description, length: { maximum: 200 }, allow_blank: true

  before_create :place_at_bottom

  scope :ordered, -> { order(Arel.sql("items.position ASC NULLS LAST, items.id ASC")) }

  private

  def place_at_bottom
    self.position ||= (Item.where(list_id: list_id).maximum(:position) || Item.where(list_id: list_id).count) + 1
  end
end
