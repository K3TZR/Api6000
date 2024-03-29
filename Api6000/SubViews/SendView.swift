//
//  SendView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/8/22.
//

import ComposableArchitecture
import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View

struct SendView: View {
  let store: StoreOf<ApiModule>
  
  struct ViewState: Equatable {
    let clearOnSend: Bool
    let commandToSend: String
    let isConnected: Bool
    init(state: ApiModule.State) {
      self.clearOnSend = state.clearOnSend
      self.commandToSend = state.commandToSend
      self.isConnected = state.isConnected
    }
  }

  var body: some View {

    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      HStack(spacing: 25) {
        Group {
          Button("Send") { viewStore.send(.commandSend) }
          .keyboardShortcut(.defaultAction)

          HStack(spacing: 0) {
            Image(systemName: "x.circle")
              .onTapGesture {
                viewStore.send(.commandClear)
              }
            
            Stepper("", onIncrement: {
              viewStore.send(.commandPrevious)
            }, onDecrement: {
              viewStore.send(.commandNext)
            })
            
            TextField("Command to send", text: viewStore.binding(
              get: \.commandToSend,
              send: {.commandText($0)} ))
          }
        }
        .disabled(viewStore.isConnected == false)

        Spacer()
        Toggle("Clear on Send", isOn: viewStore.binding(get: \.clearOnSend, send: .stateToggle(\ApiModule.State.clearOnSend)))
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct SendView_Previews: PreviewProvider {
  static var previews: some View {
    SendView(
      store: Store(
        initialState: ApiModule.State(),
        reducer: ApiModule()
      )
    )
    .frame(minWidth: 975)
    .padding()
  }
}
