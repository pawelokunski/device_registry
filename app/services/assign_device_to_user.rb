# frozen_string_literal: true

class AssignDeviceToUser
  def initialize(requesting_user:, serial_number:, new_device_owner_id:)
    @requesting_user = requesting_user
    @serial_number   = serial_number
    @new_owner_id    = new_device_owner_id.to_i
  end

  def call
    authorize_request!
    device = find_or_build_device
    validate_device_state!(device)
    activate_device_for(device)
    device
  end

  private

  def authorize_request!
    raise RegistrationError::Unauthorized unless @requesting_user.id == @new_owner_id
  end

  def find_or_build_device
    Device.find_or_create_by!(serial_number: @serial_number)
  end

  def validate_device_state!(device)
    if device.user_id.present? && device.user_id != @requesting_user.id
      raise AssigningError::AlreadyUsedOnOtherUser
    end
    return unless device.device_assignments.exists?(user_id: @requesting_user.id)

    raise AssigningError::AlreadyUsedOnUser
  end

  def activate_device_for(device)
    DeviceAssignment.create!(device:, user: @requesting_user)
    device.update!(user: @requesting_user)
  end
end
