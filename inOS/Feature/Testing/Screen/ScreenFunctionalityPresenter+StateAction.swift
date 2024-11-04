//
//  ScreenFunctionalityPresenter+StateAction.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 8/9/24.
//

import Foundation
import SwiftUI

extension ScreenFunctionalityPresenter {
  struct State {
    var boxes: [Color] = Array(repeating: .blue, count: 13 * 19)
    var rows: Int = 19
    var columns: Int = 13
    var isDarkMode: Bool = false
    var touchedColor: Color {
      return isDarkMode ? .black : .white
    }
  }

  enum Action {
    case handleDragGesture(gesture: DragGesture.Value, geometry: GeometryProxy, onUpdateTimer: () -> Void, onResetTimer: () -> Void)
    case handleTap(row: Int, column: Int, onResetTimer: () -> Void)
    case onAppear(darkmode: Bool)
    case success
    case failed
  }
}
