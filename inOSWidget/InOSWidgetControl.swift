//
//  InOSWidgetControl.swift
//  InOSWidget
//
//  Created by Uwais Alqadri on 30/03/25.
//

import AppIntents
import SwiftUI
import WidgetKit
import ActivityKit

@available(iOS 18.0, *)
struct InOSWidgetControl: ControlWidget {
  static let kind: String = "com.uwaisalqadri.device.functionality.widget"
  
  var body: some ControlWidgetConfiguration {
    AppIntentControlConfiguration(
      kind: Self.kind,
      provider: Provider()
    ) { template in
      ControlWidgetButton(action: OpenAppIntent()) {
        Label("Testing", systemImage: "iphone")
      }
      .tint(.blue)
    }
    .displayName("Benchmark")
    .description("Start Showing Benchmark of Your Phone")
  }
}

@available(iOS 18.0, *)
extension InOSWidgetControl {
  struct Provider: AppIntentControlValueProvider {
    func currentValue(configuration: ControlConfigIntent) async throws -> Value {
      return Value(isToggled: configuration.toggle, name: configuration.name)
    }
    
    func previewValue(configuration: ControlConfigIntent) -> Value {
      return Value(isToggled: false, name: configuration.name)
    }
  }
  
  struct Value {
    var isToggled: Bool
    var name: String
  }
}
