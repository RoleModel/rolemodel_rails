# frozen_string_literal: true

class MarkdownInput < SimpleForm::Inputs::Base
  include ActionView::Context
  include ApplicationHelper

  def initialize(*args)
    super

    # Ensure an id is present
    @input_html_options[:id] ||= "#{object_name}_#{attribute_name}"
  end

  # rubocop:disable Rails/ContentTag
  def input(wrapper_options = nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    content_tag('markdown-toolbar', for: merged_input_options[:id]) do
      content_tag('md-bold', icon('format_bold', title: 'Bold')) +
        content_tag('md-header', icon('format_size', title: 'Header')) +
        content_tag('md-italic', icon('format_italic', title: 'Italic')) +
        content_tag('md-quote', icon('format_quote', title: 'Quote')) +
        content_tag('md-link', icon('insert_link', title: 'Link')) +
        content_tag('md-image', icon('insert_photo', title: 'Image')) +
        content_tag('md-unordered-list', icon('format_list_bulleted', title: 'Bulleted List')) +
        content_tag('md-ordered-list', icon('format_list_numbered', title: 'Numbered List'))
    end +
      @builder.text_area(attribute_name, merged_input_options)
  end
  # rubocop:enable Rails/ContentTag
end
