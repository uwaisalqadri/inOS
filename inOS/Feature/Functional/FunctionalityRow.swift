//
//  FunctionalityRow.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 10/1/24.
//

import SwiftUI
import inCore

struct FunctionalityRow: View {
  let item: Assessment
  var isTesting: Bool
  var isPassed: Bool?
  var onTestFunction: (() -> Void)?
  
  private var iconColor: Color {
    switch isPassed {
    case true:
      return .blue
    case false:
      return .red
    default:
      return .blue.opacity(0.3)
    }
  }
  
  var body: some View {
    Button(action: {
      UIImpactFeedbackGenerator().impactOccurred()
      onTestFunction?()
    }) {
      ZStack(alignment: .topTrailing) {
        if let isPassed {
          Image(systemName: isPassed ? "checkmark" : "xmark")
            .font(.system(size: 20))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .foregroundColor(isPassed ? .green : .red)
            .padding(.top, 10)
            .animation(.easeInOut, value: isPassed)
        }
        
        VStack(alignment: .leading, spacing: 0) {
          Image(systemName: item.icon)
            .font(.system(size: 30))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(iconColor)
            .padding(.top, 10)
          
          Spacer()
          
          Text(item.title)
            .bold()
            .padding(.top, 16)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)

          Text(item.value)
            .font(.system(size: 12))
            .padding(.top, 3)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      .frame(height: 130)
      .padding(14)
      .background(
        Blur().cornerRadius(12)
      )
    }
    .buttonStyle(.plain)
    .animation(.spring, value: isTesting)
    .opacity(isTesting ? 0.2 : 1.0)
  }
}
