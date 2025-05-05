//
//  Metric.swift
//  inOS
//
//  Created by Uwais Alqadri on 20/01/25.
//

import Foundation

enum Metric: CaseIterable {
  case cpu
  case storage
  case internet
  
  var icon: String {
    switch self {
    case .cpu:
      return "cpu"
    case .storage:
      return "internaldrive"
    case .internet:
      return "wifi"
    }
  }
  
  var title: String {
    switch self {
    case .cpu:
      return "CPU Usage"
    case .storage:
      return "Storage Speed (Read/Write)"
    case .internet:
      return "Internet Speed"
    }
  }
}
