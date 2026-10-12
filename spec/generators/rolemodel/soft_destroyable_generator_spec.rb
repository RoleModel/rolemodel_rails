RSpec.describe Rolemodel::SoftDestroyableGenerator, type: :generator do
  it 'adds the concern, shared example, and soft-destroyable skill' do
    run_generators

    assert_file 'app/models/concerns/soft_destroyable.rb'
    assert_file 'spec/support/shared_examples/soft_destroyable_behavior.rb'
    assert_file '.agents/skills/soft-destroyable/SKILL.md'
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

    assert_file '.agents/skills/soft-destroyable/references/cascading.md'
    assert_no_file '.agents/skills/soft-destroyable-extras/SKILL.md'
  end

  it 'does not fail when the skill is missing from rolemodel-skills' do
    stub_skills_repo(%w[skills/tdd/SKILL.md])
    run_generators

    assert_no_file '.agents/skills/soft-destroyable/SKILL.md'
    assert_file 'app/models/concerns/soft_destroyable.rb'
  end

  it 'reuses a recently downloaded skills archive' do
    run_generators
    FileUtils.rm_rf(File.join(destination_root, '.agents'))
    stub_skills_repo(%w[skills/tdd/SKILL.md])
    run_generators

    assert_file '.agents/skills/soft-destroyable/SKILL.md'
  end

  it 'downloads the skills archive again once it expires' do
    run_generators
    FileUtils.rm_rf(File.join(destination_root, '.agents'))
    File.utime(Time.now, 11.minutes.ago, File.join(destination_root, 'tmp/rolemodel-skills.tar.gz'))
    stub_skills_repo(%w[skills/tdd/SKILL.md])
    run_generators

    assert_no_file '.agents/skills/soft-destroyable/SKILL.md'
  end
end
