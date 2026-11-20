RSpec.describe Rolemodel::EditorsGenerator, type: :generator do
  let(:extensions_json) { File.join(destination_root, '.vscode/extensions.json') }

  it 'copies .editorconfig and recommends the EditorConfig extension' do
    run_generators

    assert_file '.editorconfig'
    assert_file '.vscode/extensions.json' do |content|
      expect(JSON.parse(content)).to eq('recommendations' => ['EditorConfig.EditorConfig'])
    end
  end

  it 'keeps the extensions the app already recommends, and adds EditorConfig only once' do
    FileUtils.mkdir_p(File.dirname(extensions_json))
    File.write(extensions_json, "{\n  // VS Code adds comments like this one\n  \"recommendations\": [\"Shopify.ruby-lsp\",],\n}\n")

    2.times { run_generators }

    assert_file '.vscode/extensions.json' do |content|
      expect(JSON.parse(content)).to eq('recommendations' => ['Shopify.ruby-lsp', 'EditorConfig.EditorConfig'])
    end
  end
end
