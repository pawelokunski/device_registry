# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReturnDeviceFromUser do
  subject(:return_device) do
    described_class.new(
      user: user,
      serial_number: serial_number,
      from_user: from_user_id
    ).call
  end

  let(:user) { create(:user) }
  let(:serial_number) { '123456' }
  let(:device)        { AssignDeviceToUser.new(requesting_user: user,
                                               serial_number: serial_number,
                                               new_device_owner_id: user.id).call }

  before { device }

  context 'when the same user returns the device' do
    let(:from_user_id) { user.id }

    it 'clears current owner on device' do
      return_device
      expect(device.reload.user_id).to be_nil
    end

    it 'marks assignment as returned' do
      return_device
      assignment = device.device_assignments.last
      expect(assignment.returned_at).not_to be_nil
    end
  end

  context 'when another user tries to return the device' do
    let(:from_user_id) { create(:user).id }

    it 'raises unauthorized error' do
      expect { return_device }.to raise_error(RegistrationError::Unauthorized)
    end
  end

  context 'when device is already returned' do
    let(:from_user_id) { user.id }

    before { ReturnDeviceFromUser.new(user: user, serial_number: serial_number, from_user: user.id).call }

    it 'raises AlreadyReturned error' do
      expect { return_device }.to raise_error(ReturningError::AlreadyReturned)
    end
  end
end

