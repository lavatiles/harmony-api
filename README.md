# Discontinued. Maybe?

⚠️⚠️⚠️ Harmony API has been MAYBE discontinued. ⚠️⚠️⚠️

~~The open local API in the Harmony Hub that Harmony API relied on has been closed in the most current firmware. Logitech [has made it public](https://community.logitech.com/s/question/0D55A00008D4bZ4SAJ/harmony-hub-firmware-update-fixes-vulnerabilities) that they do not intend to open it back up. This effectively renders Harmony API useless.~~

Harmony has said that they will be bringing back the local API. When that happens in January, I'll look to see how much work it is to incorporate the changes and maybe bring the project back.

## What should I use instead?

Here are some options moving forward:

### Downgrade and Block Internet from your Hub

Home Assistant has [provided some instructions](https://www.home-assistant.io/blog/2018/12/17/logitech-harmony-removes-local-api/#reverting-the-software-update) for downgrading your Hub back to a firmware version that supports the local API. You can use this and continue using Harmony API.

### Home Assistant
If you use Home Assistant, please upgrade to at least [0.84.4](https://www.home-assistant.io/blog/2018/12/12/release-84/#release-0844---december-19) and use their Harmony component. They have ported their Harmony component to utilize the websocket API.

If you don't use Home Assistant, I'd highly suggest using it.






# Harmony API!!

Harmony API is a simple server allowing you to query/control multiple local [Harmony
Home Hubs](http://myharmony.com/products/detail/home-hub/) and their devices
over HTTP or MQTT.

With HTTP, you can simply turn on and off activities, check hub status, and send
commands to individual devices with simple HTTP requests from almost any other
project.

With MQTT, you can easily monitor the state of your devices as well as set
the current activity of your hub or send specific commands per device. This
makes it super easy to integrate into your existing home automation setup.


## Features

* Control multiple Harmony hubs.
* List activities.
* Get current status, including if everything is off, or what the current
activity is.
* Turn everything off.
* Start a specific activity.
* List devices.
* List device commands.
* Execute discrete commands for each device.

## Setup

    script/bootstrap

## Settings

Harmony API discovers your hubs automatically. You can optionally add your MQTT
broker's host to connect to it.

```json
{
  "mqtt_host": "mqtt://192.168.1.106",
  "mqtt_options": {
      "port": 1883,
      "username": "someuser",
      "password": "somepassword",
      "rejectUnauthorized": false
  },
  "topic_namespace": "home/harmony"
}
```

`mqtt_options` is optional, see the [mqtt](https://github.com/mqttjs/MQTT.js#connect) project for
allowed host and options values.

## Running It
Get up and running immediately with `script/server`.

#### Note:
On some distros, you might get an error when running it:
`/usr/bin/node: No such file or directory`

That can probably be fixed by creating a symlink:
``sudo ln -s `which nodejs` /usr/bin/node``

Harmony API will run on port `8282` by default. Use the `PORT` environment
variable to use your own port.

### Forever
harmony-api has support for [Forever](https://github.com/foreverjs/forever). It uses
`launchd` on OS X to kick it off so that it starts on boot.

### Development
You can simply run it by calling `script/server`. This will run it in development
mode with logging to standard out.

### Install as Service on OS X

    script/install

### Install as systemd unit on Linux

    sudo script/install-linux

### Docker
Installation with Docker is straightforward. Adjust the following command so that
`/path/to/your/config` points to the folder where your want to store your config and run it:

    $ docker run --name="harmony-api" -v /path/to/your/config:/config \
        -p 8282:8282 -d jonmaddox/harmony-api

This will launch Harmony API and serve the web interface from port 8282 on your Docker host. Hub
discovery requires host networking (`--net=host`). However, you can specify your Harmony Hub IP
address in `config.json` as `hub_ip`.

## Logging

Harmony API logs all of its requests. In `production`, it logs to a file at `log/logs.log`.
In `development` mode, it just logs to stdout.

## How to Upgrade to 2.0

Simply run `script/upgrade` from the root of the project and Harmony API will
upgrade to the newest version.

You are then going to have to change anything you integrate with Harmony API to
reflect the change in HTTP endpoints and MQTT topics. Read the docs in this
README to see how they have changed.

## Development

Launch the app via `script/server` to run it in the development environment.

## MQTT Docs

harmony-api can report its state changes to your MQTT broker. Just edit your
config file in `config/config.json` to add your MQTT host and options.

By default harmony-api publishes topics with the namespace of: `harmony-api`. This can be overriden
by setting `topic_namespace` in your config file.

### State Topics

When the state changes on your harmony hub, state topics will be immediately
broadcasted over your broker. There's quite a few topics that are broadcasted.

State topics are namespaced by your Harmony hub's name, as a slug. You can rename your hub
in the Harmony app.

Here's a list:

#### Current State

This topic describes the current power state. Message is `on` or `off`.

`harmony-api/hubs/family-room/state` `on`

#### Current Activity

This topic describes what the current activity of the hub is. The message is
the slug of an activity name.

`harmony-api/hubs/family-room/current_activity` `watch-tv`

#### Activity States

These topics describe the state of each activity that the hub has. The message
is `on` or `off`. There will a topic for every activity on your hub.

`harmony-api/hubs/family-room/activities/watch-tv/state` `off`  
`harmony-api/hubs/family-room/activities/watch-apple-tv/state` `on`  
`harmony-api/hubs/family-room/activities/play-xbox-one/state` `off`  


### Command Topics

You can also command harmony-api to change activities, and issue device and acivity commands by publishing topics.
harmony-api listens to these topics and will change to the activity, or issue the command when it sees
it.

#### Switching activities
Just provide the slug of the hub and activity you want to switch to and `on` as
the message. Any use of this topic with the message `off` will turn everything
off.

`harmony-api/hubs/family-room/activities/watch-tv/command` `on`  

#### Device commands
Just provide the slug of the hub and the device to control with the command you want to execute.
`harmony-api/hubs/family-room/devices/tv/command` `volume-down`

To optionally repeat the command any number of times, provide an optional repeat integer.
`harmony-api/hubs/family-room/devices/tv/command` `volume-down:5`

#### Current activity commands
Just provide the slug of the hub and the command you want to execute.
`harmony-api/hubs/family-room/command` `volume-down`

To optionally repeat the command any number of times, provide an optional repeat integer.
`harmony-api/hubs/family-room/command` `volume-down:5`

## HTTP API Docs

This is a quick overview of the HTTP service. Read [app.js](app.js) if you need more
info.

### Resources

Here's a list of resources that may be returned in a response.

#### Activity Resource

The Activity resource returns all the information you really need for an
Activity set up in your Harmony Hub.

```json
{
  "id": "15233552",
  "slug": "watch-tv",
  "label": "Watch TV",
  "isAVActivity": true
}
```

#### Device Resource

The Device resource returns all the information you need to know about the
devices set up for the hub.

```json
{
  "id": "38343689",
  "slug": "tivo-premiere",
  "label": "TiVo Premiere"
}
```

#### Command Resource

The Command resource returns all the information you really need for a
Command to let you execute it.

```json
{
  "name": "ChannelDown",
  "slug": "channel-down",
  "label":"Channel Down"
}
```

#### Status Resource

The Status resource returns the current state of your Harmony Hub.

```json
{
  "off": false,
  "current_activity": {
    "id": "15233552",
    "slug": "watch-tv",
    "label": "Watch TV",
    "isAVActivity": true
  }
}
```

### Methods

These are the endpoints you can hit to do things.

#### Info
  Use these endpoints to query the current state of your Harmony Hub.

    GET /hubs => {"hubs": ["family-room", "bedroom"] }
    GET /hubs/:hub_slug/status => StatusResource
    GET /hubs/:hub_slug/commands => {"commands": [CommandResource, CommandResource, ...]}
    GET /hubs/:hub_slug/activities => {"activities": [ActivityResource, ActivityResource, ...]}
    GET /hubs/:hub_slug/activities/:activity_slug/commands => {"commands": [CommandResource, CommandResource, ...]}
    GET /hubs/:hub_slug/devices => {"devices": [DeviceResource, DeviceResource, ...]}
    GET /hubs/:hub_slug/devices/:device_slug/commands => {"commands": [CommandResource, CommandResource, ...]}

#### Control
  Use these endpoints to control your devices through your Harmony Hub.

    PUT /hubs/:hub_slug/off => {message: "ok"}
    POST /hubs/:hub_slug/commands/:command_slug => {message: "ok"}
    POST /hubs/:hub_slug/commands/:command_slug?repeat=3 => {message: "ok"}
    POST /hubs/:hub_slug/activities/:activity_slug => {message: "ok"}
    POST /hubs/:hub_slug/devices/:device_slug/commands/:command_slug => {message: "ok"}
    POST /hubs/:hub_slug/devices/:device_slug/commands/:command_slug?repeat=3 => {message: "ok"}

## Contributions

* fork
* create a feature branch
* open a Pull Request

# LavaTiles stuff

## PI
cd LavaTiles
git clone https://github.com/lavatiles/harmony-api.git
sudo npm install forever -g
script/bootstrap
Test with: script/server
It works:
Starting discovery.
Hub discovered: GreatRoom at 192.168.1.23.
Updating activities for greatroom.
sudo script/install-linux
It works:
+ set -e
++ dirname script/install-linux
+ cd script/..
+ INSTALL_PATH=/var/lib/harmony-api
+ CONF_PATH=/etc/harmony-api
+ echo 'Installing harmony-api for Linux...'
Installing harmony-api for Linux...
+ mkdir -p /var/lib/harmony-api
+ cp -R app.js config Dockerfile LICENSE log node_modules package.json package-lock.json public README.md script /var/lib/harmony-api
+ ln -sf /var/lib/harmony-api/config /etc/harmony-api
+ ln -sf /var/lib/harmony-api/config/harmony-api-server.service /etc/systemd/system/
+ systemctl enable harmony-api-server.service
Created symlink /etc/systemd/system/multi-user.target.wants/harmony-api-server.service → /var/lib/harmony-api/config/harmony-api-server.service.

Enable at reboot
sudo systemctl enable harmony-api-server
Check Status
sudo systemctl status harmony-api-server
Browser: http://lavatiles:8282/
