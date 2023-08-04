class StocksController < ApplicationController

  require_relative '../../.api_key.rb'
  @api = StockQuote::Stock.new(api_key: $api_key)

  before_action :set_stock, only: %i[ show edit update destroy ]
  # before_action :confirm_user, only: [:edit, :update, :destroy]
  before_action :authenticate_user!
  # GET /stocks or /stocks.json
  def index
    @stocks = current_user.stocks
  end

  # GET /stocks/1 or /stocks/1.json
  def show
  end

  # GET /stocks/new
  def new
    @stock = Stock.new
  end

  # GET /stocks/1/edit
  def edit
  end

  # POST /stocks or /stocks.json
  def create
    if stock_params[:ticker] == ""
      flash[:alert] = "Please enter a company ticker symbol to search."
      puts "CANNOT BE BLANK"
      redirect_to(action: 'new')
    elsif stock_params[:ticker]
      begin
        search_stock = StockQuote::Stock.quote(stock_params[:ticker])

        @stock = Stock.new(stock_params)
  
        if @stock.save
          flash[:alert] = "Stock was successfully saved to your portfolio!"
          redirect_to(action: 'index')
        else 
          flash[:alert] = "We're Sorry, Your stock could not be saved. Please try again."
          redirect_to(action: 'new')
        end
        # respond_to do |format|
        #   if @new_stock.save
        #     format.html { redirect_to stock_url(@stock), notice: "Stock was successfully saved to your portfolio!" }
        #     format.json { render :show, status: :created, location: @stock }
        #   else
        #     format.html { render :new, status: :unprocessable_entity }
        #     format.json { render json: @stock.errors, status: :unprocessable_entity }
        #   end
        # end        
      rescue
        puts "THERE WAS NOTHING THERE BRUH"
        flash[:alert] = "Oh no! That stock symbol doesn't exist, please try again."
        redirect_to(action: 'new')
      end 
    end
  end

  # PATCH/PUT /stocks/1 or /stocks/1.json
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

  # DELETE /stocks/1 or /stocks/1.json
  def destroy
    @stock.destroy

    respond_to do |format|
      format.html { redirect_to stocks_url, notice: "Stock was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  # may not be needed if I want to hide other user's wallets
=begin
  def confirm_user
    @ticker = current_user.stocks.find_by(id: params[:id])
    redirect_to stocks_path, notice "..."
  end
=end

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
