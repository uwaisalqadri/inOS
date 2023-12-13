//
//  MaintenancePresenter.swift
//  inOS
//
//  Created by Uwais Alqadri on 22/01/25.
//

import Foundation

@MainActor
final class MaintenancePresenter: ObservableObject {
  @Published var state: State
  
  init(_ type: MaintenanceView.PageType) {
    state = State(type: type)
  }
  
  func send(_ action: Action) {
    switch action {
    case .didAppear:
      print("APPEAR")
    }
  }
}

extension MaintenancePresenter {
  struct State {
    let type: MaintenanceView.PageType
  }
  
  enum Action {
    case didAppear
  }
}

