## Tooter

Simple little ruby script to x-post my tweets to a specified mastodon instance. 

Basically just needs an app created in twitter + your mastodon instance, so to run:
- Set the ENV vars appropriately
- Fire up a redis instance
- bundle install
- Set up either a cronjob to run every so often or use `poll.sh` to run every so often

And your tweets will be mirrored!
