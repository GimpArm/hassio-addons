## Version 3.10
- In preparation for HomeAssistant 2024.2.0, remove entity name from MQTT registration

## Version 3.9

- Change client to use event based messaging
- Upgrade MQTT client

## Version 3.8

- Handle multiple messages in a single response
- Ignore ResponseCode = 5 messages, these are client upgrade messages
- Add more possible state values for switchingValues
- Upgrade the default API and Client versions

### Version 3.7

- Fixed default cover template
- Added switch example to default template

### Version 3.6

- Added ability to parse multiple json objects from Smartfriends bridge.

### Version 3.5

- Bug fix, sometimes JsonToken.Integer can be a Long.

### Version 3.4

- Bug fix, sending wrong formatted current state values.
- Feature, added ability to have complex data types for template values.

### Version 3.3

Small fix. SmarFriends change, new registrations of devices don't match on deviceTypClient any more.

### Version 3.2

Workaround for when devices are reported as having a MasterDeviceId = 0 from the SmartFriends box.
Fixed issue not listing master devices when first sub device has no room but others do.

### Version 3.1

Fixed issues with MQTT discovery.
Fixed default cover template to match changes to HASSIO.

### Version 3.0

Initial release of both REST API and MQTT client in one service.