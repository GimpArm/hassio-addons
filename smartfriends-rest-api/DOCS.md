# SmartFriends REST API
This add-on creates a link between Hassio and Smart Friends Box with a simple REST API.

## How to use this add-on?

Follow these simple steps in order to get it up and running:
### Add the repository
- Open the supervisor:
  ![alt](https://raw.githubusercontent.com/GimpArm/hassio-addons/main/images/doc02.png)
- Open the add-on store and go to repositories:
  ![alt](https://raw.githubusercontent.com/GimpArm/hassio-addons/main/images/doc03.png)
- Add GimpArm addons repository: https://github.com/gimparm/hassio-addons
  ![alt](https://raw.githubusercontent.com/GimpArm/hassio-addons/main/images/doc04.png)
- The SmartFriends REST API add-on should now be visible in the store

### Installation and first start
- Install the add-on
- Go to configuration tab and specify the connection settings:
  ```yaml
  {
  "SmartFriends": {
    "Username": "", #---------------> Username (case sensitive)
    "Password": "", #---------------> Password
    "Host": "", #-------------------> IP of your Smart Friends Box
    "Port": 4300, #-----------------> Port of the box, generally 4300/tcp
    "CSymbol": "D19033", #----------> Extra param 1
    "CSymbolAddon": "i", #----------> Extra param 2
    "ShcVersion": "2.21.1", #-------> Extra param 3
    "ShApiVersion":  "2.20" #-------> Extra param 4
  }
  ```
  **Extra API parameters**:
  In order to find these values, simply open the Smart Friends App and go to the information page as illustrated:

  ![alt](https://raw.githubusercontent.com/GimpArm/hassio-addons/main/images/doc00.jpg)

### Collect devices ID's
Device ID's **are important**, they will be used to interact with the device itself.

This .Net version makes this process easier. In a browser go to:
```http://127.0.0.1:5001/list```

And you will see an output like this:

```json
[
  {
    "id": 13103,
    "name": "Blinds Dining",
    "room": "Dining Room",
    "controlValue": 0,
    "analogValue": 100,
    "commands": [
      "Stop",
      "Up",
      "Down"
    ],
    "min": 0,
    "max": 100,
    "stepSize": 1
  },
  {
    "id": 1323,
    "name": "Light",
    "room": "LivingRoom",
    "controlValue": 1,
    "commands": [
      "On",
      "Toggle",
      "Off"
    ]
  },
  ...
  ...
]
```

### Using REST API

The service exposes a simple REST API, which can be called to control your devices.

#### Examples on how to use the REST API
- Open Shutter:

  ```http://127.0.0.1:5001/set/13103/open```
- Close shutter:

  ```http://127.0.0.1:5001/set/13103/close```
- Stop shutter:

  ```http://127.0.0.1:5001/set/13103/stop```
- Go to position 50%:

  ```http://127.0.0.1:5001/set/13103/50```
- Get current shutter position:

  ```http://127.0.0.1:5001/get/13103```

Other devices can be controlled by using a command or setting a numeric value. I have only tested Zigbee switched but others should also work.

- Turn light on:

```http://127.0.0.1:5001/set/on```

As it can be seen, actions are send using the device ID.

## Use case: Home Assistant covers

This is a simple use case: Controlling roller shutters (alias covers or rolling shutters...)

![covers](https://github.com/GimpArm/hassio-addons/main/smartfriends-rest-api/images/doc01.png)

The example shown above needs the creation of 3 elements:
- shell commands to interract with the REST API (locally)
- sensors to get the current position of the covers
- the covers themselves declared as templates
*note: Schellenberg Rollodrive sets and reports position opposite of how Home Assistant covers work. An easy solution is to always substract the value from 100*

```yaml
shell_command:
    shutter_up:        "curl http://127.0.0.1:5001/set/{{ device_id }}/up"
    shutter_down:      "curl http://127.0.0.1:5001/set/{{ device_id }}/down"
    shutter_position:  "curl http://127.0.0.1:5001/set/{{ device_id }}/{{ 100 - position }}"
    shutter_stop:      "curl http://127.0.0.1:5001/set/{{ device_id }}/stop"
    switch_on:         "curl http://127.0.0.1:5001/set/{{ device_id }}/on"
    switch_off:        "curl http://127.0.0.1:5001/set/{{ device_id }}/off"
    switch_toggle:        "curl http://127.0.0.1:5001/set/{{ device_id }}/toggle"

sensor:
  - platform: command_line
    name: shutter_position_office
    command: "curl http://192.168.1.10:5001/get/10433"
    unit_of_measurement: "%"
    scan_interval: 5
    value_template: '{{ 100 - value_json.analogValue }}'

cover:
  - platform: template
    covers:
      shutter_office:
        friendly_name: "Shutter - Office"
        device_class: shutter
        position_template: "{{ states('sensor.shutter_position_office') }}"
        open_cover:
          service: shell_command.shutter_up
          data:
            device_id: 10433
        close_cover:
          service: shell_command.shutter_down
          data:
            device_id: 10433
        stop_cover:
          service: shell_command.shutter_stop
          data:
            device_id: 10433
        set_cover_position:
          service: shell_command.shutter_position
          data_template:
            device_id: 10433
            position: "{{ position }}"


binary_sensor:
  - platform: command_line
    name: switch_officelight
    device_class: light
    command: "curl http://192.168.1.10:5001/get/14106"
    scan_interval: 5
    value_template: '{{ value_json.controlValue }}'
    payload_on: 1
    payload_off: 0

switch:
  - platform: template
    switches:
      officelight:
        friendly_name: "Office Light"
        icon_template: "mdi:lightbulb"
        value_template: '{{ is_state("binary_sensor.switch_officelight", "on") }}'
        turn_on:
          service: shell_command.switch_on
          data:
            device_id: 14106
        turn_off:
          service: shell_command.switch_off
          data:
            device_id: 14106
```


## Acknowledgments
Special thanks to [LoPablo](https://github.com/LoPablo) and [AirThusiast](https://github.com/airthusiast) for their work on figuring out how the Schellenberg/SmartFriends API functions.