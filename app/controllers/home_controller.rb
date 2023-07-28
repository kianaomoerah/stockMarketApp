class HomeController < ApplicationController

  require_relative '../../.api_key.rb'

  def index
    @api = StockQuote::Stock.new(api_key: $api_key)

    if params[:stock] == ""
      flash[:alert] = "Please enter a company ticker symbol to search!"
    elsif params[:stock]
      begin
        @stock = StockQuote::Stock.quote(params[:stock])
      rescue
        flash[:alert] = "Oh no! That stock symbol doesn't exist, please try again!" 
      end
    end
  end

  def about 
  end

end