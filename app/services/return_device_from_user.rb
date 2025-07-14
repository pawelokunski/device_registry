# frozen_string_literal: true

class ReturnDeviceFromUser
  def initialize(user:, serial_number:, from_user:)
    @user = user
    @serial_number = serial_number
    @from_user_id = from_user.to_i
  end

  def call
    raise RegistrationError::Unauthorized unless @user.id == @from_user_id

    device = Device.find_by!(serial_number: @serial_number)
    assignment = device.device_assignments.active.find_by(user_id: @user.id)
    raise ReturningError::AlreadyReturned unless assignment
    DeviceAssignment.transaction do
      assignment.update!(returned_at: Time.current)
      device.update!(user: nil)
    end
  end
end
