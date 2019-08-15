desc 'run javascript tests'
task javascript_tests: :environment do |t|
  abort('JS tests failed') unless system('bin/yarn test_ci')
end
