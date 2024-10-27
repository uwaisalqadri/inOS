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
    VStack(spacing: 16) {
      if let icon = Bundle.main.icon {
        Image(uiImage: icon)
          .resizable()
          .frame(width: 100, height: 100)
          .clipShape(RoundedRectangle(cornerRadius: 20))
      }
      
      if let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String {
        Text("Start with \(appName)")
          .font(.title)
          .bold()
          .multilineTextAlignment(.center)
      }
      
      Text("This utility app allows you to perform a series of tests to ensure your phone is functioning optimally.")
        .multilineTextAlignment(.center)
      
      Divider()
      
      VStack(alignment: .leading, spacing: 5) {
        Text("Features:")
          .font(.headline)
          .bold()
        Text("• Comprehensive Device Testing")
        Text("• Detailed Performance Assessments")
        Text("• Quick and Easy to Use")
        Text("• User-Friendly Interface")
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      
      Spacer()
      
      Divider()
      
      Button(action: onStart) {
        Text("Start")
          .font(.system(size: 18, weight: .bold))
          .foregroundColor(.white)
          .frame(maxWidth: .infinity, maxHeight: 45)
          .background(Color.blue.clipShape(Capsule()))
      }
    }
    .padding(.top, 16)
    .padding(16)
  }
}

#Preview {
  IntroductionView {
    
  }
}
