//
//  MonitorViewModel.swift
//  inOS
//
//  Created by Uwais Alqadri on 23/02/25.
//

import Foundation
import SwiftUI

@MainActor
final class MonitorViewModel: ObservableObject {
  @Published var state: State
    
  init() {
    state = State()
  }
  
  func send(_ action: Action) {
    switch action {
    case .onHotspotEnabled:
      state.isHotspotEnabled = true
    case .onConnectDevice:
      state.isLoading = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
        guard let self = self else { return }
        state.isLoading = false
        state.connectedDevice = "Google Pixel 3"
      }
    }
  }
  
  private func isDeviceConnecting() {
    state.isLoading = true
  }
}

extension MonitorViewModel {
  struct State {
    var isLoading: Bool = false
    var isHotspotEnabled: Bool = false
    var connectedDevice: String = ""
  }
  
  enum Action {
    case onConnectDevice
    case onHotspotEnabled
  }
}

