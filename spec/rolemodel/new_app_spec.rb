# frozen_string_literal: true

require 'rolemodel/new_app'

RSpec.describe Rolemodel::NewApp do
  def options_for(*args)
    argv = described_class.argv(['new', 'my_app', *args])
    Rails::Generators::AppGenerator.new(argv.take(1), argv.drop(1)).options
  end

  it 'applies the RoleModel defaults and template' do
    options = options_for('--no-rc')

    expect(options).to include('database' => 'postgresql', 'javascript' => 'webpack', 'skip_test' => true)
    expect(options['template']).to end_with('rolemodel/new_app/template.rb')
  end

  it 'lets command line flags override the defaults' do
    expect(options_for('--no-rc', '--database=sqlite3', '--no-skip-test'))
      .to include('database' => 'sqlite3', 'skip_test' => false)
  end

  it "lets the user's railsrc override the defaults, and command line flags override both" do
    Tempfile.create('railsrc') do |railsrc|
      railsrc.write("--database=mysql\n--javascript=esbuild\n")
      railsrc.flush

      options = nil
      expect { options = options_for("--rc=#{railsrc.path}", '--javascript=importmap') }.to output(/Using/).to_stdout
      expect(options).to include('database' => 'mysql', 'javascript' => 'importmap')
    end
  end
end
