# frozen_string_literal: true

module SkillsCliStub
  def stub_skills_cli
    @skills_cli_dir = Dir.mktmpdir
    npx = File.join(@skills_cli_dir, 'npx')
    File.write(npx, %(#!/bin/sh\necho "$@" >> "#{@skills_cli_dir}/npx.log"\n))
    File.chmod(0o755, npx)
    ENV['PATH'] = "#{@skills_cli_dir}:#{ENV['PATH']}"
    ENV['XDG_STATE_HOME'] = @skills_cli_dir
  end

  def last_selected_skill_agents(agents)
    path = File.join(@skills_cli_dir, 'skills/.skill-lock.json')
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, { version: 3, skills: {}, lastSelectedAgents: agents }.to_json)
  end

  def installed_skills
    log = File.join(@skills_cli_dir, 'npx.log')
    File.exist?(log) ? File.readlines(log).map { it[/--skill (\S+)/, 1] } : []
  end

  def skills_cli_calls
    File.readlines(File.join(@skills_cli_dir, 'npx.log'), chomp: true)
  end
end
