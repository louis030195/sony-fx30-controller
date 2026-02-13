# sony-fx30-controller

native macOS & iOS app to remotely control the Sony FX30 cinema camera over Wi-Fi using the PTP/IP protocol. no Sony SDK required — pure Swift implementation reverse-engineered from the protocol.

![main ui](screenshot-main.png)

![connection](screenshot-connect.png)

## features

- **live view** — real-time MJPEG viewfinder with pinch-to-zoom
- **full camera control** — ISO, shutter speed, aperture, exposure compensation, white balance, focus mode
- **record** — start/stop recording with live timecode
- **zoom** — continuous zoom in/out (W/T) with press-and-hold
- **SSDP discovery** — auto-detect cameras on the network
- **histogram** — real-time luminance histogram overlay
- **grid overlay** — rule of thirds with center cross
- **info overlay** — live exposure parameters on the viewfinder
- **exposure meter** — visual EV compensation gauge
- **cross-platform** — runs on macOS 14+ and iOS 17+ from a single codebase

## design

pure black & white. sharp corners. 1px borders. monospace typography. geometric primitives. no shadows, no gradients, no color. 150ms linear animations. inspired by the [screenpipe](https://screenpi.pe) brand system.

## protocol

communicates directly with the camera via **PTP/IP** (Picture Transfer Protocol over IP) on port `15740`. the implementation handles:

- dual TCP socket architecture (command + event channels)
- full PTP/IP handshake (INIT_CMD_REQ → INIT_CMD_ACK → INIT_EVENT_REQ → INIT_EVENT_ACK)
- Sony SDIO extension setup for proprietary property access
- property get/set for all Sony-specific device properties
- live view streaming via `GetObject(0xFFFFC002)` returning JPEG frames
- keepalive heartbeat (15s interval)
- event listener for camera-initiated state changes

### sony property codes

| property | code | description |
|---|---|---|
| ISO | `0xD21E` | ISO sensitivity |
| shutter speed | `0xD20D` | shutter speed value |
| aperture | `0x5007` | f-number |
| white balance | `0x5005` | white balance mode |
| focus mode | `0x500A` | AF-S, AF-C, DMF, MF |
| exposure bias | `0x5010` | EV compensation |
| recording | `0xD2C8` | start/stop movie recording |
| battery | `0xD218` | battery level percentage |
| zoom | `0xD2DD` | zoom direction and speed |
| storage | `0xD222` | remaining storage |

## MCP server (AI camera control)

control your camera with natural language through Claude. say "set up for a cinematic interview" and Claude configures ISO, shutter, aperture, WB — and can see the live viewfinder to check exposure.

### install

download [`sony-fx30.mcpb`](https://github.com/louis030195/sony-fx30-controller/releases) and open it. Claude Desktop will prompt you to install.

or build from source:

```bash
cd mcp
npm install
npm run build
npx @anthropic-ai/mcpb pack
open sony-fx30.mcpb
```

### tools

| tool | description |
|------|-------------|
| `connect-camera` | connect to camera via IP (default 192.168.122.1) |
| `get-camera-settings` | get all current settings |
| `get-live-frame` | capture viewfinder image as JPEG (Claude can see it) |
| `set-iso` | set ISO (Auto, 100–12800) |
| `set-shutter-speed` | set shutter speed (1/24–1/1000) |
| `set-aperture` | set f-number (f/1.4–f/22) |
| `set-white-balance` | set WB (Auto, Daylight, Tungsten, etc.) |
| `set-exposure-comp` | set EV compensation (-3.0 to +3.0) |
| `set-focus-mode` | set AF mode (AF-S, AF-C, MF, DMF) |
| `start-recording` | start video recording |
| `stop-recording` | stop video recording |
| `start-zoom` / `stop-zoom` | zoom in/out (power zoom lenses) |

### how it works

```
Sony FX30 (Wi-Fi, port 15740)
    ↑ PTP/IP (raw TCP via Node.js net.Socket)
sony-fx30-mcp (TypeScript MCP server)
    ↑ JSON-RPC over stdio
Claude Desktop / Claude Code
```

no Swift app needed. the MCP server speaks PTP/IP directly to the camera over TCP.

## native app

### setup

1. enable Wi-Fi on your FX30
2. connect your Mac/iPhone to the camera's Wi-Fi network
3. enable "Remote Shoot Function" on the camera (Menu → Network → Remote Shoot)
4. camera IP is typically `192.168.122.1`

### build

```bash
# macOS
swift build
.build/debug/SonyFX30Controller

# iOS — open in Xcode
open Package.swift
# select your iPhone as the run destination
```

### requirements

- macOS 14+ or iOS 17+
- Xcode 15+ (for iOS builds)
- Sony FX30 with Wi-Fi enabled

## compatibility

built for the Sony FX30 but should work with other Sony cameras that support PTP/IP remote control, including:

- FX3, FX6, FX9
- A7 series (A7IV, A7SIII, A7RV)
- A9 series
- ZV-E1, ZV-E10

## architecture

```
mcp/                              ← MCP server (TypeScript)
├── src/
│   ├── index.ts                  — MCP server entry point (stdio transport)
│   ├── ptp-protocol.ts           — protocol constants, packet builders
│   ├── ptp-client.ts             — TCP client, handshake, send/receive
│   └── camera.ts                 — high-level camera API
├── manifest.json                 — MCP metadata for .mcpb
├── package.json
└── tsconfig.json

Sources/SonyFX30Controller/
├── Camera/
│   ├── PTPProtocol.swift      — PTP/IP constants, packet types, Sony property codes
│   ├── PTPIPClient.swift      — actor-based TCP client using Network.framework
│   ├── SSDPDiscovery.swift    — multicast camera discovery
│   ├── CameraManager.swift    — ObservableObject bridging protocol to UI
│   └── PlatformImage.swift    — cross-platform NSImage/UIImage abstraction
├── Theme/
│   └── AppTheme.swift         — B&W design system, shared components
├── Views/
│   ├── LiveViewPanel.swift    — viewfinder, histogram, grid, info overlays
│   ├── ControlPanel.swift     — record, EV, zoom controls
│   ├── StatusBar.swift        — connection, recording, battery, FPS
│   ├── SettingsPanelLeft.swift — ISO, shutter, aperture, exposure meter
│   ├── SettingsPanelRight.swift — focus, white balance, display overlays
│   └── ConnectionView.swift   — discovery + manual IP connection
├── ContentView.swift          — adaptive layout (wide/compact)
└── SonyFX30App.swift          — app entry point
```

## license

MIT

---

built with [claude code](https://claude.ai/code)
