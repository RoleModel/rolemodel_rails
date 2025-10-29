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

  def link_to_frame(frame, *attrs, &)
    options = attrs.extract_options!
    data = options.delete(:data){ {} }.reverse_merge({turbo_frame: frame})

    link_to(*attrs, options.merge(data:), &)
  end
end
