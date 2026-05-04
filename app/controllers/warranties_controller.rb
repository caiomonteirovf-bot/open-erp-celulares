# frozen_string_literal: true

class WarrantiesController < ApplicationController
  before_action :set_phone_unit
  before_action :set_warranty, only: %i[edit update destroy]

  def index
    @warranties = Warranty.includes(:phone_unit)
                          .where(account_id: current_tenant)
                          .order(expires_at: :asc)

    @warranties = @warranties.by_type(params[:warranty_type])  if params[:warranty_type].present?
    @warranties = @warranties.by_imei(params[:imei])           if params[:imei].present?

    case params[:status]
    when 'active'        then @warranties = @warranties.active
    when 'expiring_soon' then @warranties = @warranties.expiring_soon
    when 'expired'       then @warranties = @warranties.expired
    end

    @pagy, @warranties = pagy(@warranties)
  end

  def new
    @warranty = @phone_unit.warranties.build(started_at: Date.current)
  end

  def create
    @warranty = @phone_unit.warranties.build(warranty_params)
    @warranty.account_id = current_tenant

    if @warranty.save
      redirect_to phone_unit_warranties_path(@phone_unit), notice: t('warranties.created')
    else
      flash.now[:alert] = @warranty.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @warranty.update(warranty_params)
      redirect_to phone_unit_warranties_path(@phone_unit), notice: t('warranties.updated')
    else
      flash.now[:alert] = @warranty.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @warranty.destroy
    redirect_to phone_unit_warranties_path(@phone_unit), notice: t('warranties.deleted')
  end

  private

  def set_phone_unit
    @phone_unit = PhoneUnit.find(params[:phone_unit_id])
  end

  def set_warranty
    @warranty = @phone_unit.warranties.find(params[:id])
  end

  def warranty_params
    params.require(:warranty).permit(
      :warranty_type, :started_at, :expires_at, :document_number, :notes
    )
  end
end
