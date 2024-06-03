class Order < ApplicationRecord
  has_many :items
  accepts_nested_attributes_for :items
end

# Товары в заказе
class Item < ApplicationRecord
  belongs_to :order, optional: true
end

class OrdersController < ApplicationController
  def index
    render json: Order.all
  end

  def show
    render json: Order.find(params[:id])
  end

  def create
    @order = Order.new(
      customer_name: params[:customer_name],
      address: params[:address],
      email: params[:email],
      password: params[:password],
      items_attributes: params[:items]
    )
    OrderMailer.with(order: @order).confirmation_email.deliver_now
    @order.save

    head :ok
  end

  def update
    @order = Order.find(params[:id])
    @order.update(
      customer_name: params[:customer_name],
      address: params[:address],
      email: params[:email]
    )

    render json: @order
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    render json: @order
  end

  def search
    render json: Order.where("customer_name LIKE '%#{params[:query]}%'")
  end

  def download_all
    send_data Order.all.to_csv, filename: "orders.csv"
  end

  def all_with_items
    orders = Order.all
    render json: orders.map { |order|
      {
        order: order,
        items: order.items
      }
    }
  end
end
