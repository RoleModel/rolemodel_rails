require 'spec_helper'
require 'action_view/helpers'
require 'generators/rolemodel/ui_components/modals/templates/app/helpers/turbo_frame_link_helper.rb'

RSpec.describe TurboFrameLinkHelper, type: :helper do
  include ActionView::Helpers
  include TurboFrameLinkHelper

  let(:text) { { input: 'My Link', output: 'My Link' } }
  let(:path) { { input: '/path', output: 'href="/path"' } }
  let(:classes) { { input: { class: ['always--class', 'true--class' => true, 'false--class' => false] }, output: 'class="always--class true--class"' } }
  let(:data) { { input: { data: { foo: 'bar' } }, output: 'data-foo="bar"' } }
  let(:disabled) { { input: { disabled: true }, output: 'disabled="disabled"' } }

  let(:turbo_frame) { { modal: 'data-turbo-frame="modal"', panel: 'data-turbo-frame="panel"', top: 'data-turbo-frame="_top"' } }

  context 'with a block' do
    context 'with various options' do
      it 'generates the correct modal link HTML' do
        options = classes[:input].merge(data[:input])

        expect(
          modal_link_to(path[:input], options) { tag.i(text[:input]) }
        ).to eq(
          "<a #{classes[:output]} #{turbo_frame[:modal]} #{data[:output]} #{path[:output]}><i>#{text[:output]}</i></a>"
        )
      end

      it 'generates the correct panel link HTML' do
        options = data[:input].merge(disabled[:input])

        expect(
          panel_link_to(path[:input], options) { text[:input] }
        ).to eq(
          "<a #{disabled[:output]} #{turbo_frame[:panel]} #{data[:output]} #{path[:output]}>#{text[:output]}</a>"
        )
      end

      it 'generates the correct top link HTML' do
        options = classes[:input].merge(disabled[:input]).merge(data[:input])

        expect(
          link_to_top(path[:input], options) { tag.div(text[:input], class: 'text--class') }
        ).to eq(
          "<a #{classes[:output]} #{disabled[:output]} #{turbo_frame[:top]} #{data[:output]} #{path[:output]}><div class=\"text--class\">#{text[:output]}</div></a>"
        )
      end
    end

    context 'with no options' do
      it 'generates the correct modal link HTML' do
        expect(
          modal_link_to(path[:input]) { text[:input] }
        ).to eq(
          "<a #{turbo_frame[:modal]} #{path[:output]}>#{text[:output]}</a>"
        )
      end

      it 'generates the correct panel link HTML' do
        expect(
          panel_link_to(path[:input]) { tag.div(text[:input], **classes[:input]) }
        ).to eq(
          "<a #{turbo_frame[:panel]} #{path[:output]}><div #{classes[:output]}>#{text[:output]}</div></a>"
        )
      end

      it 'generates the correct top link HTML' do
        expect(
          link_to_top(path[:input]) { text[:input] }
        ).to eq(
          "<a #{turbo_frame[:top]} #{path[:output]}>#{text[:output]}</a>"
        )
      end
    end
  end

  context 'without a block' do
    context 'with various options' do
      it 'generates the correct modal link HTML' do
        expect(
          modal_link_to(text[:input], path[:input], classes[:input])
        ).to eq(
          "<a #{classes[:output]} #{turbo_frame[:modal]} #{path[:output]}>#{text[:output]}</a>"
        )
      end

      it 'generates the correct panel link HTML' do
        options = data[:input].merge(disabled[:input])

        expect(
          panel_link_to(text[:input], path[:input], options)
        ).to eq(
          "<a #{disabled[:output]} #{turbo_frame[:panel]} #{data[:output]} #{path[:output]}>#{text[:output]}</a>"
        )
      end

      it 'generates the correct top link HTML' do
        options = classes[:input].merge(disabled[:input]).merge(data[:input])

        expect(
          link_to_top(text[:input], path[:input], options)
        ).to eq(
          "<a #{classes[:output]} #{disabled[:output]} #{turbo_frame[:top]} #{data[:output]} #{path[:output]}>#{text[:output]}</a>"
        )
      end
    end

    context 'with no options' do
      it 'generates the correct modal link HTML' do
        expect(
          modal_link_to(text[:input], path[:input])
        ).to eq(
          "<a #{turbo_frame[:modal]} #{path[:output]}>#{text[:output]}</a>"
        )
      end

      it 'generates the correct panel link HTML' do
        expect(
          panel_link_to(text[:input], path[:input])
        ).to eq(
          "<a #{turbo_frame[:panel]} #{path[:output]}>#{text[:output]}</a>"
        )
      end

      it 'generates the correct top link HTML' do
        content = tag.div(text[:input], **classes[:input])

        expect(
          link_to_top(content, path[:input])
        ).to eq(
          "<a #{turbo_frame[:top]} #{path[:output]}><div #{classes[:output]}>#{text[:output]}</div></a>"
        )
      end
    end
  end
end
