json.array!(@messages) { |message|
  json.status message.status
  json.message message.message
}
