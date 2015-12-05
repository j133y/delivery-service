class Route < ActiveRecord::Base
  belongs_to :map

  validates :origin, uniqueness: { scope: [:destination, :map_id], case_sensitive: false }

  validates :origin, :destination, :distance, presence: true

  validate :origin_destination_validation

  def origin_destination_validation
    if origin.present? && origin.casecmp(destination).zero?
      errors.add(:destination, "can't be equals to origin")
    end
  end
end
