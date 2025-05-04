//
//  CameraViewController.swift
//  inOS
//
//  Created by Uwais Alqadri on 27/10/24.
//

import SwiftUI
import AlertToast

struct CameraAssessmentView: View {
  @State var isShowingToast = false
  @State var isCheckingFrontCamera = false
  @State var isFrontCameraUndetected = false
  @State var isBackCameraUndetected = false
  
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea(.all)
      
      CameraAssessmentViewRepresentable(
        isCheckingFrontCamera: $isCheckingFrontCamera,
        isFrontCameraUndetected: $isFrontCameraUndetected,
        isBackCameraUndetected: $isBackCameraUndetected
      )
      
      VStack {
        if !isBackCameraUndetected || !isFrontCameraUndetected {
          Spacer()
            .frame(height: 90)
            .background(Color.clear)
          
          Spacer()
            .background(Color.clear)
        }
      }
      .onAppear {
        isShowingToast = true
      }
      .onDisappear {
        isShowingToast = false
      }
      .toast(
        isPresenting: $isShowingToast,
        duration: 4.5,
        tapToDismiss: true,
        offsetY: 60
      ) {
        AlertToast(
          displayMode: .hud,
          type: .regular,
          title: isCheckingFrontCamera ? "Checking front camera" : "Checking rear camera"
        )
      }
    }
  }
}
