module ApplicationHelper
  def icon_name_for_flash(type)
    case type
    when 'notice'
      'check_circle'
    when 'alert'
      'cancel'
    else
        type
    end
  end
end
