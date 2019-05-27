require 'rails_helper'

RSpec.describe 'Thermostat API', type: :request do
  describe 'GET #stats' do
    it 'returns http success' do
      ActiveJob::Base.queue_adapter = :test

      thermostat = FactoryBot.create(:thermostat)

      post '/reading', params: {
        reading: {
          thermostat_id: thermostat.id,
          temperature: 1,
          humidity: Faker::Number.decimal(2),
          battery_charge: Faker::Number.decimal(2)
        }
      }
      get "/stats/#{thermostat.id}"
      expect(response).to have_http_status(:success)

      result = JSON.parse response.body
      expect(result['temperature'].to_f).to eq(1.0)

      post '/reading', params: {
        reading: {
          thermostat_id: thermostat.id,
          temperature: 3,
          humidity: Faker::Number.decimal(2),
          battery_charge: Faker::Number.decimal(2)
        }
      }

      get "/stats/#{thermostat.id}"
      expect(response).to have_http_status(:success)
      result = JSON.parse response.body
      expect(result['temperature'].to_f).to eq(2.0)
    end
  end

  describe 'POST #reading' do
    it 'returns thermostat sequence number for this reading' do
      ActiveJob::Base.queue_adapter = :test

      thermostat = FactoryBot.create(:thermostat)
      post '/reading', params: {
        reading: {
          thermostat_id: thermostat.id,
          temperature: Faker::Number.decimal(2),
          humidity: Faker::Number.decimal(2),
          battery_charge: Faker::Number.decimal(2)
        }
      }
      expect(response). to have_http_status(:success)
      sequence_number = response.body

      get "/reading/#{thermostat.id}/#{sequence_number}"
      expect(response). to have_http_status(:success)
    end
  end

  describe 'GET #reading' do
    it 'returns previously stored reading' do
      reading = FactoryBot.create(:reading)

      get "/reading/#{reading.thermostat_id}/#{reading.sequence_number}"
      expect(response).to have_http_status(:success)

      get "/reading/#{reading.thermostat_id}/#{reading.id+1000}"
      expect(response).to have_http_status(:not_found)
    end
  end
end
