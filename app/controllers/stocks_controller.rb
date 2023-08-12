class StocksController < ApplicationController

  require_relative '../../.api_key.rb'

  before_action :set_stock, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  def index
    @stocks = current_user.stocks

    require 'json'
    require 'finnhub_ruby'

    FinnhubRuby.configure do |config|
      config.api_key['api_key'] = $api_key
    end

    @finnhub_client = FinnhubRuby::DefaultApi.new
  end

  def show
  end

  def new
    @stock = Stock.new
  end

  # revisit option to "edit" stock, may only want option to delete
  def edit
  end

  def create
    if stock_params[:ticker] == ""
      flash[:alert] = "Please enter a company ticker symbol to search."
      redirect_to(action: 'new')
    elsif stock_params[:ticker]
      begin
        require 'finnhub_ruby'
        require 'json'

        FinnhubRuby.configure do |config|
          config.api_key['api_key'] = $api_key
        end

        finnhub_client = FinnhubRuby::DefaultApi.new

        # do i need a variable here?
        stock_check = finnhub_client.company_profile2({symbol: stock_params[:ticker]})

        @stock = Stock.new(stock_params)
  
        if @stock.save
          flash[:alert] = "Stock was successfully saved to your portfolio!"
          redirect_to(action: 'index')
        else 
          flash[:alert] = "We're Sorry, Your stock could not be saved. Please try again."
          redirect_to(action: 'new')
        end
      rescue
        flash[:alert] = "Oh no! That stock symbol doesn't exist, please try again."
        redirect_to(action: 'new')
      end 
    end
  end

  def update
    respond_to do |format|
      if @stock.update(stock_params)
        format.html { redirect_to stock_url(@stock), notice: "Stock was successfully updated." }
        format.json { render :show, status: :ok, location: @stock }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
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
    # Use callbacks to share common setup or constraints between actions.
    def set_stock
      @stock = Stock.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def stock_params
      params.require(:stock).permit(:ticker, :user_id)
    end
end
