# frozen_string_literal: true

module DownloadHelper
  DOWNLOAD_PATH = Rails.root.join('tmp/downloads').to_s
  TIMEOUT = 10

  def expect_download(filename) # rubocop:disable Metrics/MethodLength
    if supports_javascript?
      file_path = "#{DOWNLOAD_PATH}/#{filename}"
      FileUtils.rm_f(file_path)

      yield

      Timeout.timeout(TIMEOUT) do
        sleep 0.1 until downloaded?(file_path)
      end
      FileUtils.rm_f(file_path)
    else
      yield
      expect(page.driver.response.headers['Content-Disposition']).to include(filename)
    end
  end

  private

  def downloaded?(file_path)
    assert File.exist?(file_path)
  end
end
