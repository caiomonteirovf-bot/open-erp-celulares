# frozen_string_literal: true

class ServiceOrdersController < ApplicationController
  before_action :set_service_order, only: %i[show edit update destroy]

  def index
    @service_orders = ServiceOrder.includes(:customer, :phone_unit)
                                  .where(account_id: current_tenant)
                                  .order(created_at: :desc)

    @service_orders = @service_orders.where(status: params[:status]) if params[:status].present?
    @service_orders = @service_orders.joins(:customer).where(
      'customers.name ILIKE ?', "%#{params[:search]}%"
    ) if params[:search].present?
    @service_orders = @service_orders.where('device_imei ILIKE ?', "%#{params[:imei]}%") if params[:imei].present?

    @pagy, @service_orders = pagy(@service_orders)
  end

  def show; end

  def new
    @service_order = ServiceOrder.new
    @service_order.service_order_items.build
  end

  def create
    @service_order = ServiceOrder.new(service_order_params)
    @service_order.account_id = current_tenant

    if @service_order.save
      redirect_to @service_order, notice: t('service_orders.created', number: @service_order.number)
    else
      flash.now[:alert] = @service_order.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @service_order.service_order_items.build if @service_order.service_order_items.empty?
  end

  def update
    if @service_order.update(service_order_params)
      @service_order.update_column(:closed_at, Time.current) if @service_order.closed?
      redirect_to @service_order, notice: t('service_orders.updated')
    else
      flash.now[:alert] = @service_order.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service_order.destroy
    redirect_to service_orders_path, notice: t('service_orders.deleted')
  end

  private

  def set_service_order
    @service_order = ServiceOrder.find(params[:id])
  end

  def service_order_params
    params.require(:service_order).permit(
      :customer_id, :phone_unit_id, :status,
      :reported_defect, :diagnosis, :technician_notes,
      :labor_cost, :promised_at, :under_warranty,
      :device_brand, :device_model, :device_imei,
      :device_color, :device_battery_health, :accessories_received,
      service_order_items_attributes: %i[
        id product_id description quantity unit_price _destroy
      ]
    )
  end
end
