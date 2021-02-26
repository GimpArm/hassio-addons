# SmartFriends MQTT
This add-on creates an MQTT link between Hassio and Smart Friends Box

## How to use this add-on?

Follow these simple steps in order to get it up and running:
### Add the repository
- Open the supervisor:
  ![alt](https://raw.githubusercontent.com/GimpArm/hassio-addons/main/smartfriends-rest-api/images/doc02.png)
- Open the add-on store and go to repositories:
  ![alt](https://raw.githubusercontent.com/GimpArm/hassio-addons/main/smartfriends-rest-api/images/doc03.png)
- Add GimpArm addons repository: https://github.com/GimpArm/hassio-addons
  ![alt](https://raw.githubusercontent.com/GimpArm/hassio-addons/main/smartfriends-rest-api/images/doc04.png)
- The SmartFriends MQTT add-on should now be visible in the store

### Installation and first start
- Install the add-on
- Go to configuration tab and specify the connection settings:
  ```yaml
  {
  "smartFriends": {
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

  ![alt](https://raw.githubusercontent.com/GimpArm/hassio-addons/main/smartfriends-rest-api/images/doc00.jpg)





## Acknowledgments
Special thanks to [LoPablo](https://github.com/LoPablo) and [AirThusiast](https://github.com/airthusiast) for their work on figuring out how the Schellenberg/SmartFriends API functions.