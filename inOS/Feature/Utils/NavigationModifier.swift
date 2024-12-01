//
//  NavigationModifier.swift
//  inOS
//
//  Created by Aleph-WQ05D on 29/11/24.
//

import SwiftUI

struct NavigationModifier<Destination: View>: ViewModifier {
  @Binding var isPresented: Bool
  @ViewBuilder let destination: Destination

  func body(content: Content) -> some View {
    content
      .background(
        NavigationLink(
          destination: destination,
          isActive: $isPresented
        ) { EmptyView() }
      )
  }
}

extension View {
  func navigation<Destination: View>(isPresented: Binding<Bool>, @ViewBuilder destination: () -> Destination) -> some View {
    self.modifier(NavigationModifier(isPresented: isPresented, destination: destination))
  }
}
