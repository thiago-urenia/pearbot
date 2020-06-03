# Pearbot

## Getting started

### Setup a Slack bot
First clone the repo into a new folder `pearbot`

In Slack administration create a new Bot Integration under [services/new/bot](http://slack.com/services/new/bot). On the next screen, note the API token.

In your `pearbot` root folder, create a `.env` file with the API token from above. To enable gifs, you will need to
add a Giphy API token, you may use the public token `dc6zaTOxFJmzC` for testing.

```
SLACK_API_TOKEN=...
GIPHY_API_KEY=...
```

### Set up your database
You will need to create your local DBs:

```
bundle exec rake db:create
bundle exec rake db:migrate
```

You can optionally seed your database with dummy data:

```
bundle exec rake db:seed
```

### Run your server
Run your rails server locally

```
bundle exec rails s
```

Alteratively, start it via Foreman:

```
foreman start
```

### Interacting with the bot

Invite the bot to a channel via `/invite pearbot`. You can interact with the bot by mentioning `@pearbot` directly. Alternatively you can start your command with `pearbot` or `🍐`

In-order to run Pearbot, you must first setup a *pool* of partipants for a given channel. Run `pearbot setup` to do this for the first time. All non-bot users will automatically be put into the pool to start with. Run `pearbot status` to check the current status of the pool and its members. You can manually refresh the pool at any time by running `pearbot refresh`. This will clean out any members who have left the channel and add any new joiners. The pool will automatically be refreshed before any pairing.

Run `pearbot pair` for a new round of pairs. This will notify each member of their pair and print the results in the channel. I would suggest adding this as a regular Slack reminder in your channel. If you would like to re-run pairings, simply run `pearbot pair` to match everyone up again. You can run `pearbot reminder` at any time to see re-display the last round of pairings (without notifying each user again).

Users can temporarily disable pairing without leaving the channel by running `pearbot snooze me`. You can snooze another user from the pool (for example, if they are on holiday) by running `pearbot snooze [@username]`. To resume pairing run either `pearbot resume me` or `pearbot resume [@username]`.

### Commands
To interact with Pearbot using one of the following commands (eg `@pearbot hi`, `pearbot hi`, `🍐 hi` ).

You can always say `pearbot help` for a reminder of all of these commands.

- **hi**: Wave hello to Pearbot to confirm that it is currently running.

#### Pool management
- **setup**: Start a new pairing pool for the current channel. You will only need to setup the pool once.
- **refresh**: Refresh the pool so it matches the current members of the channel.
- **status**: Display status information about the pool members and when they were last paired.
- **destroy**: Destroy the pool for the current channel. (This is destructive and you will lose any user statuses.)

#### Pairing
- **pair**: Pair up all active participants from the channel pool.
- **reminder / who did [someone] pair with**: Print the results of the last round of pairings.

#### User preferences
- **snooze me / snooze [@user]** - Temporarily disable pairing for either yourself or a given user from the pool.
- **resume me / snooze [@user]** - Re-enable pairing for either yourself or a given user from the pool.
