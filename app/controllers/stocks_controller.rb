class StocksController < ApplicationController

  require_relative '../../.api_key.rb'
  require 'json'

  before_action :set_stock, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  def index
    @stocks = current_user.stocks
  end

  def show
    @stock = Stock.find(params[:id])
  end

  def new
    @stock = Stock.new
  end

  def create
    @stock = Stock.new(stock_params)
     
    if !@stock.valid?
      flash[:alert] = "Company ticker cannot be blank."
      redirect_to(action: 'new') and return
    else
      begin 
        require 'finnhub_ruby'
        require 'json'

        FinnhubRuby.configure do |config|
          config.api_key['api_key'] = $api_key
        end

        finnhub_client = FinnhubRuby::DefaultApi.new
        
        stock_check = JSON.parse((finnhub_client.company_profile2({symbol: stock_params[:ticker]})).to_json)

        if stock_check.empty?
          flash[:alert] = "Oh no! That stock symbol doesn't exist, please try again."
          redirect_to(action: 'new') and return 
        else 
          if @stock.save
            flash[:alert] = "Stock was successfully saved to your portfolio!"
            redirect_to(action: 'index')
          else 
            flash[:alert] = "We're Sorry, Your stock could not be saved. Please try again."
            redirect_to(action: 'new')
          end
        end 
      rescue
        flash[:alert] = "Ops! Something's gone wrong on our end, please try again."
      end
    end         
  end

  def destroy
    @stock.destroy

    respond_to do |format|
      format.html { redirect_to stocks_url, notice: "Stock was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_stock
      @stock = Stock.find(params[:id])
    end

    def stock_params
      params.require(:stock).permit(:ticker, :user_id)
    end
    
end
