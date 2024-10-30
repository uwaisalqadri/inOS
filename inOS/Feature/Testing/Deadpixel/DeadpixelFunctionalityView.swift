//
//  DeadpixelFunctionalityView.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 8/9/24.
//

import SwiftUI

struct DeadpixelFunctionalityView: View {
  @StateObject var presenter: DeadpixelFunctionalityPresenter

  init() {
    _presenter = StateObject(
      wrappedValue: DeadpixelFunctionalityPresenter()
    )
  }

  var body: some View {
    ZStack {
      switch presenter.state.index {
      case 0:
        Color(.redDeadPixel)
      case 1:
        Color(.greenDeadPixel)
      case 2:
        Color(.blueDeadPixel)
      case 3:
        Color.black
      case 4:
        Color.white
      default:
        Color(.redDeadPixel)
      }
    }
    .edgesIgnoringSafeArea(.all)
    .onAppear {
      presenter.send(.setTimer)
    }
    .onTapGesture {
      presenter.send(.failed)
    }
  }
}

#Preview {
  DeadpixelFunctionalityView()
}
