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

```Lua
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
    - `cipher`: `AES`, other may be coming later
    - `iv`: If `AES` then iv is here.
  - `signature`: If signed.
- `payload`: Serialized data, may be encrypted

### Encryption

You generally need a **tier-3 data card** at both ends! No data card required for transfer nodes though. More info in [Key exchange](#key-exchange)

There is 1 encryption method available right now: [AES](#aes).

#### AES


More info in [Key exchange](#key-exchange)

### Signing

You generally need a **tier-3 data card** at both ends! No data card required for transfer nodes though. Yes, same as encrypting. More info in [Key exchange](#key-exchange)

There is 1 signing method available right now: [DSA](#dsa).

#### DSA



### Key exchange

To create a key pair you need a tier-3 data card. To generate a Diffie-Hellman shared key (used for encrypting and decrypting) you need a tier-3 data card, again. BUT, technically after you saved the shared key you can use it with a tier-2 data card, without signing capabilities of course. Anyway, I won't do all this and just say: **You need a tier-3 data card to use AES encryption or DSA signing!** I am however thinking about organizing a UUID list with nodes trusted for shared key generation and/or key pair generation. This seems like a doable idea, but for now the main thing isn't finished yet so it's a low priority.

Keys are stored in the address book among with 2 tables of supported ciphers and signing methods.

```Lua
addressBook = {
  ["34eb7b28-14d3-4767-b326-dd1609ba92e"] = {
    cipher = {"AES"},
    sign = {"DSA"},
    public = "key data here"
  },
  ["12345678-1234-1234-1234-123456789ab"] = true
}
```

Only the interesting part is shown, `payload` is optional. There are 2 messages to a successful handshake:

###### Request (A -> B)
- `header`: Protocol data, addresses, etc. Serialized table
  - `key`: Table. Only present if needed
    - `m`: `?`
    - `cipher`: Table of supported cipher methods
    - `sign`: Table of supported sign methods
    - `public`: Public key of `hostA`

###### Response (B -> A)
- `header`: Protocol data, addresses, etc. Serialized table
  - `key`: Table. Only present if needed
    - `m`: `!`
    - `cipher`: Table of supported cipher methods
    - `sign`: Table of supported sign methods
    - `public`: Public key of `hostB`

The response can be be actually sent without request just to change the public key. If key from `hostB` on `hostA` is lost or expired, `hostA` will request a new one from `hostB`. If `hostA` lost its private key or just wants to disable encrypting/signing, then it will broadcast to everyone:

- `header`: Protocol data, addresses, etc. Serialized table
  - `key`: Table. Only present if needed
    - `m`: `-`
