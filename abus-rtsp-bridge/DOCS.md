# ABUS RTSP Bridge

> ⚠️ **Only one connection at a time.** These cameras only allow a single active viewing
> session. While this add-on is running and connected, you will **not** be able to view or
> control the camera from the official phone app - and if you open the app (or anything
> else) while this add-on is connected, one of the two will lose its connection. Only use
> one or the other at a time.

Restreams ABUS/JSW-family P2P cameras (the ones normally only viewable through their own
phone app) as standard RTSP streams, with PTZ, ONVIF, and health-check support - so any
NVR/media server (Frigate, Synology Surveillance Station, Blue Iris, VLC, etc.) can use them
like any other IP camera.

Source code: https://github.com/gimparm/abus-rtsp-bridge

## Before you start

You need the camera's **DID** and **view password** (the same credentials the phone app
uses). The DID looks like `ABCD-012345-EFGHI` and is shown in the app's device settings.
If you can't find it, turn on push notifications for the camera in the app - the notification
your phone receives contains the DID.

If you plan to use your NVR's own motion/object detection (e.g. Frigate), turn off the
camera's built-in detection features in the phone app first - running both at once just
wastes the camera's own limited resources on redundant detection work, and can make the
camera itself feel slower/less responsive, with no benefit since the NVR is already
analyzing the same stream.

## Network access

This add-on runs on the host network (`host_network: true`) so it can send/receive the UDP
broadcast packets needed to discover the cameras on your LAN. If a camera can't be found on
the LAN within its `timeout` seconds, it automatically falls back to a cloud/P2P rendezvous
protocol instead (the same one the phone app uses when you're away from home) - this requires
the camera's `did` to be set, since the cloud lookup is keyed by it.

## Configuration

Add every camera to the `cameras` list. The other sections are shared by all cameras. Every
option is optional unless noted - anything left blank keeps a sensible default.

### `cameras`
| Option | Description |
|---|---|
| `name` | **Required.** Unique name (letters, digits, `_`, `-`), used in logs and as the RTSP path. |
| `password` | **Required.** Camera view password / security code. |
| `did` / `target_ip` | At least one is **required** when you have several cameras, so discovery picks the right one. `did` is also **required** for the cloud/P2P fallback; `target_ip` skips broadcast discovery and probes that LAN address directly. |
| `bind_ip` | Local IPv4 to bind the discovery socket to. Leave blank to auto-select. |
| `timeout` | Discovery timeout in seconds before falling back to the cloud/P2P path. Default `5.0`. |
| `resolution`, `disable_audio`, `disable_talkback` | Per-camera overrides of the `rtsp` defaults below. |
| `onvif_port` | Enables ONVIF for this camera on this port. ONVIF is **off** for a camera unless this is set; each port must be unique. |
| `onvif_ws_discovery`, `onvif_ptz_step` | Optional ONVIF WS-Discovery toggle and PTZ step (1-16) for this camera; only used with `onvif_port`. |

Each camera runs in its own worker, so one failing never affects the others.

### `rtsp`
| Option | Description |
|---|---|
| `bind_ip` | Address the RTSP server listens on. Default `0.0.0.0` (all interfaces). |
| `port` | RTSP port shared by all cameras. Default `8554`. Each camera is served at `rtsp://<host>:<port>/<camera name>`. |
| `resolution` | Video quality: `0`=by camera setting, `1`=Full HD, `2`=HD, `3`=SD, `4`=automatic. |
| `disable_audio` | Disable the second (audio) RTP stream. Audio is included by default. |
| `disable_talkback` | Disable two-way audio (see [Two-way audio](#two-way-audio)). |

### `ptz`
| Option | Description |
|---|---|
| `enabled` | Enable the PTZ/snapshot/health REST server on port 8080. |
| `http_host` / `http_port` | Bind address/port for that REST server. |

### `auth`
| Option | Description |
|---|---|
| `username` / `password` | If both are set, require HTTP/RTSP Basic auth on the RTSP streams, ONVIF services, and PTZ REST server. Leave both blank to disable auth. |

### `diagnostics`
| Option | Description |
|---|---|
| `debug` | Verbose per-packet/per-frame diagnostic logging. |
| `dump_raw` | Diagnostic: write raw post-auth frames to this path instead of streaming. Leave blank. |
| `skip_video_start` / `skip_audio_start` | Diagnostic test flags - leave off. |

The REST API is shared by all cameras: it stays on port `8080` with the camera name as the first
path segment, e.g. `http://<host>:8080/garage/ptz/left` or `http://<host>:8080/garage/snapshot`;
`/cameras` lists the names and `/health` reports the worst status across all cameras (used by
the watchdog).

## Two-way audio

The RTSP stream supports the ONVIF audio backchannel, so a client that requests it can talk
through the camera's speaker. In Frigate/go2rtc (and Home Assistant's camera two-way talk), if
the RTSP source doesn't request the backchannel by default, add `#backchannel=1` to its URL,
e.g. `rtsp://<host>:8554/<camera name>#backchannel=1`.
The client must send G.711 A-law (`PCMA/8000`). While the speaker is open the camera's own audio
is muted in the stream to avoid feedback, and a connected backchannel client roughly doubles the
stream's CPU use. Set `rtsp.disable_talkback` (or the per-camera `disable_talkback`) to turn it off.

## Endpoints

- RTSP streams: `rtsp://<host>:8554/<camera name>`
- PTZ/snapshot/health REST API: `http://<host>:8080/<camera name>/...` (`/ptz/<direction>`,
  `/snapshot`, `/siren/<on|off>`, `/light/<on|off>`, and `POST /play?source=<mp3 url>` to play
  a sound on the camera's speaker - see the main project's README for the full list), plus
  `http://<host>:8080/cameras` and `http://<host>:8080/health`
- ONVIF (only for cameras with `onvif_port`): `http://<host>:<onvif_port>/onvif/device_service`

## Frigate example

Since this add-on uses `host_network`, `<host>` below is just the IP/hostname of the Home
Assistant host it's running on - Frigate reaches it exactly like any other camera on your
network. For a camera named `front_door` with `onvif_port: 8000`:

```yaml
cameras:
  front_door:
    detect:
      fps: 5
    ffmpeg:
      input_args: preset-rtsp-generic
      inputs:
        - path: rtsp://<username>:<password>@<host>:8554/front_door
          roles: [record, detect]
    onvif:
      host: <host>
      port: 8000
      user: <username>
      password: <password>
```

`<username>`/`<password>` here are only needed if you set `auth.username`/`auth.password` in
this add-on's own configuration above - if you left auth disabled, drop `user:`/`password:`
from the `onvif:` block and the `<username>:<password>@` part of the RTSP `path:` entirely.

## Home Assistant Generic Camera integration

If you just want to view the camera in the Home Assistant frontend without a full NVR, use
the built-in [Generic Camera integration](https://www.home-assistant.io/integrations/generic/)
(**Settings > Devices & services > Add Integration > Generic Camera**):

- **Stream Source**: `rtsp://<username>:<password>@<host>:8554/<camera name>`
- **Still Image URL** (optional, for a faster-loading thumbnail/snapshot): `http://<host>:8080/<camera name>/snapshot`
- **RTSP transport protocol**: set this to `tcp` - this add-on only serves RTSP over TCP
  (interleaved), not UDP, so the default transport setting will fail to connect.

As with the Frigate example above, the `<username>:<password>@` part is only needed if you
set `auth.username`/`auth.password` on this add-on; otherwise just use `<host>` in the URL
directly, or fill in the integration's own separate Username/Password fields instead.

## Troubleshooting

- **Add-on starts but never finds a camera**: confirm that camera's `did`/`password` are
  correct, and that Home Assistant itself is on the same LAN/VLAN as the camera (this add-on
  uses `host_network`, so it shares Home Assistant's own network visibility).
- **Works, then randomly disconnects**: check whether the official app or another viewer is
  connected at the same time - see the single-session note above.
- **Health check**: `GET http://<host>:8080/health` reports `starting`/`ok`/`stalled`/
  `reconnecting`/`unhealthy` - this add-on's watchdog uses the same endpoint.
