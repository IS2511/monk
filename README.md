# monk

A versatile tool for network management.
Feel the freedom of not having to think about the delivery of your data.

~~A wise peer-to-peer network. Address book included.
`monk` network provides "network layer (3)", "transport layer (4)" and
parts of "presentation level (6)" such as compression and encryption on level 4!
Next "session layer (5)" is coming soon!
Network levels: [OSI model](https://en.wikipedia.org/wiki/OSI_model).~~

~~When needed `client` and `node` will be used,
otherwise node is the general term to talk about any part of the network.~~

Part of the "Big projects small prospects" 

## Installing

~~TODO: add this to hpm repo!~~ Awaiting hpm rewrite (will it happen?)

Installer (uses github):

```
pastebin run ???
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

- `monk(event: string, options: any)`: Service events. Possible events:
  - `start`: Service started! Hooray!
  - `stop`: Service stopped, dependents may stop themselves
  - `online`: Just connected to a network, `options: string` name of network
  - `offline`: Just lost connection, `options: string` name of network

- `monk_general(header: table, payload: string)`: General messages.           
  Event for messages on port `500` ([Ports](#ports))
  in [General](#general-packet) format.
  The `header` is left untouched, but `payload` is auto-decrypted if possible

## Protocols

| Name   | Version | Description
| ------ | ------: | ---
| mIP    |       1 | Routing, fragmentation
| mICMP  |       1 | Control messages
| mTCP   |       1 | Streams, delivery check
| mMBCP  |       1 | Backwards compatibility
| mLCB   |       1 | Link card for long bridges
| mRWB   |       1 | Link over Internet (capital I)

## Quick FAQ

- Q: Does this all even work?\
  A: I sure hope so
- Q: Is this your first time doing something like this?\
  A: First time doing such a big project
- Q: Does this project scare you?\
  A: A bit
- Q: How did this project start?\
  A: Well, I woke up this morning... Then there was a ~~hole~~ project
- Q: Is this FAQ here just for jokes?
  A: Mostly
- Q: Can you fit more jokes here?
  A: Apparently no

## Network

### Ports

- `500`: Used for any communication with `monk`'s [general](#general-packet) packet format.
- `501`: Reserved for `monk` ping messages. [Ping](#ping-packet) packets only
- `510`: Reserved for `monk` service messages. [Service](#service-packet) packets only

Those are the only strictly reserved ports, `monk` can be used on any port.

### Packet structure

#### General packet:

- `header`: Protocol data, addresses, etc. Serialized table
  - `procotol`: Specified by program using, `monk` is reserved
  - `hash`: Checking integrity of payload (optional)
  - `src`: Source hardware address
  - `dst`: Destination hardware address
  - `time`: When was this sent (optional)
  - `fragment`: Table, if needed. See [fragmentation](#fragmentation) for more info
    - `group`: Some random number for fragment identification
    - `number`: Starts with `1`
  - `encryption`: Table, if needed. See [encryption](#encryption) for more info
    - `cipher`: `AES`, other may be coming later
    - `iv`: If `AES` then `iv` is here.
  - `signature`: Table, if needed. See [signing](#signing) for more info
    - `method`
    - `sign`
- `payload`: Serialized data, may be encrypted

#### Ping packet:

- `m`: `?` - ping, `n` - node pong, `c` - client pong, `!` - joined network
- `status`: `online` or `offline` (in answer)
- `network`: Name of the network already in (in pong) or joining to (in `!`)

#### Service packet:

It looks just like the general packet but can be in any form. These packets are not for users anyway.

### Fragmentation

TODO

### The Book

```Lua
{
  ["34eb7b28-14d3-4767-b326-dd1609ba92e"] = {
    online = true,
    friends = {},
    cipher = {"AES"},
    sign = {"DSA"},
    public = "key data here"
  },
  ["12345678-1234-1234-1234-123456789ab"] = {
    online = true,
    friends = {}
  }
}
```

### Encryption

About creating and exchanging keys: [Key exchange](#key-exchange)

There is 1 encryption method available right now: [AES](#aes)

#### AES

Read the [wiki](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) to understand AES. Our technology is generally the same. Read the [OC wiki](https://ocdoc.cil.li/component:data) to read about this particular implementation. **Tier-2 data card** is required to encrypt or decrypt. To create keys **tier-3 data card** is required

### Signing

About creating and exchanging keys: [Key exchange](#key-exchange)

There is 1 signing method available right now: [DSA](#dsa)

#### DSA

Read the [wiki](https://en.wikipedia.org/wiki/Digital_Signature_Algorithm) to understand DSA. Our technology is generally the same. Read the [OC wiki](https://ocdoc.cil.li/component:data) to read about this particular implementation. **Tier-3 data card** is required to sign, confirm or create keys

### Key exchange

To create a key pair you need a tier-3 data card. To generate a Diffie-Hellman shared key (used for encrypting and decrypting) you need a tier-3 data card, again. BUT, technically after you saved the shared key you can use it with a tier-2 data card, without signing capabilities of course. Anyway, I won't do all this and just say: **You need a tier-3 data card to use AES encryption or DSA signing!** I am however thinking about organizing a UUID list with nodes trusted for shared key generation and/or key pair generation. This seems like a doable idea, but for now the main thing isn't finished yet so it's a low priority.

Keys are stored in the address book among with 2 tables of supported ciphers and signing methods. More info in [The Book](#the-book)

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
