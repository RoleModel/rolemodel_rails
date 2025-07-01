module TurboFrameLinkHelper
  def panel_link_to(...)
    link_to_frame('panel', ...)
  end

  def modal_link_to(...)
    link_to_frame('modal', ...)
  end

  def link_to_top(...)
    link_to_frame('_top', ...)
  end

  def link_to_frame(frame, name, url, options = {}, &)
    data_option = { data: options.fetch(:data, {}).reverse_merge({ turbo_frame: frame }) }

    if block_given?
      link_to(name, (url || {}).merge(data_option), &)
    else
      link_to(name, url, options.merge(data_option))
    end
  end
end
