//
//  BenchmarkView.swift
//  inOS
//
//  Created by Uwais Alqadri on 27/11/24.
//

import SwiftUI
import DeviceKit

struct BenchmarkView: View {
  @StateObject var presenter: BenchmarkPresenter
  
  init() {
    _presenter = StateObject(
      wrappedValue: BenchmarkPresenter()
    )
  }
  
  var body: some View {
    VStack(spacing: 0) {
      ForEach(presenter.state.benchmarks, id: \.self) { benchmark in
        VStack {
          Image(systemName: benchmark.icon)
            .font(.system(size: 50))
            .foregroundColor(.blue)
          
          Text(presenter.getBenchmark(of: benchmark).wrappedValue)
            .font(.system(size: 24, weight: .bold))
            .padding(.top, 6)
          
          Text(benchmark.title)
            .font(.system(size: 16, weight: .medium))
        }
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 3)
        .padding()
        .background(
          Blur().cornerRadius(12)
        )
      }
      .padding([.top, .horizontal], 12)
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        DeviceView()
      }
    }
    .onAppear {
      presenter.send(.onAppear)
    }
    .onDisappear {
      presenter.send(.onDisappear)
    }
  }
}

#Preview {
  NavigationView {
    BenchmarkView()
  }
}
