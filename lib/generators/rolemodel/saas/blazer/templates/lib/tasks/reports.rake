# frozen_string_literal: true

def import_blazer_query(author_user_id, query_path_name)
  file_name = query_path_name.split('/').last
  puts "Importing blazer query #{file_name}"
  file_contents = File.readlines(query_path_name)
  description = file_contents.select { |line| line.start_with?('--')}
                             .map { |comment_line| comment_line.gsub('--', '').strip }
                             .join('. ')
                             .presence
  query = file_contents.select {|line| !line.start_with?('--') }.join(' ')
  name = File.basename(file_name, File.extname(file_name))
  Blazer::Query.create_with(
    description: description,
    statement: query,
    status: 'active',
    data_source: 'main',
    creator_id: author_user_id
  ).find_or_create_by!(name: name)
end

def import_blazer_dashboard(author_user_id, dashboard_path_name)
  file_name = dashboard_path_name.split('/').last
  puts "Importing blazer dashboard #{file_name}"
  name = File.basename(file_name, File.extname(file_name))
  Blazer::Dashboard.where(name: name).destroy_all
  blazer_dashboard = Blazer::Dashboard.create(
    name: name, creator_id: author_user_id
  )

  file_contents = File.readlines(dashboard_path_name).reject { |s| s.strip.empty? }
  file_contents.each do |query_name|
    query = Blazer::Query.find_by(name: query_name.strip)
    if query.nil?
      puts "Unable to find blazer query #{query_name}"
      next
    end
    blazer_dashboard.queries << query
  end
end

namespace :import do
  desc 'import all stock reports'
  task reports: :environment do
    author_user_id = ENV['USER_ID']
    if author_user_id.blank?
      puts "USER_ID is required"
      exit(1)
    end
    Dir[Rails.root.join('db/blazer/queries/*.sql')].sort.each do |path_name|
      import_blazer_query(author_user_id, path_name)
    end
    Dir[Rails.root.join('db/blazer/dashboards/*.txt')].sort.each do |path_name|
      import_blazer_dashboard(author_user_id, path_name)
    end
  end
end
