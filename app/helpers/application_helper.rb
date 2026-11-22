module ApplicationHelper
  def hide_button(user)
    user.id == current_user.id
  end

  def format_username(username)
    '@' + username
  end

  def format_tag(tag)
    '#' + tag
  end

  def published_lists(user)
    List.published_lists.where(user_id: user.id)
  end

  # URL for a resized version of a list or item photo (:card or :large)
  def photo_url(attachment, size = :card)
    attachment.variable? ? url_for(attachment.variant(size)) : url_for(attachment)
  end

  # File field options for photos: opens the photo library / camera on phones and
  # shrinks big photos before upload (photo_upload_controller.js)
  def photo_input_html
    { accept: "image/*", data: { controller: "photo-upload", action: "change->photo-upload#resize" } }
  end
end
