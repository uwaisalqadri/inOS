//
//  ScreenAssessmentPresenter.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 8/9/24.
//

import Foundation
import SwiftUI

@MainActor
class ScreenAssessmentPresenter: ObservableObject {

  @Published var state = State()

  func send(_ action: Action) {
    switch action {
    case let .onAppear(darkmode):
      state.isDarkMode = darkmode
      
    case let .handleDragGesture(gesture, geometry, onUpdateTimer, onResetTimer):
      handleDragGesture(
        gesture,
        geometry: geometry,
        onUpdateTimer: onUpdateTimer,
        onResetTimer: onResetTimer
      )

    case let .handleTap(row, column, onResetTimer):
      handleTap(
        row: row,
        column: column,
        onResetTimer: onResetTimer
      )

    case .success:
      Notifications.didTouchScreenPassed.post(with: true)

    case .failed:
      Notifications.didTouchScreenPassed.post(with: false)
    }
  }

  func indexFor(row: Int, column: Int) -> Int {
    return row * state.columns + column
  }
}

extension ScreenAssessmentPresenter {
  private func handleTap(row: Int, column: Int, onResetTimer: () -> Void) {
    let index = indexFor(row: row, column: column)
    if state.boxes[index] == .blue {
      state.boxes[index] = state.touchedColor
      onResetTimer()
    }
  }

  private func handleDragGesture(_ gesture: DragGesture.Value, geometry: GeometryProxy, onUpdateTimer: () -> Void, onResetTimer: () -> Void) {
    let cellWidth = geometry.size.width / CGFloat(state.columns)
    let cellHeight = geometry.size.height / CGFloat(state.rows)

    let xPosition = Int(gesture.location.x / cellWidth)
    let yPosition = Int(gesture.location.y / cellHeight)

    let boxIndex = self.indexFor(row: yPosition, column: xPosition)

    if state.boxes[boxIndex] == .blue {
      state.boxes[boxIndex] = state.touchedColor
      onResetTimer()
    } else {
      onUpdateTimer()
    }
  }
}
