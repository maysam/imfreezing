class RedisService
  def self.redis
    @redis ||= Redis::Namespace.new('iamfreezing', redis: Redis.new)
    Rails.logger.info "@redis=#{@redis}"
    @redis
  end

  def self.get_current_sequence_number(thermostat_id)
    redis.get "thermostat_#{thermostat_id}"
  end

  def self.set_current_sequence_number(thermostat_id, sequence_number)
    redis.set "thermostat_#{thermostat_id}", sequence_number
  end

  def self.set_data(current_sequence_number, data)
    thermostat_id = data.delete 'thermostat_id'

    old_data = get_stats thermostat_id
    new_data = data

    old_data.each do |key, value|
      new_data[key] = (data[key].to_f + value.to_f*(current_sequence_number-1)) / current_sequence_number
    end

    key = "thermostat_#{thermostat_id}_#{current_sequence_number}"
    redis.set key, data.to_json

    set_stats thermostat_id, data

    current_sequence_number
  end

  def self.get_data(key)
    data = redis.get key
    JSON.parse data if data
  end

  def self.get_stats(thermostat_id)
    keys = ['temperature', 'humidity', 'battery_charge']
    stats = {}
    keys.each do |key|
      stats[key] = redis.get "stats_#{thermostat_id}_#{key}"
    end
    stats
  end

  def self.set_stats(thermostat_id, data)
    data.each do |key, value|
      redis.set "stats_#{thermostat_id}_#{key}", value
    end
  end
end
