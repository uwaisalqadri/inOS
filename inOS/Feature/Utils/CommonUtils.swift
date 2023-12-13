//
//  CommonUtils.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 6/1/24.
//

import Foundation
import SwiftUI

extension CGFloat {
  var int: Int {
    Int(self)
  }
}

extension Float {
  func toPercentage() -> String {
    let clampedValue = max(0.0, min(1.0, self))
    let percentage = Int(clampedValue * 100)
    return "\(percentage)%"
  }
}

extension Double {
  func toPercentage() -> String {
    let percentage = self * 100
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

extension Binding where Value == Bool {
  var not: Binding<Bool> {
    Binding<Bool>(
      get: { !self.wrappedValue },
      set: { self.wrappedValue = !$0 }
    )
  }
}
