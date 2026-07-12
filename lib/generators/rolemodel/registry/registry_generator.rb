# frozen_string_literal: true

module Rolemodel
  # One-time seeding generator for consuming apps that predate the registry.
  # Feature-detects which generators have been applied by probing for their
  # characteristic output files, then writes seeded entries into the
  # config/initializers/rolemodel_generators.rb managed block.
  #
  # Safe to run multiple times: never overwrites existing entries, never writes
  # false. A re-run simply reports current state and no-ops.
  #
  # Exempt from registry recording — it bootstraps the registry, it is not
  # itself a product-of-installation generator.
  class RegistryGenerator < GeneratorBase
    skip_registry_entry!

    # Map from registry key → detection probe. Each entry is a lambda that
    # receives the app's root and returns true if that generator's footprint
    # is detected.
    #
    # The probes derive from each generator's idempotency guards and
    # characteristic output files. Low-confidence probes are omitted rather
    # than risk false positives; those generators will show as "not detected"
    # and the human can decide.
    DETECTION_MAP = {
      webpack:                ->(root) { File.exist?(File.join(root, 'webpack.config.js')) },
      sentry:                 ->(root) { File.exist?(File.join(root, 'config/initializers/sentry.rb')) },
      simple_form:            ->(root) { File.exist?(File.join(root, 'config/initializers/simple_form.rb')) },
      good_job:               ->(root) { File.exist?(File.join(root, 'config/initializers/good_job.rb')) },
      lograge:                ->(root) { File.exist?(File.join(root, 'config/initializers/lograge.rb')) },
      slim:                   ->(root) { File.exist?(File.join(root, 'app/views/layouts/application.html.slim')) },
      github:                 ->(root) { Dir.exist?(File.join(root, '.github/workflows')) },
      heroku:                 ->(root) { File.exist?(File.join(root, 'Procfile')) },
      tailored_select:        ->(root) { File.exist?(File.join(root, 'app/inputs/tailored_select_input.rb')) },
      react:                  ->(root) { File.exist?(File.join(root, 'app/javascript/controllers/react_controller.js')) },
      editors:                ->(root) {
        f = File.join(root, '.vscode/extensions.json')
        File.exist?(f) && File.read(f).include?('EditorConfig')
      },
      kaminari:               ->(root) { Dir.exist?(File.join(root, 'app/views/kaminari')) },
      mailers:                ->(root) { File.exist?(File.join(root, 'config/initializers/premailer_rails.rb')) },
      soft_destroyable:       ->(root) { File.exist?(File.join(root, 'app/models/concerns/soft_destroyable.rb')) },
      source_map:             ->(root) { File.exist?(File.join(root, 'lib/middleware/rolemodel/source_map.rb')) },
      optics_base:            ->(root) {
        scss = Dir.glob(File.join(root, 'app/assets/stylesheets/application.*')).first
        scss && File.read(scss).include?('@rolemodel/optics')
      },
      optics_icons:           ->(root) { File.exist?(File.join(root, 'app/helpers/icon_helper.rb')) },
      testing_rspec:          ->(root) { File.exist?(File.join(root, 'spec/spec_helper.rb')) },
      testing_factory_bot:    ->(root) { File.exist?(File.join(root, 'spec/support/factory_bot.rb')) },
      testing_parallel_tests: ->(root) { File.exist?(File.join(root, '.rspec_parallel')) },
      testing_vitest:         ->(root) { File.exist?(File.join(root, 'vitest.config.js')) },
      testing_jasmine_playwright: ->(root) { File.exist?(File.join(root, 'jp-runner.config.mjs')) },
      saas_devise:            ->(root) { File.exist?(File.join(root, 'config/initializers/devise.rb')) },
      linters_eslint:         ->(root) { File.exist?(File.join(root, 'eslint.config.js')) },
      linters_rubocop:        ->(root) { File.exist?(File.join(root, '.rubocop.yml')) },
      ui_components_flash:    ->(root) { File.exist?(File.join(root, 'app/views/application/_flash.html.slim')) },
      ui_components_modals:   ->(root) { File.exist?(File.join(root, 'app/javascript/initializers/turbo_confirm.js')) },
      ui_components_navbar:   ->(root) { File.exist?(File.join(root, 'app/views/layouts/_navbar.html.slim')) },
    }.freeze

    def detect_and_seed
      say 'Scanning for previously applied generators…', :blue

      # Ensure the initializer file and managed block exist
      create_initializer

      say '', :blue

      seeded    = 0
      skipped   = 0
      not_detected = 0

      DETECTION_MAP.each do |key, probe|
        detected = probe.call(destination_root)

        if already_recorded?(key)
          skipped += 1
          say "  #{key.to_s.ljust(30)} already recorded — skipping", :cyan
          next
        end

        if detected
          Registry.record(key, destination_root:, comment: 'seeded-by-detection')
          seeded += 1
          say "  #{key.to_s.ljust(30)} detected & seeded", :green
        else
          not_detected += 1
          say "  #{key.to_s.ljust(30)} not detected", :yellow
        end
      end

      initializer_path = File.expand_path(Registry::INITIALIZER_PATH, destination_root)

      say '', :green
      say "Seeded: #{seeded} | Skipped (already recorded): #{skipped} | Not detected: #{not_detected}", :green
      say '', :blue
      say "Review #{initializer_path} in your app and adjust entries as needed.", :blue
    end

    private

    # Create the initializer from the template if it doesn't already exist.
    def create_initializer
      path = File.expand_path(Registry::INITIALIZER_PATH, destination_root)
      return if File.exist?(path)

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, Registry::FILE_TEMPLATE)
      say '  Created empty registry initializer', :blue
    end

    # Check if a key already has a genuine (version-stamped) entry in the
    # managed block. A seeded-by-detection entry is NOT considered "already
    # recorded" for the purpose of skip logic — the seeder overwrites its own
    # prior seeds to keep the comment clean. A version-stamped entry (from a
    # genuine generator run) is never touched.
    def already_recorded?(key)
      path = File.expand_path(Registry::INITIALIZER_PATH, destination_root)
      return false unless File.exist?(path)

      content = File.read(path)
      return false unless content.include?(Registry::BEGIN_MARKER)

      content.lines.each do |line|
        match = Registry::ENTRY_PATTERN.match(line)
        next unless match && match[:key] == key.to_s

        # Only skip if the entry has a version stamp (genuine run),
        # not a seeded-by-detection comment
        return line.include?('rolemodel_rails')
      end

      false
    end
  end
end
