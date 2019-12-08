# frozen_string_literal: true

require 'rails_helper'

describe RepositoryDateRangeValue, type: :model do
  let(:date_range_value) do
    create :repository_date_range_value, start_time: Time.utc(2000, 10, 10), end_time: Time.utc(2000, 10, 11)
  end

  describe '.formatted' do
    it 'prints date format with time' do
      str = '10/10/2000 - 10/11/2000'
      expect(date_range_value.formatted).to eq(str)
    end
  end

  describe '.data_changed?' do
    context 'when has different date value' do
      let(:new_values) do
        {
          start_time: Time.utc(2000, 10, 10).to_s,
          end_time: Time.utc(2000, 10, 12).to_s
        }
      end

      it do
        expect(date_range_value.data_changed?(new_values)).to be_truthy
      end
    end

    context 'when has same date value (but different time)' do
      let(:new_values) do
        {
          start_time: Time.utc(2000, 10, 10).to_s,
          end_time: Time.utc(2000, 10, 11, 4, 11).to_s
        }
      end

      it do
        expect(date_range_value.data_changed?(new_values)).to be_falsey
      end
    end
  end
end
