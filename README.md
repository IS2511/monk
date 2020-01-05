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
    trusted = {}
  },
  doGeneralMessages = true,
  lowEnergyPercent = 0
}
```

- `scan:enable`: If `true` periodic ping broadcasts are made
- `scan:delay`: Delay between ping broadcast in seconds, rounded to seconds
- `scan:radius`: Broadcast radius in blocks
- `network:autoconnect`: If `true` node autoconnects to trusted networks
- `network:trusted`: List of trusted networks, `[network]=true` format
- `doGeneralMessages`: If `true` general messages will be auto-processed
- `lowEnergyPercent`: Disable scanning if energy is lower than this, `0` is off

## Events

- `monk(event: string, options: any)`: Service events. Possible events:
  - `start`: Service started! Hooray!
  - `stop`: Service stopped, dependents may stop themselves or restart `monk`
  - `online`: Just connected to a network, `options: string` name of network
  - `offline`: Just lost connection, `options: string` name of network

- `monk_general(header: table, payload: string)`: General messages.           
  Event for messages on port `500` ([Ports](#ports)) in [General](#general-packet) format. The `header` is left untouched, but `payload` is auto-decrypted if possible

## Network

### Ports

- `500`: Used for any communication with `monk`'s [general](#general-packet) packet format.
- `501`: Reserved for `monk` ping messages. [Ping](#ping-packet) packets only
- `510`: Reserved for `monk` service messages. [Service](#service-packet) packets only

Those are the only strictly reserved ports, `monk` can be used on any port.

### Packet structure

#### General packet:

- `header`: Protocol data, addresses, etc. Serialized table
  - `procotol`: Specified by user, `monk` is reserved
  - `hash`: Checking integrity of payload (optional)
  - `src`: Source hardware address
  - `dst`: Destination hardware address
  - `time`: When was this sent (optional?)
  - `encryption`: Table. See [encryption](#encryption) for more info
    - `m`: `?`, `!` or `-`
    - `cipher`: `AES`, other may be coming later
    - `iv`: If `AES` then iv is here.
  - `signature`: If signed.
- `payload`: Serialized data, may be encrypted

#### Ping packet:

- `m`: `?` - ping, `n` - node pong, `c` - client pong, `!` - joined network
- `status`: `online` or `offline` (in answer)
- `network`: Name of the network already in (in pong) or joining to (in `!`)

#### Service packet:

It looks just like the general packet but actually can be in any form. These packets are not for users anyway. If you are still interested:

- `header`: Protocol data, addresses, etc. Serialized table
  - `hash`: Checking integrity of payload
  - `src`: Source hardware address
  - `dst`: Destination hardware address
  - `time`: When was this sent (optional?)
  - `encryption`: Table. See [encryption](#encryption) for more info
    - `m`: `?`, `!` or `-`
    - `cipher`: `AES`, other may be coming later
    - `iv`: If `AES` then iv is here.
  - `signature`: If signed.
- `payload`: Serialized data, may be encrypted

### Encryption

There is 1 encryption method available right now: AES.

#### AES

To create a key pair you need a tier-3 data card. To generate a Diffie-Hellman shared key (used for encrypting and decrypting) you need a tier-3 data card, again. BUT, technically after you saved the shared key you can use it with a tier-2 data card, without signing capabilities of course. Anyway, I won't do all this and just say: **You need a tier-3 data card to use AES encryption!**

There are 2 messages to a successful handshake:

###### First looks like this (A -> B). Request
  - `encryption`: Table. Only present if needed
    - `m`: `?`
    - `cipher`: `AES`
    - `public`: Public key of host A

###### Second looks like this (B -> A). Response
  - `encryption`: Table. Only present if needed
    - `m`: `!`
    - `cipher`: `AES`
    - `public`: Public key of host B

### Signing
