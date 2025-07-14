# frozen_string_literal: true

class DevicesController < ApplicationController
  before_action :authenticate_user!, only: %i[assign unassign]
  def assign
    AssignDeviceToUser.new(
      requesting_user: @current_user,
      serial_number:       params.require(:device).require(:serial_number),
      new_device_owner_id: params.require(:new_owner_id)
    ).call
    head :ok
  rescue RegistrationError::Unauthorized
    render json: { error: 'Unauthorized' }, status: :unprocessable_entity
  rescue AssigningError::AlreadyUsedOnOtherUser,
    AssigningError::AlreadyUsedOnUser
    render json: { error: 'Invalid' }, status: :unprocessable_entity
  end

  def unassign
    #TODO
  end

  private

  def device_params
    params.permit(:new_owner_id, :serial_number)
  end
end
