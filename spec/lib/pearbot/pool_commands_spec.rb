require 'rails_helper'

describe "commands" do
  let(:bot) { SlackRubyBot.config.user }

  describe Pearbot::PoolCommands::PearbotCommand do
    describe ".replace_me_with_id" do
      let(:current_user_id) { "current-user-id" }
      subject { described_class.replace_me_with_id(parsed_id, current_user_id) }

      context "when matches me" do
        let(:parsed_id) { "me" }
        it { is_expected.to eq current_user_id }
      end

      context "not not matching me" do
        let(:parsed_id) { "rando" }
        it { is_expected.to eq parsed_id }
      end
    end
  end

  describe Pearbot::PoolCommands::Setup do
    let(:command) { "#{bot} setup" }

    let(:pool) { FactoryBot.build(:pool, slack_channel_id: "some-channel") }
    before { expect(Pool).to receive(:new).and_return(pool) }

    context "when valid" do
      it "loads participants" do
        expect(pool).to receive(:load_participants)
        expect(command).to respond_with_slack_message /Started a new pool for <#channel> with .* participants/
      end
    end

    context "when invalid" do
      before { allow(pool).to receive(:save).and_return(false) }
      it "does not load participants" do
        expect(pool).not_to receive(:load_participants)
        expect(command).to respond_with_slack_message /A pool for <#channel> already exist/
      end
    end
  end

  describe Pearbot::PoolCommands::Refresh do
    let(:command) { "#{bot} refresh" }
    before { expect(Pool).to receive(:find_by).and_return(pool) }

    context "when a pool is found" do
      let(:pool) { FactoryBot.create :pool }
      it "refreshes the pool" do
        expect(pool).to receive(:refresh_participants)
        expect(command).to respond_with_slack_message /Refreshing the pool for <#channel>.\nThere are now .* participants/
      end
    end

    context "when no pool found" do
      let(:pool) { nil }
      it "responds with an error" do
        expect_any_instance_of(Pool).not_to receive(:refresh_participants)
        expect(command).to respond_with_slack_message /No pool for <#channel> exists./
      end
    end
  end

  describe Pearbot::PoolCommands::Status do
    let(:command) { "#{bot} status" }
    before { expect(Pool).to receive(:find_by).and_return(pool) }

    context "when a pool is found" do
      let(:pool) { FactoryBot.create :pool }
      it "refreshes the pool and responds with the latest status information" do
        expect(pool).to receive(:refresh_participants)
        expect(command).to respond_with_slack_message /There are currently/
      end
    end

    context "when no pool found" do
      let(:pool) { nil }
      it "responds with an error" do
        expect(command).to respond_with_slack_message /No pool for <#channel> exists./
      end
    end
  end

  describe Pearbot::PoolCommands::Destroy do
    let(:command) { "#{bot} destroy" }
    before { expect(Pool).to receive(:find_by).and_return(pool) }

    context "when a pool is found" do
      let(:pool) { FactoryBot.create :pool }
      it "destroys the pool" do
        expect(pool).to receive(:destroy)
        expect(command).to respond_with_slack_message /Destroyed the pool for <#channel>/
      end
    end

    context "when no pool found" do
      let(:pool) { nil }
      it "responds with an error" do
        expect(command).to respond_with_slack_message /No pool for <#channel> exists./
      end
    end
  end

  describe Pearbot::PoolCommands::Pair do
    let(:command) { "#{bot} pair" }
    before { expect(Pool).to receive(:find_by).and_return(pool) }

    context "when a pool is found" do
      let(:pool) { FactoryBot.create :pool }
      context "with no available participants" do
        it "does not run a new round" do
          expect(pool).to receive(:refresh_participants)
          expect(Round.count).to eq 0
          expect(command).to respond_with_slack_message /Looks like nobody's available for pairing/
        end
      end

      context "with 1 available participant" do
        before { FactoryBot.create(:pool_entry, :available, pool: pool) }

        it "does not run a new round" do
          expect(pool).to receive(:refresh_participants)
          expect(Round.count).to eq 0
          expect(command).to respond_with_slack_message /looks like you're on your own/
        end
      end

      context "with multiple available participants" do
        before do
          2.times { FactoryBot.create(:pool_entry, :available, pool: pool) }
        end

        it "runs a new round" do
          expect(pool).to receive(:refresh_participants)
          expect(Round.count).to eq 0
          expect(command).to respond_with_slack_message /The next round of pairs are/
          expect(Round.count).to eq 1
        end
      end
    end

    context "when no pool found" do
      let(:pool) { nil }
      it "responds with an error" do
        expect(command).to respond_with_slack_message /No pool for <#channel> exists./
      end
    end
  end

  describe Pearbot::PoolCommands::Reminder do
    let(:command) { "#{bot} reminder" }
    before { expect(Pool).to receive(:find_by).and_return(pool) }

    context "when a pool is found" do
      let(:pool) { FactoryBot.create :pool }

      context "and there are previous rounds" do
        before { FactoryBot.create(:round, pool: pool) }
        it "responds with details from the last round" do
          expect(pool).to receive(:refresh_participants)
          expect(command).to respond_with_slack_message /Last draw/
        end
      end

      context "and there are no previous rounds" do
        it "responds that there have been no round" do
          expect(pool).to receive(:refresh_participants)
          expect(command).to respond_with_slack_message /You haven't ran any rounds in <#channel>/
        end
      end
    end

    context "when no pool found" do
      let(:pool) { nil }
      it "responds with an error" do
        expect(command).to respond_with_slack_message /No pool for <#channel> exists./
      end
    end
  end

  describe Pearbot::PoolCommands::Snooze do
    let!(:my_user) { FactoryBot.create(:participant, slack_user_id: "user") }
    let!(:another_user) { FactoryBot.create(:participant, slack_user_id: "rando") }

    before do
      expect(Pool).to receive(:find_by_channel_id_and_refresh).and_return(pool)
      allow_any_instance_of(Participant).to receive(:name) { |p| p.slack_user_id.titleize }
    end

    context "when a pool exists" do
      let(:pool) { FactoryBot.create :pool }
      skip "snoozing myself" do
        let(:command) { "#{bot} snooze me" }

        context "when I am in the current pool" do
          before { my_user.join_pool(pool) }
          it "snoozes you from the current pool" do
            expect(command).to respond_with_slack_message /Snoozed drawing for #{my_user.name} in <#channel>/
            expect(pool.snoozed_participants).to include my_user
          end
        end

        context "when I am not in the current pool" do
          it "responds that this user is not in the pool" do
            expect(command).to respond_with_slack_message /#{my_user.name} is not in the pool, ask them to join <#channel>/
          end
        end
      end

      context "snoozing a specific username" do
        let(:command) { "#{bot} snooze <@#{another_user.slack_user_id}>" }

        context "when a user is found" do
          context "and they are in the current pool" do
            before { another_user.join_pool(pool) }
            it "snoozes them from the current pool" do
              expect(command).to respond_with_slack_message /Snoozed drawing for #{another_user.name} in <#channel>/
              expect(pool.snoozed_participants).to include another_user
            end
          end

          context "and they are not in the current pool" do
            it "responds that this user is not in the pool" do
              expect(command).to respond_with_slack_message /#{another_user.name} is not in the pool, ask them to join <#channel>/
            end
          end
        end

        context "when no user is found" do
          before { another_user.destroy }
          it "responds that no user was found" do
            expect(command).to respond_with_slack_message /Can't find that user/
          end
        end
      end
    end

    skip "when no pool found" do
      let(:command) { "#{bot} snooze me" }
      let(:pool) { nil }
      it "responds with an error" do
        expect(command).to respond_with_slack_message /No pool for <#channel> exists./
      end
    end
  end

  describe Pearbot::PoolCommands::Resume do
    let!(:my_user) { FactoryBot.create(:participant, slack_user_id: "user") }
    let!(:another_user) { FactoryBot.create(:participant, slack_user_id: "rando") }

    before do
      expect(Pool).to receive(:find_by_channel_id_and_refresh).and_return(pool)
      allow_any_instance_of(Participant).to receive(:name) { |p| p.slack_user_id.titleize }
    end

    context "when a pool exists" do
      let(:pool) { FactoryBot.create :pool }
      skip "resuming myself" do
        let(:command) { "#{bot} resume me" }

        context "when I am in the current pool" do
          before { my_user.join_pool(pool).snooze }
          it "marks you as available in the current pool" do
            expect(command).to respond_with_slack_message /Resumed drawing for #{my_user.name} in <#channel>/
            expect(pool.available_participants).to include my_user
          end
        end

        context "when I am not in the current pool" do
          it "responds that this user is not in the pool" do
            expect(command).to respond_with_slack_message /#{my_user.name} is not in the pool, ask them to join <#channel>/
          end
        end
      end

      context "resuming a specific username" do
        let(:command) { "#{bot} resume <@#{another_user.slack_user_id}>" }

        context "when a user is found" do
          context "and they are in the current pool" do
            before { another_user.join_pool(pool).snooze }
            it "marks you as available in the current pool" do
              expect(command).to respond_with_slack_message /Resumed drawing for #{another_user.name} in <#channel>/
              expect(pool.available_participants).to include another_user
            end
          end

          context "and they are not in the current pool" do
            it "responds that this user is not in the pool" do
              expect(command).to respond_with_slack_message /#{another_user.name} is not in the pool, ask them to join <#channel>/
            end
          end
        end

        context "when no user is found" do
          before { another_user.destroy }
          it "responds that no user was found" do
            expect(command).to respond_with_slack_message /Can't find that user/
          end
        end
      end
    end

    skip "when no pool found" do
      let(:command) { "#{bot} resume me" }
      let(:pool) { nil }
      it "responds with an error" do
        expect(command).to respond_with_slack_message /No pool for <#channel> exists./
      end
    end
  end

end

