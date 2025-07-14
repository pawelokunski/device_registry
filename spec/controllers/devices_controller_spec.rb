# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DevicesController, type: :controller do
  let(:api_key) { create(:api_key) }
  let(:user) { api_key.bearer }

  describe 'POST #assign' do
    subject(:assign) do
      post :assign,
           params: { new_owner_id: new_owner_id, device: { serial_number: '123456' } },
           session: { token: user.api_keys.first.token }
    end
    context 'when the user is authenticated' do
      context 'when user assigns a device to another user' do
        let(:new_owner_id) { create(:user).id }

        it 'returns an unauthorized response' do
          assign
          expect(response.code).to eq('422')
          expect(response.parsed_body).to eq({ 'error' => 'Unauthorized' })
        end
      end

      context 'when user assigns a device to self' do
        let(:new_owner_id) { user.id }

        it 'returns a success response' do
          assign
          expect(response).to be_successful
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized response' do
        post :assign
        expect(response).to be_unauthorized
      end
    end
  end

  describe 'POST #unassign' do
    let(:serial_number) { '123456' }
    let(:user)          { create(:user) }
    let!(:api_key)      { create(:api_key, bearer: user) }

    before do
      AssignDeviceToUser.new(
        requesting_user: user,
        serial_number: serial_number,
        new_device_owner_id: user.id
      ).call
    end

    subject(:unassign) do
      post :unassign,
           params: { device: { serial_number: serial_number }, from_user_id: from_user_id },
           session: session_data
    end

    context 'when the user is authenticated' do
      let(:session_data) { { token: api_key.token } }

      context 'and returns their own device' do
        let(:from_user_id) { user.id }

        it 'returns a success response' do
          unassign
          expect(response).to be_successful
        end
      end

      context 'but another user tries to return it' do
        let(:from_user_id) { create(:user).id }

        it 'returns an unprocessable entity response' do
          unassign
          expect(response.code).to eq('422')
          expect(response.parsed_body).to eq({ 'error' => 'Invalid' })
        end
      end

      context 'but the device is already returned' do
        let(:from_user_id) { user.id }

        before do
          ReturnDeviceFromUser.new(
            user: user,
            serial_number: serial_number,
            from_user: user.id
          ).call
        end

        it 'returns an unprocessable entity response' do
          unassign
          expect(response.code).to eq('422')
          expect(response.parsed_body).to eq({ 'error' => 'Invalid' })
        end
      end
    end

    context 'when the user is not authenticated' do
      let(:session_data) { {} }
      let(:from_user_id) { user.id }

      it 'returns an unauthorized response' do
        unassign
        expect(response).to be_unauthorized
      end
    end
  end
end
