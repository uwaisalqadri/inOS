//
//  MainView.swift
//  inOS
//
//  Created by Uwais Alqadri on 19/04/25.
//

import SwiftUI
import inCore

struct MainView: View {
  @StateObject private var presenter = FunctionalityPresenter()
  
  var body: some View {
    SplitView(
      topView: {
        FunctionalityView()
      },
      bottomView: {
        BenchmarkView()
      },
      topMiniOverlay: {
        HStack {
          DeviceView()
        }.frame(maxWidth: .infinity, alignment: .center)
      },
      bottomMiniOverlay: {
        HStack {
          DashboardMetricView(
            deviceMetrics: $presenter.state.deviceMetrics,
            isRunning: false,
            isSpecificationPresented: .constant(false),
            isBenchmarkPresented: .constant(false)
          ).padding(16)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .onAppear {
          presenter.send(.loadStatus)
        }
      }
    )

  }
}

