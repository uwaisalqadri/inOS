//
//  Assessment+Ext.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 25/3/24.
//

import Foundation

extension Assessment {
  var icon: String {
    switch self {
    case .cpu:
      return "cpu"
    case .storage:
      return "internaldrive"
    case .batteryStatus:
      return "battery.100"
    case .jailbreak:
      return "lock.shield"
    case .silentSwitch:
      return "bell.slash"
    case .volumeUp:
      return "speaker.wave.3.fill"
    case .volumeDown:
      return "speaker.wave.1"
    case .powerButton:
      return "power"
    case .vibration:
      return "waveform.path.ecg"
    case .camera:
      return "camera"
    case .touchscreen:
      return "hand.point.up.left"
    case .cellular:
      return "simcard"
    case .wifi:
      return "wifi"
    case .biometric:
      return "faceid"
    case .accelerometer:
      return "gyroscope"
    case .bluetooth:
      return "dot.radiowaves.right"
    case .gps:
      return "location"
    case .homeButton:
      return "house"
    case .mainSpeaker:
      return "speaker.3.fill"
    case .earSpeaker:
      return "ear"
    case .proximity:
      return "sensor.tag.radiowaves.forward"
    case .deadpixel:
      return "eye.slash"
    case .rotation:
      return "rotate.right"
    case .microphone:
      return "mic.fill"
    case .multitouch:
      return "hand.raised"
    case .barometer:
      return "speedometer"
    case .compass:
      return "location.north.line.fill"
    case .connector:
      return "cable.connector.horizontal"
    case .wirelessCharging:
      return "bolt.circle.fill"
    case .torch:
      return "flashlight.on.fill"
    }
  }
  
  var title: String {
    switch self {
    case .cpu:
      return "CPU"
    case .storage:
      return "Storage"
    case .batteryStatus:
      return "Battery"
    case .jailbreak:
      return "No Jailbreak"
    case .silentSwitch:
      return "Silent Switch"
    case .volumeUp:
      return "Volume Up"
    case .volumeDown:
      return "Volume Down"
    case .powerButton:
      return "Power Button"
    case .vibration:
      return "Vibration"
    case .camera:
      return "Camera"
    case .touchscreen:
      return "Touch Screen"
    case .cellular:
      return "Cellular"
    case .wifi:
      return "Wi-Fi"
    case .biometric:
      return "Biometric"
    case .accelerometer:
      return "Accelerometer"
    case .bluetooth:
      return "Bluetooth"
    case .gps:
      return "GPS"
    case .homeButton:
      return "Home Button"
    case .mainSpeaker:
      return "Main Speaker"
    case .earSpeaker:
      return "Ear Speaker"
    case .proximity:
      return "Proximity"
    case .deadpixel:
      return "Dead Pixel"
    case .rotation:
      return "Rotation"
    case .microphone:
      return "Microphone"
    case .multitouch:
      return "Multi Touch"
    case .barometer:
      return "Barometer"
    case .compass:
      return "Compass"
    case .connector:
      return "Connector"
    case .wirelessCharging:
      return "Wireless Charging"
    case .torch:
      return "Torch"
    }
  }
  
  var value: String {
    switch self {
    case .cpu:
      return "Test the performance of your device's CPU"
    case .storage:
      return "Ensure your device's storage is functioning optimally"
    case .batteryStatus:
      return "Check the health of your device's battery"
    case .jailbreak:
      return "Verify if your device has been jailbroken"
    case .silentSwitch:
      return "Test the functionality of your device's silent switch"
    case .volumeUp:
      return "Ensure the volume up button is responsive"
    case .volumeDown:
      return "Ensure the volume down button is responsive"
    case .powerButton:
      return "Verify the functionality of the power button"
    case .vibration:
      return "Test if the vibration motor is working correctly"
    case .camera:
      return "Ensure the camera functionality is intact"
    case .touchscreen:
      return "Check the responsiveness of the touch screen"
    case .cellular:
      return "Verify the status of your cellular"
    case .wifi:
      return "Test the connectivity of your device to Wi-Fi networks"
    case .biometric:
      return "Ensure the functionality of biometric auth"
    case .accelerometer:
      return "Test the accelerometer sensor of your device"
    case .bluetooth:
      return "Verify the Bluetooth connectivity of your device"
    case .gps:
      return "Check the accuracy of GPS functionality on your device"
    case .homeButton:
      return "Test the responsiveness of the home button"
    case .mainSpeaker:
      return "Ensure the main speaker is producing sound properly"
    case .earSpeaker:
      return "Test the functionality of the ear speaker"
    case .proximity:
      return "Check the functionality of the proximity sensor"
    case .deadpixel:
      return "Detect any dead pixels on your device's screen"
    case .rotation:
      return "Verify if the screen rotation feature is working"
    case .microphone:
      return "Test the microphone's recording capability"
    case .multitouch:
      return "Check the functionality of multi-touch gestures on your device"
    case .barometer:
      return "Test the barometer sensor for pressure measurement"
    case .compass:
      return "Verify the compass accuracy and functionality"
    case .connector:
      return "Check if the physical connector is functioning"
    case .wirelessCharging:
      return "Verify the wireless charging capability"
    case .torch:
      return "Test the device torch"
    }
  }
  
  var finishedMessage: String {
    switch self {
    case .cpu:
      return "CPU is healthy!"
    case .storage:
      return "Storage is safe!"
    case .batteryStatus:
      return "Battery is healthy!"
    case .jailbreak:
      return "No Jailbreak identified!"
    case .silentSwitch:
      return "Silent Switch worked!"
    case .volumeUp:
      return "Volume up button is responsive!"
    case .volumeDown:
      return "Volume down button is responsive!"
    case .powerButton:
      return "Power button is functioning!"
    case .vibration:
      return "Vibration is working!"
    case .camera:
      return "Camera functionality is intact!"
    case .touchscreen:
      return "Touch screen is responsive!"
    case .cellular:
      return "SIM card status verified!"
    case .wifi:
      return "Wi-Fi connectivity tested!"
    case .biometric:
      return "Biometric working properly!"
    case .accelerometer:
      return "Accelerometer sensor tested!"
    case .bluetooth:
      return "Bluetooth connectivity verified!"
    case .gps:
      return "GPS functionality checked!"
    case .homeButton:
      return "Home button is responsive!"
    case .mainSpeaker:
      return "Speaker sound properly!"
    case .earSpeaker:
      return "Ear speaker sound properly!"
    case .proximity:
      return "Proximity sensor worked!"
    case .deadpixel:
      return "No dead pixels detected!"
    case .rotation:
      return "Screen rotation feature verified!"
    case .microphone:
      return "Microphone recording capability tested!"
    case .multitouch:
      return "Multi-touch gestures are responsive!"
    case .barometer:
      return "Barometer sensor is functioning well!"
    case .compass:
      return "Compass is calibrated and accurate!"
    case .connector:
      return "Connector is functional!"
    case .wirelessCharging:
      return "Wireless charging works correctly!"
    default:
      return ""
    }
  }
  
  var testingMessage: String {
    switch self {
    case .silentSwitch:
      return "Turn On/Off the silent switch"
    case .volumeUp:
      return "Press the volume up button"
    case .volumeDown:
      return "Press the volume down button"
    case .powerButton:
      return "Press the power button"
    case .wifi:
      return "Connect to a Wi-Fi network"
    case .cellular:
      return "Turn On Cellular"
    case .bluetooth:
      return "Turn On/Off Bluetooth"
    case .gps:
      return "Check GPS signal"
    case .microphone:
      return "Say 'Hi' to Microphone"
    case .earSpeaker:
      return "Put your phone like a call"
    case .mainSpeaker:
      return "Playing a sound..."
    case .vibration:
      return "Check if the device vibrates"
    case .proximity:
      return "Cover your screen"
    case .rotation:
      return "Rotate to landscape"
    case .connector:
      return "Connect cable to power source"
    case .wirelessCharging:
      return "Please charge with MagSafe"
    default:
      return ""
    }
  }
}
