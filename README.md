# lms-rfidplay 

RFID Play plugin for LMS

This plugin provides a HTTP interface that can be triggered with an RFID card identity and make it possible to map this to a playlist or song that should start to play when the RFID card is used.

# Pre-requisities
LMS 8.2 or later must be installed and configured

# Installation
- Configure the repository in **LMS Settings/Plugins**: https://erland.github.io/lms-rfidplay/repo.xml
- Select to install **RFID Play** plugin

# Configuration
- Goto **LMS Settings/Advanced/RFID Play** and select which player that should be controlled via RFID
- Setup one of the RFID remote controls
  - Arduino based: https://github.com/erland/arduino-lms-rfidremote
  - Raspberry (Python) based: https://github.com/erland/raspberry-lms-rfid
- Swipe an RFID card and goto **LMS Settings/Advanced/RFID Play** and specify which playlist that should be triggered when the new card is swiped in front of the RFID reader.
