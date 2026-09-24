# frozen_string_literal: true

module SkillsRepoStub
  SKILL_FILES = %w[
    skills/optics-context/SKILL.md
    skills/optics-context/assets/tokens.json
    skills/tdd/SKILL.md
    skills/turbo-fetch/SKILL.md
    skills/turbo-modals/SKILL.md
    skills/soft-destroyable/SKILL.md
  ].freeze

  def stub_skills_repo(files = SKILL_FILES)
    root = Dir.mktmpdir
    files.each do |file|
      path = File.join(root, 'rolemodel-skills-main', file)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, file)
    end
    system('tar', '-czf', "#{root}/archive.tgz", '-C', root, 'rolemodel-skills-main', exception: true)
    stub_const('Rolemodel::GeneratorBase::SKILLS_ARCHIVE', "file://#{root}/archive.tgz")
  end
end
