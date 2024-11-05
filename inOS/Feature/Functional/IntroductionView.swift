//
//  IntroductionView.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 27/10/24.
//

import SwiftUI

struct IntroductionView: View {
  var onStart: () -> Void
  
  var body: some View {
    VStack(spacing: 20) {
      if let icon = Bundle.main.icon {
        Image(uiImage: icon)
          .resizable()
          .frame(width: 70, height: 70)
          .clipShape(.rect(cornerRadius: 15))
          .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 6)
          .padding(.bottom, 10)
          .padding(.top, 26)
      }
      
      if let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String {
        Text("Welcome to \(appName)")
          .font(.title2)
          .fontWeight(.semibold)
          .multilineTextAlignment(.center)
      }
      
      Text("Easily run tests to make sure your device is in top shape!")
        .font(.body)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
        .padding(.top, -16)
      
      Divider()
        .padding(.vertical, 10)
      
      VStack(alignment: .leading, spacing: 8) {
        Text("Features:")
          .font(.headline)
          .fontWeight(.bold)
        
        VStack(alignment: .leading, spacing: 5) {
          Label("Comprehensive Device Testing", systemImage: "checkmark.circle")
          Label("Detailed Performance Insights", systemImage: "chart.bar")
          Label("Quick and Easy to Use", systemImage: "hand.tap")
          Label("User-Friendly Interface", systemImage: "star.circle")
        }
        .font(.subheadline)
      }
      .padding()
      .background(Color.blue.opacity(0.05))
      .cornerRadius(16)
      
      Divider()
        .padding(.vertical, 10)
      
      Text("When a test passes, the icon will update to show success or failure.")
        .font(.footnote)
        .fontWeight(.bold)
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 30)
      
      HStack {
        Image(systemName: "faceid")
          .font(.system(size: 30))
          .foregroundColor(.blue.opacity(0.3))
        
        Image(systemName: "arrow.right")
          .font(.system(size: 20))
          .foregroundColor(.black)
        
        Image(systemName: "faceid")
          .font(.system(size: 30))
          .foregroundColor(.blue)
        
        Image(systemName: "faceid")
          .font(.system(size: 30))
          .foregroundColor(.red)
      }
      .padding(.top, 12)
      
      Spacer()
      
      Button(action: onStart) {
        Text("Get Started")
          .font(.system(size: 18, weight: .medium))
          .foregroundColor(.white)
          .padding(.vertical, 12)
          .frame(maxWidth: .infinity)
          .background(Color.blue)
          .clipShape(.capsule)
      }
      .padding(.top, 20)
    }
    .padding()
  }
}

#Preview {
  IntroductionView { }
}
