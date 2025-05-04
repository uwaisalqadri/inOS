//
//  BenchmarkPresenter.swift
//  inOS
//
//  Created by Uwais Alqadri on 27/11/24.
//

import Foundation
import SwiftUI
import inCore

@MainActor
final class BenchmarkPresenter: ObservableObject {
  @Published var state: State
  
  init() {
    state = State()
  }
  
  func send(_ action: Action) {
    switch action {
    case .onAppear:
      startMonitoring()
//      if #available(iOS 16.2, *) {
//        LiveActivityManager.startLiveActivity(with: "Connecting...")
//      }
    case .onDisappear:
      state.timer?.invalidate()
//      if #available(iOS 16.2, *) {
//        LiveActivityManager.endLiveActivity(with: "Stopped")
//      }
    }
  }
  
  func getBenchmark(of benchmark: Benchmark) -> Binding<String> {
    switch benchmark {
    case .cpu:
      return Binding(
        get: { self.state.cpuUsage },
        set: { self.state.cpuUsage = $0 }
      )
    case .storage:
      return Binding(
        get: { self.state.storageSpeed },
        set: { self.state.storageSpeed = $0 }
      )
    case .internet:
      return Binding(
        get: { self.state.internetSpeed },
        set: { self.state.internetSpeed = $0 }
      )
    }
  }
}

private extension BenchmarkPresenter {
  func startMonitoring() {
    state.timer = Timer.scheduledTimer(
      withTimeInterval: 1.0,
      repeats: true
    ) { [weak self] _ in
      Task { @MainActor in
        self?.updateBenchmarks()
      }
    }
  }
  
  func updateBenchmarks() {
    state.cpuUsage = Benchmarker.default.cpuLoad()
    state.storageSpeed = Benchmarker.default.storageSpeed()
    Benchmarker.default.internetSpeed { speed in
      DispatchQueue.main.async { [weak self] in
        self?.state.internetSpeed = speed
        if #available(iOS 16.2, *) {
          LiveActivityManager.updateLiveActivity(with: speed)
        }
      }
    }
  }
}
