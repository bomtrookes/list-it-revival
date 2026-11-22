# A single resized photo. Pages show the small "card" or "large" versions instead of the
# original upload, and uploads are checked for type and size.
module HasPhoto
  extend ActiveSupport::Concern

  MAX_SIZE = 10.megabytes
  CONTENT_TYPES = %w[image/jpeg image/png image/webp image/gif].freeze

  included do
    has_one_attached :photo do |photo|
      photo.variant :card,  resize_to_limit: [800, 800],   saver: { quality: 80, strip: true }
      photo.variant :large, resize_to_limit: [1400, 1400], saver: { quality: 82, strip: true }
    end

    validate :photo_is_a_reasonable_image
  end

  private

  def photo_is_a_reasonable_image
    return unless attachment_changes["photo"] && photo.attached?

    if CONTENT_TYPES.exclude?(photo.blob.content_type)
      errors.add(:photo, "must be a JPEG, PNG, WebP or GIF image")
    elsif photo.blob.byte_size > MAX_SIZE
      errors.add(:photo, "is too big (the limit is #{MAX_SIZE / 1.megabyte} MB)")
    end
  end
end
