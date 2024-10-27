//
//  Blur.swift
//  inOS
//
//  Created by Uwais Alqadri on 27/10/24.
//

import Foundation
import SwiftUI

public struct Blur: UIViewRepresentable {
  @State var style: UIBlurEffect.Style
  
  public init(style: UIBlurEffect.Style = .systemMaterial) {
    self.style = style
  }
  
  public func makeUIView(context: Context) -> UIVisualEffectView {
    return UIVisualEffectView(effect: UIBlurEffect(style: style))
  }
  
  public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    uiView.effect = UIBlurEffect(style: style)
  }
}
