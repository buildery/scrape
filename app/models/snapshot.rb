class Snapshot
  attr_reader :url, :file_name

  def initialize(url, file_name)
    @url = url
    @file_name = file_name
  end

  def run
   `phantomjs lib/screengrab.js #{url} db/site_snapshots/#{file_name}.png`
   p "site snapped!"
  end
end
