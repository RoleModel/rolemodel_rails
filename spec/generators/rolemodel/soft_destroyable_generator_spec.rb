# frozen_string_literal: true

RSpec.describe Rolemodel::SoftDestroyableGenerator, type: :generator do
  it 'adds the concern, shared example, and soft-destroyable skill' do
    run_generators

    assert_file 'app/models/concerns/soft_destroyable.rb'
    assert_file 'spec/support/shared_examples/soft_destroyable_behavior.rb'
    expect(installed_skills).to eq %w[soft-destroyable]
  end

  it 'installs the skill from RoleModel/skills for Claude, Copilot, and Codex without prompting' do
    run_generators

    expect(skills_cli_calls).to eq [
      '-y skills@latest add RoleModel/skills --skill soft-destroyable --agent claude-code github-copilot codex -y'
    ]
  end

  it "installs for the agents last selected in the user's skills CLI" do
    last_selected_skill_agents %w[cursor claude-code]
    run_generators

    expect(skills_cli_calls.first).to end_with '--agent cursor claude-code -y'
  end
end
