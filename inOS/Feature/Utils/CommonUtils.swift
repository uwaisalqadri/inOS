//
//  CommonUtils.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 6/1/24.
//

import Foundation

extension Float {
  func toPercentage() -> String {
    let clampedValue = max(0.0, min(1.0, self))
    let percentage = Int(clampedValue * 100)
    return "\(percentage)%"
  }
}

extension Double {
  func toPercentage() -> String {
    let clampedValue = max(0.0, min(1.0, self))
    let percentage = Int(clampedValue * 100)
    return "\(percentage)%"
  }
}

extension Bool {
  func toYesNo() -> String {
    self ? "Yes" : "No"
  }
  
  func toOnOff() -> String {
    self ? "On" : "Off"
  }
}

extension Int64 {
  func toMBFormat() -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = .useMB
    formatter.countStyle = .decimal
    formatter.includesUnit = true
    return formatter.string(fromByteCount: self)
  }
  
  func toGBFormat() -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = .useGB
    formatter.countStyle = .decimal
    formatter.includesUnit = false
    
    let formattedString = formatter.string(fromByteCount: self)
    
    if let doubleValue = Double(formattedString.replacingOccurrences(of: ",", with: ".")) {
      return "\(String(format: "%.0f", ceil(doubleValue))) GB"
    } else {
      return "\(formattedString) GB"
    }
  }
}
