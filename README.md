# OC-P2P

Peer-to-peer network. Address book included. OC-P2P network provides "network layer" according to [OSI model](https://en.wikipedia.org/wiki/OSI_model).

When needed `client` and `node` will be used, otherwise node is the general term to talk about any part of the network.

## Installing

Some info here

## Network

### Packet structure (on receive)

#### Default packet:

- `remoteAddress`: Hardware remote address
- `port`: You can read the official manual for all this =\_=
- `distance`: World distance between nodes
- `hash`: Checking integrity of payload
- `from`: Sender hardware address
- `date`: When was this sent
- `payload`: Encrypted(?) serialized data

#### Ping packet:

Ping packet is smaller than the default packet because it's so common. Everything except `payload` is skipped because it's the same

- `remoteAddress`: Hardware remote address
- `port`: You can read the official manual for all this =\_=
- `distance`: World distance between nodes
- `m`: `?` - ping, `n` - node pong, `c` - client pong, `!` - joined network
- `status`: `online` or `offline` (in answer)
- `network`: Name of the network already in (in pong) or joining to (in `!`)
