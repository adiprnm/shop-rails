class Setting < ApplicationRecord
  encrypts :value

  def self.bulk_update(params)
    params.each do |key, value|
      find_or_initialize_by(key: key).update(value: value)
    end
  end
end
