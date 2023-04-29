desc 'run javascript tests'
task javascript_tests: :environment do |t|
  success = true
  success &&= system('yarn test_shared')
  success &&= system('yarn test_view_ci')
  abort('JS tests failed') unless success
end
