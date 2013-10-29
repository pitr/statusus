xml.instruct! :xml, verion: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title "#{@user.app_name} Status"
    xml.description "Status of #{@user.app_name}"
    xml.link root_url

    @user.messages.each do |message|
      xml.item do
        xml.title Message::STATUSES.invert[message.status]
        xml.description message.text
        xml.pubDate message.updated_at.to_s(:rfc822)
        xml.link root_url
        xml.guid message.guid
      end
    end
  end
end
