module DynamicLinkHelper
  def panel_link_to(name, url, classes = nil)
    link_to(name, url, class: classes, data: { remote: true, panel: true })
  end

  def modal_link_to(name, url, classes = nil)
    link_to(name, url, class: classes, data: { remote: true, modal: true })
  end
end
