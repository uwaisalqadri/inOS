//
//  MonitorView.swift
//  inOS
//
//  Created by Uwais Alqadri on 23/02/25.
//

import SwiftUI
import AlertToast

struct MonitorView: View {
  @AppStorage("isDarkMode") private var isDarkMode: Bool = false
  @StateObject private var viewModel: MonitorViewModel
  
  init() {
    _viewModel = StateObject(
      wrappedValue: MonitorViewModel()
    )
  }
  
  var body: some View {
    ZStack {
      if viewModel.state.connectedDevice.isEmpty {
        noDeviceView()
      } else {
        VStack {
          Button(action: {
            viewModel.send(.onHotspotEnabled)
          }) {
            VStack(spacing: 6) {
              Image(systemName: "personalhotspot")
                .font(.system(size: 50))
                .foregroundColor(viewModel.state.isHotspotEnabled ? .blue : .blue.opacity(0.3))
              
              let color: Color = isDarkMode ? .white : .black
              Text("Hotspot")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(viewModel.state.isHotspotEnabled ? color : color.opacity(0.3))
            }
            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 3)
            .padding()
            .background(
              Blur().cornerRadius(24)
            )
          }.buttonStyle(.plain)
          
          Spacer()
        }
      }
    }
    .toast(isPresenting: $viewModel.state.isLoading, alert: {
      AlertToast(displayMode: .alert, type: .loading)
    })
    .padding([.horizontal, .top], 32)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        if !viewModel.state.connectedDevice.isEmpty {
          HStack(spacing: 4) {
            Image(systemName: "iphone.homebutton")
              .font(.system(size: 20))
              .foregroundColor(.blue)
            
            Text(viewModel.state.connectedDevice)
              .font(.system(size: 14, weight: .semibold))
          }
          .padding(.all, 3)
        }
      }
    }
  }
  
  @ViewBuilder
  func noDeviceView() -> some View {
    Button(action: {
      viewModel.send(.onConnectDevice)
    }) {
      Image(systemName: "iphone.homebutton")
      Text("No Device")
    }.buttonStyle(.plain)
  }
}

