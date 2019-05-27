class V1::ReadingController < ApplicationController
  def reading
    sequence_number = params['sequence_number']
    thermostat_id = params['thermostat_id']

    key = "thermostat_#{thermostat_id}_#{sequence_number}"
    data = RedisService.get_data key
    unless data
      data = Reading.find_by thermostat_id: thermostat_id, sequence_number: sequence_number
    end
    if data
      render json: data
    else
      render status: :not_found
    end
  end

  def store_reading
    thermostat_id = reading_params['thermostat_id']

    current_thermostat_sequence = RedisService.get_current_sequence_number thermostat_id

    if current_thermostat_sequence.nil?
      thermostat = Thermostat.find thermostat_id
      current_thermostat_sequence = thermostat.sequence_number
    end

    current_thermostat_sequence = current_thermostat_sequence.to_i + 1
    RedisService.set_data current_thermostat_sequence, reading_params
    RedisService.set_current_sequence_number thermostat_id, current_thermostat_sequence

    params['sequence_number'] = current_thermostat_sequence
    StoreReadingJob.perform_later(reading_params)

    render json: current_thermostat_sequence
  end

  def stats
    data = RedisService.get_stats params['thermostat_id']
    render json: data
  end

  private

  def reading_params
    params.require(:reading).permit(:thermostat_id, :temperature, :humidity, :battery_charge, :sequence_number)
  end
end
