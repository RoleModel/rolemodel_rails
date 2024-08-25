# frozen_string_literal: true

# TailoredSelectInput is a custom input type for SimpleForm that renders a tailored select web component
#
# Options:
#   Any options available for SimpleForm's CollectionSelectInput (A.K.A a normal HTML select)
#
# Usage:
# <%= f.input :my_field, as: :tailored_select %>

module ActionView
  module Helpers
    class FormBuilder
      def tailored_select(method, collection, value_method, text_method, options = {}, html_options = {})
        @template.tailored_select(@object_name, method, collection, value_method, text_method,
                                  objectify_options(options), @default_html_options.merge(html_options))
      end
    end

    module FormOptionsHelper
      def tailored_select(object, method, collection, value_method, text_method, options = {}, html_options = {})
        Tags::TailoredSelect.new(object, method, self, collection, value_method, text_method, options,
                                 html_options).render
      end
    end

    module Tags
      class TailoredSelect < CollectionSelect
        private

        def select_content_tag(option_tags, options, html_options)
          html_options = html_options.stringify_keys
          %i[required multiple size].each do |prop|
            html_options[prop.to_s] = options.delete(prop) if options.key?(prop) && !html_options.key?(prop.to_s)
          end

          add_default_name_and_id(html_options)

          if placeholder_required?(html_options)
            if options[:include_blank] == false
              raise ArgumentError,
                    'include_blank cannot be false for a required field.'
            end

            options[:include_blank] ||= true unless options[:prompt]
          end

          value = options.fetch(:selected) { value() }
          # For real, this is the only line that changed from CollectionSelect, just changed the tag name
          select = content_tag('tailored-select', add_options(option_tags, options, value), html_options)

          if html_options['multiple'] && options.fetch(:include_hidden, true)
            tag('input', disabled: html_options['disabled'], name: html_options['name'], type: 'hidden', value: '',
                         autocomplete: 'off') + select
          else
            select
          end
        end
      end
    end
  end
end

class TailoredSelectInput < SimpleForm::Inputs::CollectionSelectInput
  def input(wrapper_options = nil)
    @builder.tailored_select(
      attribute_name, collection, *detect_collection_methods.reverse, input_options,
      merge_wrapper_options(input_html_options, wrapper_options)
    )
  end

  def input_html_classes
    []
  end
end
