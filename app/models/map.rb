class Map < ActiveRecord::Base
  has_many :routes, dependent: :delete_all

  accepts_nested_attributes_for :routes

  validates :name, uniqueness: true

  validates :name, presence: true
end
