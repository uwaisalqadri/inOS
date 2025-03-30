//
//  Notifications.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 8/9/24.
//

import Foundation

struct Notifications {
  static let didTouchScreenPassed = NSNotification.Name("didTouchScreenPassed")
  static let didDeadpixelPassed = NSNotification.Name(rawValue: "didDeadpixelPassed")
  static let didCameraPassed = NSNotification.Name(rawValue: "didCameraPassed")
  static let didCompassPassed = NSNotification.Name(rawValue: "didCompassPassed")
  static let didMultitouchPassed = NSNotification.Name(rawValue: "didMultitouchPassed")
  static let didInputConfirmation = NSNotification.Name(rawValue: "didInputConfirmation")
  static let didBenchmarkEnabled = NSNotification.Name(rawValue: "didBenchmarkEnabled")
}

extension NSNotification.Name {
  func post(with object: Any? = nil) {
    NotificationCenter.default.post(name: self, object: object)
  }
  
  func publisher() -> NotificationCenter.Publisher {
    NotificationCenter.default.publisher(for: self)
  }
}
