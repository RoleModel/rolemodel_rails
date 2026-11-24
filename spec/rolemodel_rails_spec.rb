RSpec.describe Rolemodel do
  it "has a version number" do
    expect(Rolemodel::VERSION).not_to be nil
  end

  it "loads without Rails already required" do
    expect(system(RbConfig.ruby, "-Ilib", "-e", "require 'rolemodel-rails'", err: File::NULL)).to be true
  end
end
