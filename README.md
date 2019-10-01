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

#### Channel commands
Invite the bot to a channel via `/invite pearbot`. You can interact with the bot by mentioning `@pearbot` directly. Alternatively you can start your command with `pearbot` or `🍐`

To interact with Pearbot, ask it variations of the following commands:
- **setup**: Starts a new pool for the current channel, you should only need to do this once.
- **refresh**: Updates pool participants to only the current members of the channel.
- **status**: Check some status information about the pool for the current channel, if it exists.
- **destroy**: Destroys the pool for the current channel.
- **pair**: Run a new round of pairing with all active participants from the channel pool. Snoozed partipants will be ignored.
- **remind**: Show the results of the last pairing round again.
- **snooze me**: Turn off pairing for the current user within this channel pool.
- **resume me**: Turn on pairing for the current user within this channel pool.
