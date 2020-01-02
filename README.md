# monk

Peer-to-peer network. Address book included. `monk` network provides "network layer" according to [OSI model](https://en.wikipedia.org/wiki/OSI_model).

When needed `client` and `node` will be used, otherwise node is the general term to talk about any part of the network.

## Installing

TODO: add this to hpm repo.

Recommended method:

```
hpm install monk
```

Installing from git:

```
pastebin run ???
```

## Config

Config is stored in `/etc/monk.cfg`. Default config:

```
{
  scan = {
    enable = true,
    delay = 60,
    radius = 400
  },
  network = {
    autoconnect = true,
    filter = "*"
  },
  lowEnergyPercent = 0
}
```

- `scan:enable`: If `true` periodic ping broadcasts are made
- `scan:delay`: Delay between ping broadcast in seconds
- `scan:radius`: Broadcast radius in blocks
- `lowEnergyPercent`: Disable scanning if energy is lower than this, `0` is off

## Events

- `monk(event: string, options: table)`: Service events (rc.lua)
- `monk_general(header: table, payload: string)`: General messages

## Network

### Ports

- `500`: Used for any communication with `monk`'s general packet format.
- `501`: Reserved for `monk` ping messages. Ping packets only
- `510`: Reserved for `monk` service messages. Service packets only

Those are the only strictly reserved ports, `monk` can be used on any port.

### Packet structure

#### General packet:

- `header`: Protocol defines, addresses, etc.
  - `procotol`: Specified by user, `monk` is reserved
  - `hash`: Checking integrity of payload (optional)
  - `src`: Source hardware address
  - `dst`: Destination hardware address
  - `date`: When was this sent
- `payload`: Serialized data, may be encrypted

#### Ping packet:

- `header`: Protocol defines, addresses, etc.
  - `m`: `?` - ping, `n` - node pong, `c` - client pong, `!` - joined network
  - `status`: `online` or `offline` (in answer)
  - `network`: Name of the network already in (in pong) or joining to (in `!`)

#### Service packet:

- `header`: Protocol defines, addresses, etc.
  - `hash`: Checking integrity of payload
  - `src`: Source hardware address
  - `dst`: Destination hardware address
  - `date`: When was this sent
- `payload`: Serialized data, may be encrypted
