//
//  DeviceMetric.swift
//  inOS
//
//  Created by Uwais Alqadri on 01/05/25.
//

import inCore
import DeviceKit

enum DeviceMetric: Equatable, Hashable {
  case phone(String = "")
  case cpu(String)
  case memory(String)
  case storage(String)
  case battery(String)
  case settings(String)
  
  static func == (lhs: DeviceMetric, rhs: DeviceMetric) -> Bool {
    lhs.value == rhs.value
  }
  
  var isSettings: Bool {
    if case let .settings(string) = self {
      return string == "Settings"
    }
    return false
  }
  
  var value: String {
    switch self {
    case let .phone(string):
      return string
    case let .cpu(string):
      return string
    case let .memory(string):
      return string
    case let .storage(string):
      return string
    case let .battery(string):
      return string
    case let .settings(string):
      return string
    }
  }

  var icon: String {
    switch self {
    case .phone:
      switch true {
      case !Device.current.isWithoutHomeButton && !Device.current.isPad:
        return "iphone.homebutton"
      case Device.current.isPad:
        return "ipad"
      default:
        return "iphone"
      }
    case .cpu:
      return "cpu"
    case .memory:
      return "memorychip"
    case .storage:
      return "internaldrive"
    case .battery:
      return "battery.0"
    case .settings:
      return "gear"
    }
  }
}
