# monk

![https://thenounproject.com/term/monk/583034/](https://d30y9cdsu7xlg0.cloudfront.net/png/583034-200.png)

A wise peer-to-peer network, versatile tool for network management.
Feel the freedom of not having to think about the delivery of your data.

## Installing

~~TODO: add this to hpm repo!~~ Awaiting hpm rewrite (will it happen?)

Installer (uses github):

```
pastebin run dpTDJfcV
```

## Commands

- `man monk`: Probably opens this README.md, idk

### Service (rc.lua)

- `rc monk start`: I wonder what that does?
- `rc monk stop`: Read some linux manuals I guess
- `rc monk enable`: Or try `man rc` if you know what I mean
- `rc monk disable`: Now to the interesting commands
- `rc monk restart`: Quality of life, `stop` and `start` in sequence
- `rc monk reload`: Quality of life, reloads config without restart, for busy servers
- `rc monk status`: AdVaNcEd, check for service stats and status

### Executable

- `monk configurator`: Launch the configurator. Good place to start after installing
- `monk config <variable> [value]`: Read/write config. Preferred over direct file editing
- `monk register-rc`: Register service in rc, also can be done in `configurator`
- `monk generate-config`: Write default config to `monk.cfg.example`

## Config

**NOTE**: `monk config` is preferred over direct editing of main config

| Config   | Location                   | Description
| -------- | -------------------------- | ---
| Main     | `/etc/monk/monk.cfg`       | `rc.d` config and more
| Protocol | `/etc/monk/protocol/?.cfg` | Replace `?` with protocol name

## Events

- `monk_general(header: table, payload: string)`: General messages.           
  Event for messages on port `500` ([Ports](#ports)).
  The `header` is left untouched, but `payload` is 


- `monk_service(event: string, options: any)`: Service events. Possible events:
  - `start`: Service started! Hooray!
  - `stop`: Service stopped, dependents may stop themselves
  - `online`: Just connected to a network, `options: string` name of network
  - `offline`: Just lost connection, `options: string` name of network


## Protocols

| Name                  | Version | Description
| --------------------- | ------: | ---
| [mIP](doc/mIP.md)     |       1 | Routing, fragmentation
| [mTCP](doc/mTCP.md)   |       1 | Streams, delivery check
| [mBCP](doc/mBCP.md)   |       1 | Backwards compatibility
| [mLCB](doc/mLCB.md)   |       1 | Link card for long bridges
| [mRWB](doc/mRWB.md)   |       1 | Link over Internet (capital I)

## Quick FAQ

- Q: Does this all even work?\
  A: I sure hope so
- Q: Is this your first time doing something like this?\
  A: First time doing such a big project, on lua too
- Q: Does this project scare you?\
  A: A bit
- Q: How did this project start?\
  A: Well, I woke up this morning... Then there was a ~~hole~~ project
- Q: Is this FAQ here just for jokes?\
  A: Mostly
- Q: Can you fit more jokes here?\
  A: Apparently no

## Network

Those are the only strictly reserved ports, `monk` can be used on any port.

### 