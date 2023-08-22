module TurboFrameLinkHelper
  def panel_link_to(name, url=nil, options={}, &block)
    frame_link_helper('panel', name, url, options, &block)
  end

  def modal_link_to(name, url=nil, options={}, &block)
    frame_link_helper('modal', name, url, options, &block)
  end

  private

  def frame_link_helper(frame, name, url, options, &block)
    data_option = { data: options.fetch(:data, {}).reverse_merge({ turbo_frame: frame }) }

    if block_given?
      link_to(name, (url || {}).merge(data_option), &block)
    else
      link_to(name, url, options.merge(data_option))
    end
  end
end
