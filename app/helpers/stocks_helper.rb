module StocksHelper

  def stock_search(stock)
    
    require 'finnhub_ruby'

    FinnhubRuby.configure do |config|
      config.api_key['api_key'] = ENV["API_KEY"]
    end

    @finnhub_client = FinnhubRuby::DefaultApi.new

    begin
      quote_hash = JSON.parse((@finnhub_client.quote(stock)).to_json) 
      profile_hash = JSON.parse((@finnhub_client.company_profile2({symbol:   stock})).to_json) 
      metric_hash = JSON.parse((@finnhub_client.company_basic_financials(stock, 'all')).to_json) 

      @stock_info = [quote_hash, profile_hash, metric_hash]
    rescue
      flash[:alert] = "There appears to be an issue retrieving your requested stock information. Please try again. "
    end
  end

  def precision(num)
    number_with_precision(num, :precision => 2, :delimiter => '.')
  end
  
end
