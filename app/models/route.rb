class Route < ActiveRecord::Base
  belongs_to :map

  validates :origin, :destination, :distance, presence: true

  validate :origin_destination_validation
  validate :validate_uniqueness_of_origin_destination_map

  def origin_destination_validation
    if origin.present? && origin.casecmp(destination).zero?
      errors.add(:destination, "can't be equals to origin")
    end
  end

  def validate_uniqueness_of_origin_destination_map
    match = Route.where('lower(origin) = lower(?) AND lower(destination) = lower(?) AND map_id = ?', self.origin, self.destination, self.map_id).first
    errors.add(:origin, "can't be duplicated by destination and map") if match
  end
end
