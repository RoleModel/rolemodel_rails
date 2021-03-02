module DynamicLinkHelper
  def panel_link_to(name, url, options)
    link_to(name, url, options.merge(data: { remote: true, panel: true }))
  end

  def modal_link_to(name, url, options)
    link_to(name, url, options.merge(data: { remote: true, modal: true }))
  end
end
