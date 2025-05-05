//
//  BenchmarkPresenter+StateAction.swift
//  inOS
//
//  Created by Uwais Alqadri on 27/11/24.
//

import Foundation

extension MetricPresenter {
  struct State {
    var timer: Timer?
    var benchmarks: [Metric] = Metric.allCases
    var cpuUsage: String = "Calculating..."
    var storageSpeed: String = "Calculating..."
    var internetSpeed: String = "Calculating..."
  }
  
  enum Action {
    case onAppear
    case onDisappear
  }
}
