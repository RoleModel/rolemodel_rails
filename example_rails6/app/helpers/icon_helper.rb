module IconHelper
  def icon(name, classes: nil, color: nil, hover_text: nil)
    tag.span(name, class: "material-icons #{classes}", style: "color: var(--color-#{color})", title: hover_text)
  end
end
