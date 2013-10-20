json.(message, :id, :status, :text)
json.created_at message.created_at.to_s(:short)
