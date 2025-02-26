//
//  DeviceView.swift
//  inOS
//
//  Created by Uwais Alqadri on 25/01/25.
//

import SwiftUI
import DeviceKit

struct DeviceView: View {
  @AppStorage("isDarkMode") private var isDarkMode: Bool = false
  var isShimmer: Bool = false
  var onTapGesture: (() -> Void)? = nil
  
  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: FunctionalityPresenter.Status.Specs.phone.icon)
        .font(.system(size: 20))
        .foregroundColor(.blue)
      
      Text(Device.current.safeDescription)
        .font(.system(size: 14, weight: .semibold))
    }
    .foregroundColor(isDarkMode ? .white : .black)
    .padding(.all, 3)
    .overlay(
      Group {
        if isShimmer {
          ShimmerView()
            .opacity(isDarkMode ? 0.2 : 0.7)
        } else {
          Color.clear
        }
      }
    )
    .onTapGesture {
      onTapGesture?()
    }
  }
}


public struct ShimmerView: View {
  @State
  private var xOffset: CGFloat = -250
  
  public init() {}
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        Color.clear
        
        LinearGradient(
          gradient:
            Gradient(
              colors: [
                Color(red: 0.9450980392, green: 0.937254902, blue: 0.937254902),
                Color.white,
                Color(red: 0.9450980392, green: 0.937254902, blue: 0.937254902)
              ]
            ),
          startPoint: .leading,
          endPoint: .trailing
        )
        .mask(
          Rectangle()
            .fill(
              LinearGradient(
                gradient: Gradient(
                  colors: [
                    Color.clear,
                    Color.white,
                    Color.clear
                  ]
                ),
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .offset(x: xOffset)
            .animation(
              Animation
                .linear(duration: 1.6)
                .repeatForever(autoreverses: true)
            )
            .onAppear {
              xOffset = geometry.size.width
            }
        )
      }
      .cornerRadius(8)
    }
  }
}

