require 'rails_helper'

describe PoolEntry do
  it { should belong_to(:participant) }
  it { should belong_to(:pool) }

  let!(:available_entry) { FactoryBot.create(:pool_entry, :available) }
  let!(:snoozed_entry) { FactoryBot.create(:pool_entry, :snoozed) }

  describe ".available" do
    subject { described_class.available }
    it { is_expected.to eq [available_entry] }
  end

  describe ".available" do
    subject { described_class.snoozed }
    it { is_expected.to eq [snoozed_entry] }
  end

  describe "#snooze" do
    subject { available_entry}
    it "sets the status to snoozed" do
      subject.snooze
      expect(subject.status).to eq PoolEntry::SNOOZED
    end
  end

  describe "#resume" do
    subject { snoozed_entry }
    it "sets the status to available" do
      subject.resume
      expect(subject.status).to eq PoolEntry::AVAILABLE
    end
  end
end
