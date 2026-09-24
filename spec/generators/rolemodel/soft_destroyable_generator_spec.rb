RSpec.describe Rolemodel::SoftDestroyableGenerator, type: :generator do
  it 'adds the concern, shared example, and soft-destroyable skill' do
    run_generators

    assert_file 'app/models/concerns/soft_destroyable.rb'
    assert_file 'spec/support/shared_examples/soft_destroyable_behavior.rb'
    assert_file '.claude/skills/soft-destroyable/SKILL.md',
                %r{rolemodel-skills/main/skills/soft-destroyable/SKILL\.md}
  end

  it 'installs every file in the skill directory, and nothing outside it' do
    stub_skills_repo(
      %w[
        skills/soft-destroyable/SKILL.md
        skills/soft-destroyable/references/cascading.md
        skills/soft-destroyable-extras/SKILL.md
      ]
    )
    run_generators

    assert_file '.claude/skills/soft-destroyable/references/cascading.md'
    assert_no_file '.claude/skills/soft-destroyable-extras/SKILL.md'
  end

  it 'reports a skill missing from rolemodel-skills without failing' do
    stub_skills_repo([])
    output = run_generators[described_class]

    expect(output).to match(/missing.*soft-destroyable/)
    assert_file 'app/models/concerns/soft_destroyable.rb'
  end
end
