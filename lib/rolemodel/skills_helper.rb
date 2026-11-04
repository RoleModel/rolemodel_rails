# frozen_string_literal: true

require 'json'

module Rolemodel
  module SkillsHelper
    SKILLS_REPO = 'RoleModel/skills'
    DEFAULT_SKILL_AGENTS = %w[claude-code github-copilot codex].freeze

    private

    def install_skill(name)
      inside('.') { run "npx -y skills@latest add #{SKILLS_REPO} --skill #{name} --agent #{skill_agents.join(' ')} -y" }
    end

    # Agents the user last picked in the skills CLI; it only offers them as defaults interactively.
    def skill_agents
      JSON.parse(File.read(skills_state_path))['lastSelectedAgents'].presence || DEFAULT_SKILL_AGENTS
    rescue Errno::ENOENT, JSON::ParserError
      DEFAULT_SKILL_AGENTS
    end

    def skills_state_path
      state_home = ENV['XDG_STATE_HOME']
      state_home ? File.join(state_home, 'skills/.skill-lock.json') : File.expand_path('~/.agents/.skill-lock.json')
    end
  end
end
