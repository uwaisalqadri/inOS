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
    ZStack {
      if #available(iOS 17.0, *) {
        benchmarkView
      } else {
        benchmarkView
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .principal) {
              DeviceView()
            }
          }
          .background(
            HStack(alignment: .top) {
              Capsule()
                .fill(Color(.lightGray))
                .frame(width: 100, height: 6)
                .opacity(0.2)
                .padding(.top, 8)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
          )
      }
    }
    .onAppear {
      presenter.send(.onAppear)
    }
    .onDisappear {
      presenter.send(.onDisappear)
    }
  }
  
  var benchmarkView: some View {
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
          ZStack(alignment: .top) {
            Image(systemName: "square.and.arrow.down.fill")
              .font(.system(size: 60))
              .padding(.top, 45)
              .foregroundColor(.blue)
            Blur(style: .systemMaterial).cornerRadius(Theme.current.cornerRadius)
          }
        )
      }
      .padding([.top, .horizontal], 12)
    }
    .padding(.top, 12)
  }
}

#Preview {
  NavigationView {
    BenchmarkView()
  }
}
