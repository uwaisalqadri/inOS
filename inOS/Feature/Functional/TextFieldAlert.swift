//
//  TextFieldAlert.swift
//  inOS
//
//  Created by Uwais Alqadri on 04/11/24.
//

import SwiftUI
import Combine

extension View {
  public func textFieldAlert(
    isPresented: Binding<Bool>,
    title: String,
    text: Binding<String>,
    placeholder: String = "",
    onSubmit: @escaping (String) -> Void,
    onRepeat: @escaping () -> Void
  ) -> some View {
    self.modifier(
      TextFieldAlert(
        isPresented: isPresented,
        title: title,
        text: text,
        placeholder: placeholder,
        onSubmit: onSubmit,
        onRepeat: onRepeat
      )
    )
  }
}

struct TextFieldAlert: ViewModifier {
  @Binding var isPresented: Bool
  let title: String
  @Binding var text: String
  let placeholder: String
  let onSubmit: (String) -> Void
  let onRepeat: () -> Void

  func body(content: Content) -> some View {
    ZStack(alignment: .top) {
      content.disabled(isPresented)

      if isPresented {
        VStack(spacing: 0) {
          Text(title)
            .font(.headline)
            .padding([.top, .horizontal], 20)

          TextField(placeholder, text: $text)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .textFieldStyle(.roundedBorder)
            .padding(.top, 18)
            .padding(.horizontal, 12)
            .padding(.bottom, 20)
            .onReceive(Just(text)) { _ in limitText(1) }
          
          Divider()

          HStack {
            Spacer()
            Button(action: {
              onRepeat()
            }) {
              Text("Repeat")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(.rect)
            }
            Spacer()
            
            Divider()
            
            Spacer()
            Button(action: {
              dismissKeyboard()
              onSubmit(text)
              withAnimation {
                isPresented.toggle()
              }
            }) {
              Text("Done")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(.rect)
            }
            Spacer()
          }.frame(height: 50)
        }
        .background(Blur())
        .frame(width: 300)
        .cornerRadius(20)
        .overlay(
          RoundedRectangle(cornerRadius: 20)
            .stroke(lineWidth: 0.5)
            .foregroundColor(.init(.lightGray).opacity(0.5))
        )
        .padding(.top, 200)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 6)
      }
    }
    .background(Color.clear)
    .animation(.easeInOut, value: isPresented)
    .onChange(of: isPresented) { _ in
      text = ""
    }
  }
  
  private func limitText(_ upper: Int) {
    if text.count > upper {
      text = String(text.prefix(upper))
    }
  }
  
  private func dismissKeyboard() {
    UIView.animate(withDuration: 0.3) {
      UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
  }
}
