//
//  Assessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 20/3/24.
//

import Foundation

public enum Assessment: String, CaseIterable, Codable {
  case cpu
  case storage
  case batteryStatus
  case jailbreak
  case silentSwitch
  case volumeUp
  case volumeDown
  case powerButton
  case vibration
  case camera
  case torch
  case touchscreen
  case multitouch
  case cellular
  case wifi
  case biometric
  case accelerometer
  case barometer
  case bluetooth
  case gps
  case compass
  case homeButton
  case mainSpeaker
  case earSpeaker
  case proximity
  case deadpixel
  case rotation
  case microphone
  case connector
  case wirelessCharging
  
  public static var allCases: [Assessment] {
    let allCases: [Assessment] = [
      .cpu,
      .storage,
      .batteryStatus,
      .jailbreak,
      .silentSwitch,
      .volumeUp,
      .volumeDown,
      .powerButton,
      .vibration,
      .camera,
      .torch,
      .touchscreen,
      .multitouch,
      .cellular,
      .wifi,
      .biometric,
      .accelerometer,
//      .barometer,
      .bluetooth,
      .gps,
      .compass,
      //.homeButton,
      .mainSpeaker,
      .earSpeaker,
      .proximity,
      .deadpixel,
      .rotation,
      .microphone,
      .connector,
      .wirelessCharging
    ]
    
    return allCases
  }
}
