# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sprint, type: :model do
  describe 'Model tests for sprints' do
    context 'validations' do
      it { should validate_presence_of(:name) }
    end

    context 'associations' do
      it { should belong_to(:project) }
    end
  end
end
