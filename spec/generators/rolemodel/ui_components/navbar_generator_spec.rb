RSpec.describe Rolemodel::UiComponents::NavbarGenerator, type: :generator do
  destination File.expand_path('../../tmp/', File.dirname(__FILE__))

  let(:run_flash_generator_first) { false }
  let(:run_modal_generator_first) { false }

  before { run_generators_against_test_app(generators:) }

  let(:generators) do
    [
      ::Rolemodel::SlimGenerator,
      ::Rolemodel::WebpackGenerator,
      ::Rolemodel::Optics::BaseGenerator,
      (::Rolemodel::UiComponents::FlashGenerator if run_flash_generator_first),
      (::Rolemodel::Turbo::ModalsGenerator if run_modal_generator_first),
      described_class
    ].compact
  end

  it 'adds the navbar file' do
    assert_file 'app/views/application/_navbar.html.slim'
    assert_file 'app/javascript/lib/shoelace.js'
    assert_file 'app/assets/stylesheets/components/shoelace/index.css'

    assert_file 'app/views/layouts/application.html.slim' do |content|
      expect(content).to include("= render 'navbar'")
    end

    assert_file 'app/assets/stylesheets/application.css' do |content|
      expect(content).to include("@import 'components/shoelace/index.css';")
    end

    assert_file 'app/javascript/application.js' do |content|
      expect(content).to include("import './lib/shoelace.js'")
    end
  end

  context 'if the modal and flash have already been installed' do
    let(:run_flash_generator_first) { true }
    let(:run_modal_generator_first) { true }

    it 'places the render below flash and modals' do
      assert_file 'app/views/layouts/application.html.slim' do |content|
        flash_index = content.index("= render 'flash'")
        modal_index = content.index("turbo_frame_tag 'modal'")
        navbar_index = content.index("= render 'navbar'")

        expect(navbar_index).to be > modal_index
        expect(navbar_index).to be > flash_index
      end
    end
  end
end
