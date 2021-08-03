module IconHelper
  def icon(name, classes: nil, color: nil, hover_text: name)
    contents = custom_icon(name) || name

    tag.span(contents, class: icon_classes(classes, custom_icon(name)), style: "color: var(--color-#{color})", title: hover_text)
  end

  private

  def icon_classes(classes, is_custom)
    icon_class = is_custom ? 'custom-icons' : 'material-icons'

    classes.present? ? classes.prepend("#{icon_class} ") : icon_class
  end

  def custom_icon(name)
    # Check for a custom SVG icon matching the given name.
    custom_icon_path = Webpacker.manifest.lookup("media/images/icons/#{name}.svg")
    return if custom_icon_path.blank?

    custom_icon_contents = load_svg_from_file_or_dev_server(custom_icon_path)

    # These SVG files can safely be marked html_safe since we created them and
    # they are part of this app's code.
    custom_icon_contents.html_safe # rubocop:disable Rails/OutputSafety
  end

  def load_svg_from_file_or_dev_server(custom_icon_path)
    # Read in SVG file. Needs special handling for the webpack dev server
    # because that doesn't write out any of the files.
    if Webpacker.dev_server.running?
      dev_server = Webpacker.dev_server
      custom_icon_path.slice!("#{dev_server.protocol}://#{dev_server.host_with_port}")
      connection = URI.open("#{dev_server.protocol}://#{dev_server.host_with_port}#{custom_icon_path}")
      contents = connection.read
      connection.close
      contents
    else
      File.read(File.join(Webpacker.config.public_path, custom_icon_path))
    end
  end
end
