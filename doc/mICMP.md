# mICMP - Minecraft Internet Control Message Protocol

## Packet structure
Low-level `modem.send` call looks something like this:\
`modem.send(address, port, header: string, data: string)`\
The 2 interesting things are:
- `header`: structured string, used for routing (duh)
- `data`: probably serialized table, contains something like mTCP

