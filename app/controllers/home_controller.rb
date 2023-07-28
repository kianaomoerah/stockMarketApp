class HomeController < ApplicationController

  require_relative '../../.api_key.rb'

  def index
    @api = StockQuote::Stock.new(api_key: $api_key)
  end

  def about 
  end
  
end
