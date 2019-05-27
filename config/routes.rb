Rails.application.routes.draw do
  scope module: :v1, constraints: ApiVersion.new('v1', true) do
    post 'reading', to: 'reading#store_reading'

    get 'reading/:thermostat_id/:sequence_number', to: 'reading#reading'
    get 'stats/:thermostat_id', to: 'reading#stats'
  end
end
