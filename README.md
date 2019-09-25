# Pearbot

## Getting started

### Setup a Slack bot
First clone the repo into a new folder `pearbot`

In Slack administration create a new Bot Integration under [services/new/bot](http://slack.com/services/new/bot). On the next screen, note the API token.

In your `pearbot` root folder, create a `.env` file with the API token from above.

```
SLACK_API_TOKEN=...
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
### Test commands

To test everything is working correctly, start a conversion with your bot in Slack. Or invite the bot to a channel via `/invite [bot name]` and send it a calculate command with `[bot name] calculate 2+2`.
It will respond with 4.

NB: In a direct conversation with the bot, you can simply ask the command directly without calling its name eg `calculate 2+2`)
