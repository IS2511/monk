# monk

A wise peer-to-peer network. Address book included. `monk` network provides "network layer (3)", "transport layer (4)" and parts of "presentation level (6)" such as compression and encryption on level 4! Next "session layer (5)" is coming soon! Network levels: [OSI model](https://en.wikipedia.org/wiki/OSI_model).

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
  enable = true, -- Global service trigger
  scan = {
    enable = true,
    delay = 60, -- in seconds
    radius = 400, -- in blocks
    lowEnergyPercent = 0 -- Turn off scanning if lower than this
  },
  net = {
    autoconnect = {
      enable = true,
      trusted = {} -- Trust no one >:)
    },
    friends = {
      saveCoords = true
    },
    packet = {
      mtu = 4096
    }
    book = {
      enable = true, -- If false every message will be sent to all friends
      volumeSpreadMethod = "even" -- even/priority (sorted from top to bottom)
      volumes = { -- These all actually store 1 book just divided
        {
          location = "/var/lib/monk/book" -- folder
          maxSize = "1M" -- [b]ytes, [k]ilobytes, [M]egabytes, inf - infinity
          -- divide = { -- Overrides global book.divide
          --   enable = true,
          --   method = "index (why though?)"
          -- },
          -- compress = { -- Overrides global book.compress
          --   enable = true,
          --   method = "something else"
          -- }
        }
      },
      clean = { -- Offline for long -> expire -> remove
        enable = true,
        expireOn = "2d" -- supports seconds, minutes, hours, days (24h)
      },
      update = { -- Book too old -> request a new one
        enable = true,
        expireOn = "1h" -- supports seconds, minutes, hours, days (24h)
      },
      divide = { -- [RAM] Reducing RAM consumption if volume too big
        enable = true,
        method = "folder" -- index/folder, folder is faster
      },
      compress = { -- [HDD] May slow down volume access
        enable = true,
        method = "deflate" -- Only "deflate" available now (data card)
      }
    }
  },
  event = {
    generalMessages = true
  }
}
```

If you are not sure what an option means, here is some more info:

- `enable`: If `false` all attempts to start the service will be ignored
- `scan`: All about auto scanning for ~nodes~ new friends!
  - `enable`: If `true` periodic ping broadcasts are made
  - `delay`: Delay between ping broadcast in seconds, rounded to seconds
  - `radius`: Broadcast radius in blocks
  - `lowEnergyPercent`: Disable scans if energy is lower than this, `0` is off
- `net`: Network settings
  - `autoconnect`: Auto connecting to trusted networks
    - `enable`: If `true` node autoconnects to trusted networks
    - `trusted`: List of trusted networks, `[network]=true` format
  - `book`: All about the address book and its storage policy
    - `clean`: Cleaning "dead" nodes from the book
      - `enable`: If `true` node cleans expired contacts
      - `expireOn`: Time from last online (ping), in real time
    - `update`: Requesting new book if too long without update
      - `enable`: If `true` node requests a new book
      - `expireOn`: Time from the last book update, in real time
- `event.GeneralMessages`: If `true` general messages will be auto-processed

A few more comments on the config:

- You *can* technically store the address book in a one large file if you set the `net.book.divide.enable` to `false` but it's strongly recommended **not** to as it will increase the RAM usage significantly. It will be very spiky and not very good.
-

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
  - `procotol`: Specified by program using, `monk` is reserved
  - `hash`: Checking integrity of payload (optional)
  - `src`: Source hardware address
  - `dst`: Destination hardware address
  - `time`: When was this sent (optional)
  - `fragment`: Only present if needed
    - `group`: Some random number for fragment identification
    - `number`: Starts with 1
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

It looks just like the general packet but can be in any form. These packets are not for users anyway.

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

You generally need a **tier-3 data card** at both ends! No data card required for transfer nodes though. More info in [Key exchange](#key-exchange)

There is 1 encryption method available right now: [AES](#aes)

#### AES


More info in [Key exchange](#key-exchange)

### Signing

You generally need a **tier-3 data card** at both ends! No data card required for transfer nodes though. Yes, same as encrypting. More info in [Key exchange](#key-exchange)

There is 1 signing method available right now: [DSA](#dsa)

#### DSA



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
