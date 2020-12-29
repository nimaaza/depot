require 'pago'

class Order < ApplicationRecord
  enum pay_types: {
    'Check' => 0,
    'Credit card' => 1,
    'Purchase order' => 2
  }

  validates :name, :address, :email, presence: true
  validates :pay_type, inclusion: pay_types.values

  has_many :line_items, dependent: :destroy

  def add_line_items_from_cart(cart)
    cart.line_items.each do |line_item|
      line_item.cart_id = nil
      line_items << line_item
    end
  end

  def charge!(pay_type_params)
    payment_details = {}
    payment_method = nil

    case pay_type
    when 0
      payment_method = :check
      payment_details[:routing] = pay_type_params[:routing_number]
      payment_details[:account] = pay_type_params[:account_number]
    when 1
      payment_method = :credit_card
      month,year = pay_type_params[:expiration_date].split(//)
      payment_details[:cc_num] = pay_type_params[:credit_card_number]
      payment_details[:expiration_month] = month
      payment_details[:expiration_year] = year
    when 2
      payment_method = :po
      payment_details[:po_num] = pay_type_params[:po_number]
    end

    puts '#####################################3'
    p pay_type

    payment_result = Pago.make_payment(
      order_id: id,
      payment_method: payment_method,
      payment_details: payment_details
    )

    if payment_result.succeeded?
      OrderMailer.received(self).deliver_later
    else
      raise payment_result.error
    end
  end
end
