# mIP - Minecraft Internet Protocol

## About
This library is used by mTCP and other network protocols for packet routing.

You probably won't notice this library and probably shouldn't use it
unless you are developing new network protocols and/or technology.

## Header structure
Low-level `modem.send()` call looks something like this:\
`modem.send(address, port, header: string, ...)`\
The 2 interesting things are:
- `header`: structured string, used for routing (duh)
- `...`: more headers/data, like mTCP

Contents of data are not relevant to us now, we'll focus on `header`.

Everything field is aligned to bytes for simpler string operations
(eg. `string.byte(header:sub(offset, offset+size))`).
Every number with multiple bytes/bits is in little-endian (if I understand correctly).

| Name       | Size | Description
| ---------- | ---- | ---
| `version`  |   1  | Protocol version, current is `mIPv1` => `1`
| `flowID`   |   3  | Unique ID, used to identify flows. See [Packet flow](#packet-flow)
| `packetID` |   3  | Unique ID, used with `flowID` for caching and loop prevention
| `prevID`   |   3  | `packetID` of previous packet in flow. See [Packet flow](#packet-flow)
| `proto`    |   1  | Protocol of next item in `modem.send()`. See [Protocols](#protocols)
| `hopLimit` |   1  | -1 every hop, 0 => packet dies (unless on `dst`)
| `flags`    |   1  | Bitmask, `END`, `DNF`, ???
| `src`      |  36  | Source modem address
| `dst`      |  36  | Destination modem address
| `options`  | 1-3  | ???????????

Total size: 1 + 3\*3 + 3 + 36\*2 + 2 (modem string overhead) = 87

### Flags
- `END`: This is the end of the flow. See [Packet flow](#packet-flow)
- `DNF`: Do Not Fragment, ignore `flowID`. See [Packet flow](#packet-flow)
- ``: ???

## Quick FAQ

- Q: Does mIP guarantee delivery?\
  A: Nope, mTCP does (I hope)
- Q: \
  A: 

## Going deeper

### Packet flow
Concept is somewhat similar to [IPv6's Flow Label](https://en.wikipedia.org/wiki/IPv6_packet#Fixed_header)

A high-entropy identifier of a flow of packets between a source and destination.
A flow is group of packets, e.g., a TCP session or a media stream (lol).

Packet flow is also responsible for package fragmentation.
If `flowID` is `0` there is no flow.
If `flowPrev` is `0` this is the beginning of a flow.
End of the flow is indicated by the `END` [flag](#flags).

The 3 bytes for `packetID` and `flowID` are generated like this:
```lua
local function genID()
  local x = math.random(1, 16777216) -- (2^8)^3
  return string.char(x%255, math.floor((x/255)%255), math.floor((x/65025)%255))
end
```
The lua random generator seed is distinct for every computer (as far as I know).
Make an issue if you know a **better method**!

### Protocols

Current list of protocols:

| `proto` | Name        | Description
| ------: | ----------- | ---
|       0 | Unknown     | Why though?
|       1 | mICMP       | Forming OC Internet since 2020
|       2 | mTCP        | 
|       3 | mUDP        | 
|       4 | mMCP        | WIP Wrap around vanilla OC messages
|       5 | mVPN        | WIP? "Ha-ha, I'm someone else" (c) User
|       6 | mLCB        | WIP To infinity and beyond!
|       7 | mRWB        | WIP Connect multiple nets via internet
|   8-252 | Unassigned  | New protocols coming soon! (no)
| 253-254 | Testing     | Will be dropped by default
|     255 | Reserved    | Will be dropped by default

Make an issue if you want your protocol here.

### Path discovery

]]--

-- TODO: Read ICMPv6, NDP, ARP, IPv4, IPv6?, TCP, UDP

-- TODO: Make route discovery great again! Create mNDP?

-- TODO: Route Discovery packet or something?
--[[
- Cache local neighbours?
- Send Route Discovery packet or something (A searches D)
- Receive answer with route? A -> B -> C -> D

| - | dst A | dst B | dst C | dst D |
| --- | --- | ----- | ----- | --- 
| A |   -   |   B*  |   B   |   B   |
| B |   A*  |   -   |   C*  |   C   |
| C |   B   |   B*  |   -   |   D*  |
| D |   C   |   C   |   C*  |   -   |
\* Can be cached? They are neighbours, maybe instantly

No neighbours:

| - | dst A | dst B | dst C | dst D |
| --- | --- | ----- | ----- | ---
| A |   -   |       |   B   |   B   |
| B |       |   -   |       |   C   |
| C |   B   |       |   -   |       |
| D |   C   |   C   |       |   -   |

]]--

-- TODO: Return header hash/"hash"? To confirm identity

-- TODO: You are a client? Just broadcast ping and connect with nearest pong
-- Server pongs every request from client? Must(?) if on move (tablet or etc.)
-- And then communicate like there is no such thing as distance ;)

### The Book

```Lua
book = {
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

-- TODO: Call modem.send() last in tick, form send queue?

-- TODO: Make wrappers for protocols, like protoWrapper(data_and_things)
-- Make a universal proto wrapper?

