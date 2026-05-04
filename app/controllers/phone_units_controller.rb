# frozen_string_literal: true

class PhoneUnitsController < ApplicationController
  before_action :set_phone_unit, only: %i[show edit update destroy]

  def index
    @phone_units = PhoneUnit.includes(:product)
                            .where(account_id: current_tenant)
                            .order(created_at: :desc)

    @phone_units = @phone_units.by_imei(params[:imei])       if params[:imei].present?
    @phone_units = @phone_units.where(status: params[:status]) if params[:status].present?
    @phone_units = @phone_units.where(
      "products.name ILIKE ?", "%#{params[:search]}%"
    ).joins(:product)                                          if params[:search].present?

    @pagy, @phone_units = pagy(@phone_units)
  end

  def show; end

  def new
    @phone_unit = PhoneUnit.new
  end

  def edit; end

  def create
    @phone_unit = PhoneUnit.new(phone_unit_params)
    @phone_unit.account_id = current_tenant

    if @phone_unit.save
      redirect_to phone_units_path, notice: t('phone_units.created')
    else
      flash.now[:alert] = @phone_unit.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @phone_unit.update(phone_unit_params)
      redirect_to phone_unit_path(@phone_unit), notice: t('phone_units.updated')
    else
      flash.now[:alert] = @phone_unit.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @phone_unit.destroy
    redirect_to phone_units_path, notice: t('phone_units.deleted')
  end

  private

  def set_phone_unit
    @phone_unit = PhoneUnit.find(params[:id])
  end

  def phone_unit_params
    params.require(:phone_unit).permit(
      :product_id, :imei1, :imei2, :serial_number,
      :status, :condition, :purchase_price, :sale_price,
      :battery_health, :color, :notes
    )
  end
end
