RSpec.describe Rolemodel::GoodJobGenerator, type: :generator do
  # The full generator needs the good_job gem installed. This runs only the configuration step.
  let(:production_rb) { File.join(destination_root, 'config/environments/production.rb') }

  def configure_good_job
    FileUtils.cd(destination_root) do
      capture(:stdout) { described_class.new([], [], destination_root:).configure_good_job }
    end
  end

  it 'sets the GoodJob adapter in config/application.rb' do
    configure_good_job

    assert_file 'config/application.rb' do |content|
      expect(content).to include("    config.active_job.queue_adapter = :good_job\n  end\nend\n")
    end
  end

  it 'comments out an adapter that production.rb sets, and leaves one that is already a comment' do
    File.write(
      production_rb,
      File.read(production_rb).sub(
        "Rails.application.configure do\n",
        "Rails.application.configure do\n  config.active_job.queue_adapter = :solid_queue\n"
      )
    )

    configure_good_job

    assert_file 'config/environments/production.rb' do |content|
      expect(content).to include("  # config.active_job.queue_adapter = :solid_queue\n")
      expect(content).to include("  # config.active_job.queue_adapter = :resque\n")
      expect(content).not_to include('# # config.active_job')
    end
  end
end
