require 'rails_helper'

describe RoundCreator do
  let(:pool) { FactoryBot.create :pool }
  let(:round_creator) { RoundCreator.new(pool) }

  describe "#create" do
    subject { round_creator.create }
    let(:drawn_groupings) { subject.groupings }

    context "for 0 participants" do
      it "returns a round" do
        expect(subject).to be_a Round
        expect(subject.pool).to be pool
      end

      it "does not draw any groupings" do
        expect(drawn_groupings).to be_empty
      end
    end

    context "for 1 participant" do
      before do
        FactoryBot.create(:pool_entry, :available, pool: pool)
      end

      it "returns a round with one grouping" do
        expect(subject).to be_a Round
        expect(subject.pool).to be pool
      end

      it "does not draw any groupings" do
        expect(drawn_groupings).to be_empty
      end
    end

    context "for 2 participants" do
      before do
        2.times { FactoryBot.create(:pool_entry, :available, pool: pool) }
      end

      it "returns a round" do
        expect(subject).to be_a Round
        expect(subject.pool).to be pool
      end

      it "draws one grouping of 2" do
        groupings = subject.groupings

        expect(drawn_groupings.count).to eq 1
        expect(drawn_groupings.first.participants.count).to eq 2
      end
    end

    context "for 6 participants" do
      before do
        6.times { FactoryBot.create(:pool_entry, :available, pool: pool) }
      end

      it "returns a round" do
        expect(subject).to be_a Round
        expect(subject.pool).to be pool
      end

      it "draws 3 groupings" do
        expect(drawn_groupings.count).to eq 3
      end

      specify "drawn groupings have exactly 2 participants" do
        drawn_groupings.each do |grouping|
          expect(grouping.participants.count).to eq 2
        end
      end
    end

    context "for 7 participants" do
      before do
        7.times { FactoryBot.create(:pool_entry, :available, pool: pool) }
      end

      it "returns a round" do
        expect(subject).to be_a Round
        expect(subject.pool).to be pool
      end

      it "draws 3 groupings" do
        expect(subject.groupings.count).to eq 3
      end

      specify "drawn groupings have at least 2 participants" do
        drawn_groupings.each do |grouping|
          expect(grouping.participants.count).to be >= 2
        end
      end
    end
  end
end
