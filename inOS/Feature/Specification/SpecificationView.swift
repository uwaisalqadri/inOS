//
//  SpecificationView.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 27/10/24.
//

import SwiftUI

struct SpecificationView: View {
  @StateObject private var presenter: SpecificationPresenter
  
  init() {
    _presenter = StateObject(
      wrappedValue: SpecificationPresenter()
    )
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Information")
          .fontWeight(.bold)
          .frame(maxWidth: .infinity, alignment: .leading)
        Divider()
        Text("Specification")
          .fontWeight(.bold)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.leading, 10)
      }
      .padding(.horizontal, 16)
      .background(Color.gray.opacity(0.1))
      .clipShape(.rect(cornerRadius: 14))
      .frame(height: 50)
      .padding(.horizontal, 16)
      
      List(presenter.state.specs) { model in
        HStack {
          Text(model.title)
            .frame(maxWidth: .infinity, alignment: .leading)
          Text(model.value)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 10)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
      }
      .listStyle(.plain)
    }
    .padding(.top, 16)
    .onAppear {
      presenter.send(.loadDeviceSpecs)
    }
    .navigation(isPresented: $presenter.state.isBenchmarkPresented) {
      BenchmarkView()
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        DeviceView(
          isShimmer: true,
          onTapGesture: {
            presenter.state.isBenchmarkPresented = true
          }
        )
      }
      
      ToolbarItem(placement: .topBarTrailing) {
        Button(action: {
          if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
          }
        }) {
          Image(systemName: "gear")
            .font(.system(size: 20))
            .foregroundColor(.blue)
        }
      }
    }
  }
}
