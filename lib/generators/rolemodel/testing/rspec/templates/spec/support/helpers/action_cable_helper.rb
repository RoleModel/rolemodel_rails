module ActionCableHelper
  def wait_for_stream_connection
    expect(page).to have_selector('turbo-cable-stream-source[connected]', visible: false)
  end
end
