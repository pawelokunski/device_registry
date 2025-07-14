# frozen_string_literal: true

class AssignDeviceToUser
  def initialize(requesting_user:, serial_number:, new_device_owner_id:)
    @requesting_user = requesting_user
    @serial_number   = serial_number
    @new_owner_id    = new_device_owner_id.to_i
  end

  def call
    raise RegistrationError::Unauthorized unless @requesting_user.id == @new_owner_id

    device = Device.find_or_create_by!(serial_number: @serial_number) do |d|
      d.user = @requesting_user
    end

    if device.user_id.present? && device.user_id != @requesting_user.id
      raise AssigningError::AlreadyUsedOnOtherUser
    end

    if device.device_assignments.where(user_id: @requesting_user.id).exists?
      raise AssigningError::AlreadyUsedOnUser
    end

    DeviceAssignment.transaction do
      DeviceAssignment.create!(device: device, user: @requesting_user)
      device.update!(user: @requesting_user)
    end

    device
  end
end
