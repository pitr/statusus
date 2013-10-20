module ApplicationHelper
  def class_for_status(status)
    case status
    when 0
      'good'
    when 1
      'minor'
    when 2
      'major'
    end
  end
end
