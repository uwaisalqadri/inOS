//
//  CameraViewController.swift
//  inOS
//
//  Created by Uwais Alqadri on 27/10/24.
//

import SwiftUI

struct CameraFunctionalityView: View {
  @State var isCheckingFrontCamera = false
  @State var isFrontCameraUndetected = false
  @State var isBackCameraUndetected = false
  
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea(.all)
      
      CameraFunctionalityViewRepresentable(
        isCheckingFrontCamera: $isCheckingFrontCamera,
        isFrontCameraUndetected: $isFrontCameraUndetected,
        isBackCameraUndetected: $isBackCameraUndetected
      )
      
      VStack {
        if !isBackCameraUndetected || !isFrontCameraUndetected {
          Spacer()
            .frame(height: 90)
            .background(Color.clear)
          
          Text(isCheckingFrontCamera ? "Checking front camera" : "Checking rear camera")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.black)
            .frame(width: UIScreen.main.bounds.width - 35, height: 44)
            .padding(.horizontal)
            .background(Color.white)
            .cornerRadius(12)
          
          Spacer()
            .background(Color.clear)
        }
      }

    }
  }
}
