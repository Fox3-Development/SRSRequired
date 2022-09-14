# Enforces SRS Clients in your server.

This script runs as a DCS hook that will enforce SRS connectios fromm your players.

Will currently return the player to spectators if the client does not exist in the SRS clients export when they take off.

**You must have the Client Export enabled in SRS. This produces the `clients-info.json` file that we read from. **

# Configuration

## Enabled
Defaults to true. If changed to false, this hook does nothing.

## SRS url
The message sent to players as they are kicked to spectators will include the SRS url in it.

## Clients File

Set `sCheck.clients_file` to the SR-Server's directory and clients-json location.

**You need to enable the Client Export in SRS.**

Example, if your SRS is installed to `C:\Program Files\SRS`, then set clients_file to `[[C:\Program Files\SRS\clients-info.json]]`

