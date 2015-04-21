class GoogleSearch
  attr_reader :search

  def initialize(search)
    @search = search
  end

  def run
    begin
      results = Mechanize.new.get("https://www.googleapis.com/customsearch/v1?key=#{Figaro.env.google_api_key}&cx=#{Figaro.env.google_cse}&q=#{search}").content
    rescue Exception => e
      p e
      return nil
    end

    return nil if !results.include?("items")

    links = []

    JSON.parse(results)["items"].each do |i|
      links << i["link"]
    end

    return links
  end
end
