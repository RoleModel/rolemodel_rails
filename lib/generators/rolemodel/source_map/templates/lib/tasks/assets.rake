# frozen_string_literal: true

namespace :assets do
  task clean_sourcemaps: :environment do
    maps_root = Rails.root.join('maps')
    next unless maps_root.exist?

    assets_root = Rails.public_path.join('assets')

    puts 'Cleaning sourcemaps folder'
    maps_root.glob('*.map').each do |map_file|
      asset_file = map_file.basename('.map')
      map_file.delete unless assets_root.join(asset_file).exist?
    end
  end

  task relocate_sourcemaps: :environment do
    maps_root = Rails.root.join('maps')
    maps_root.mkpath

    puts 'Relocating sourcemap files'
    Rails.root.glob('public/assets/*.map').each do |map_file|
      map_file.rename(maps_root.join(map_file.basename))
    end
  end

  task clear_sourcemaps: :environment do
    maps_root = Rails.root.join('maps')
    maps_root.rmtree if maps_root.exist?
  end
end

Rake::Task['assets:clean'].enhance do
  Rake::Task['assets:clean_sourcemaps'].invoke
end

Rake::Task['assets:precompile'].enhance do
  Rake::Task['assets:relocate_sourcemaps'].invoke
end

Rake::Task['assets:clobber'].enhance do
  Rake::Task['assets:clear_sourcemaps'].invoke
end
