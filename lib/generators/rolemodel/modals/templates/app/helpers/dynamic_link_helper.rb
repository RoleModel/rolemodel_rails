module DynamicLinkHelper
  def panel_link_to(name, url, options)
    link_to(name, url, options.merge(data: { turbo_frame: 'panel' }))
  end

  def modal_link_to(name, url, options)
    link_to(name, url, options.merge(data: { turbo_frame: 'modal' }))
  end
end
