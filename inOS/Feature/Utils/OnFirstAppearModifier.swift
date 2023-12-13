//
//  OnFirstAppearModifier.swift
//  inOS
//
//  Created by Uwais Alqadri on 27/10/24.
//

import Foundation
import SwiftUI

struct OnFirstAppearModifier: ViewModifier {
  var action: (() -> Void)?
  
  @State private var didFirstAppear: Bool = false
  
  func body(content: Content) -> some View {
    content
      .onAppear {
        guard !didFirstAppear else { return }
        didFirstAppear = true
        action?()
      }
  }
}

public extension View {
  func onFirstAppear(perform action: (() -> Void)? = nil) -> some View {
    modifier(OnFirstAppearModifier(action: action))
  }
}
