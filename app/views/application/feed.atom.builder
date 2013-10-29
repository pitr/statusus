atom_feed do |feed|
  feed.title "#{@user.app_name} Status"
  feed.updated @user.messages.maximum(:updated_at)

  @user.messages.each do |message|
    feed.entry message, id: message.guid, published: message.updated_at, url: root_url do |entry|
      entry.title Message::STATUSES.invert[message.status]
      entry.content message.text
      # entry.pubDate message.updated_at.to_s(:rfc822)
      # entry.link root_url
      # entry.guid message.guid
    end
  end
end
