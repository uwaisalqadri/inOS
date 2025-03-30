//
//  Intents.swift
//  inOS
//
//  Created by Uwais Alqadri on 30/03/25.
//

import AppIntents
import SwiftUI
import WidgetKit
import ActivityKit

@available(iOS 18.0, *)
struct ControlConfigIntent: ControlConfigurationIntent {
  static let title: LocalizedStringResource = "Benchmark Configuration"
  
  @Parameter(title: "Benchmark Name", default: "Benchmark")
  var name: String
  
  @Parameter(title: "Benchmark Enabled", default: false)
  var toggle: Bool
}

@available(iOS 16.0, *)
struct OpenAppIntent: AppIntent {
  static let title: LocalizedStringResource = "Open inOS App"

  static var openAppWhenRun: Bool = true
  
  func perform() async throws -> some IntentResult {
    return .result()
  }
}

@available(iOS 16.0, *)
struct BenchmarkIntent: SetValueIntent {
  static let title: LocalizedStringResource = "Benchmark Set Value"
  
  @Parameter(title: "Benchmark Name")
  var name: String
  
  @Parameter(title: "Benchmark Enabled")
  var value: Bool
  
  init() {}
  
  init(_ name: String, value: Bool) {
    self.name = name
    self.value = value
  }
  
  func perform() async throws -> some IntentResult {
    Notifications.didBenchmarkEnabled.post()
    return .result()
  }
}
