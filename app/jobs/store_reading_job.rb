class StoreReadingJob < ApplicationJob
  queue_as :default

  def perform(thermostat_id, sequence_number, data)
    p 'StoreReadingJob performing'
    thermostat = Thermostat.find thermostat_id
    thermostat.readings.create sequence_number: sequence_number, temperature: data['temperature'], humidity: data['humidity'], battery_charge: data['battery_charge']
  end
end
