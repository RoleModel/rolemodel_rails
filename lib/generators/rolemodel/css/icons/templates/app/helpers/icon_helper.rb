module IconHelper
  def icon(name, classes: nil, color: nil, hover_text: name)
    using_custom_icon = custom?(name)
    contents = using_custom_icon ? custom_content(name) : name

    tag.span(contents, class: classes(classes, using_custom_icon), style: "color: var(--color-#{color})", title: hover_text)
  end

  private

  def classes(classes, using_custom_icon)
    icon_class = using_custom_icon ? 'custom-icons' : 'material-icons'

    "#{icon_class} #{classes}"
  end

  def custom_icon_path(name)
    Webpacker.manifest.lookup("media/images/icons/#{name}.svg")
  end

  def custom?(name)
    custom_icon_path(name).present?
  end

  def custom_content(name)
    custom_icon_contents = load_svg_from_file_or_dev_server(custom_icon_path(name))

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
