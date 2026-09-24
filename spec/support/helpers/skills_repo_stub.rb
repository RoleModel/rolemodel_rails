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
    tree = { tree: files.map { { type: 'blob', path: it } } + [{ type: 'tree', path: 'skills' }] }.to_json

    allow(URI).to receive(:open).and_wrap_original do |original, url, *args, &block|
      next original.call(url, *args, &block) unless url.to_s.include?(Rolemodel::GeneratorBase::SKILLS_REPO)

      io = StringIO.new(url.include?('/git/trees/') ? tree : "stubbed #{url}")
      block ? block.call(io) : io
    end
  end
end
