require 'rails_helper'

describe Grouping do
  it { should belong_to(:round) }
  it { should have_and_belong_to_many(:participants) }

  let(:grouping) { FactoryBot.create :grouping }

  describe "#to_mentions" do
    subject { grouping.to_mentions }
    before { grouping.participants << participants }

    context "with 1 participant" do
      let(:participants) {
          [
            FactoryBot.create(:participant)
          ]
        }

      it { is_expected.to eq "#{participants[0].mention}" }
    end

    context "with 2 participants" do
      let(:participants) {
        [
          FactoryBot.create(:participant),
          FactoryBot.create(:participant)
        ]
      }

      it { is_expected.to eq "#{participants[0].mention} and #{participants[1].mention}" }
    end

    context "with 3 participants" do
      let(:participants) {
        [
          FactoryBot.create(:participant),
          FactoryBot.create(:participant),
          FactoryBot.create(:participant)
        ]
      }

      it { is_expected.to eq "#{participants[0].mention}, #{participants[1].mention} and #{participants[2].mention}" }
    end
  end

  describe "#to_names" do
    subject { grouping.to_names }

    before do
      grouping.participants << participants

      participants.each do |participant|
        allow(participant).to receive(:slack_user)
          .and_return(double(real_name: Faker::TvShows::Community.characters))
      end
    end

    context "with 1 participant" do
      let(:participants) {
          [
            FactoryBot.create(:participant)
          ]
        }

      it { is_expected.to eq "#{participants[0].name}" }
    end

    context "with 2 participants" do
      let(:participants) {
        [
          FactoryBot.create(:participant),
          FactoryBot.create(:participant)
        ]
      }

      it { is_expected.to eq "#{participants[0].name} and #{participants[1].name}" }
    end

    context "with 3 participants" do
      let(:participants) {
        [
          FactoryBot.create(:participant),
          FactoryBot.create(:participant),
          FactoryBot.create(:participant)
        ]
      }

      it { is_expected.to eq "#{participants[0].name}, #{participants[1].name} and #{participants[2].name}" }
    end
  end
end
