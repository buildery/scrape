class YelpSearch
  attr_reader :location, :term

  def initialize(location,term)
    @location = location.gsub(" ","+")
    @term = term.gsub(" ","+")
  end

  def run
    consumer = OAuth::Consumer.new( Figaro.env.yelp_consumer_key, Figaro.env.yelp_consumer_secret, {:site => "http://api.yelp.com", :signature_method => "HMAC-SHA1", :scheme => :query_string})
    access_token = OAuth::AccessToken.new( consumer, Figaro.env.yelp_token, Figaro.env.yelp_token_secret)

    result_limit = 10

    search_results = access_token.get("/v2/search?term=#{term}&location=#{location}&limit=#{result_limit}").body

    businesses = []

    JSON.parse(search_results)["businesses"].each do |n|
      h={}
      h[n["name"]] = n["url"]

      page = Mechanize.new.get("#{n["url"]}")

      if page.at(".biz-website a")
        h[n["name"]] = page.at(".biz-website a").text.strip if page.at(".biz-website a").text.strip
      else
        h[n["name"]] = n["url"]
      end
      p h
      businesses << h
    end

    businesses.each do |name|
      url = "http://#{name.values[0]}"
      file_name = friendly_filename(name.keys[0])
      p url
      `phantomjs lib/screengrab.js #{url} db/site_snapshots/#{file_name}.png`
    end
  end

  def friendly_filename(filename)
      filename.gsub(/[^\w\s_-]+/, '')
              .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
              .gsub(/\s+/, '_')
  end
end
