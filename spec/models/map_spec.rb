require 'rails_helper'

RSpec.describe Map, :type => :model do
  describe 'validations' do
    it { expect(subject).to validate_uniqueness_of(:name) }
  end
end
