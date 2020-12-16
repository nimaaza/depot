class AdminController < ApplicationController
  def index
    @total_ordets = Order.count
  end
end
