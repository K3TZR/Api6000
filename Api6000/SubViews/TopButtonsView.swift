//
//  TopButtonsView.swift
//  Api6000Components/ApiViewer/Subviews/ViewerSubViews
//
//  Created by Douglas Adams on 1/8/22.
//

import ComposableArchitecture
import SwiftUI

import Shared

// ----------------------------------------------------------------------------
// MARK: - View

public struct TopButtonsView: View {
  let store: StoreOf<ApiModule>
  
  struct ViewState: Equatable {
    let isGui: Bool
    let showTimes: Bool
    let showPings: Bool
    let rxAudio: Bool
    let txAudio: Bool
    let local: Bool
    let smartlink: Bool
    let loginRequired: Bool
    let useDefault: Bool
    let isConnected: Bool
    init(state: ApiModule.State) {
      self.isGui = state.isGui
      self.showTimes = state.showTimes
      self.showPings = state.showPings
      self.rxAudio = state.rxAudio
      self.txAudio = state.txAudio
      self.local = state.local
      self.smartlink = state.smartlink
      self.loginRequired = state.loginRequired
      self.useDefault = state.useDefault
      self.isConnected = state.isConnected
    }
  }

 public  var body: some View {

   WithViewStore(self.store, observe: ViewState.init) { viewStore in
      HStack(spacing: 20) {
        Button(viewStore.isConnected ? "Stop" : "Start") {
          viewStore.send(.startStopButton)
        }
        .keyboardShortcut(viewStore.isConnected ? .cancelAction : .defaultAction)

        HStack(spacing: 10) {
          Toggle("Gui", isOn: viewStore.binding(get: \.isGui, send: .toggle(\ApiModule.State.isGui)))
            .frame(width: 60)
            .disabled( viewStore.isConnected )
          Group {
            Toggle("Show Times", isOn: viewStore.binding(get: \.showTimes, send: .toggle(\ApiModule.State.showTimes)))
            Toggle("Show Pings", isOn: viewStore.binding(get: \.showPings, send: .showPingsToggle))
          }
          .frame(width: 100)
        }

        Spacer()
        ControlGroup {
          Toggle(isOn: viewStore.binding(get: \.rxAudio, send: { .rxAudioButton($0)} )) {
            Text("Rx Audio") }
          Toggle(isOn: viewStore.binding(get: \.txAudio, send: { .txAudioButton($0)} )) {
            Text("Tx Audio") }
        }
        .frame(width: 130)

        Spacer()
        ControlGroup {
          Toggle("Local", isOn: viewStore.binding(get: \.local, send: { .localButton($0) } ))
          Toggle("Smartlink", isOn: viewStore.binding(get: \.smartlink, send: { .smartlinkButton($0) } ))
        }
        .frame(width: 130)
        .disabled( viewStore.isConnected )

        Spacer()
        Toggle("Smartlink Login", isOn: viewStore.binding(get: \.loginRequired, send: { .loginRequiredButton($0) }))
          .disabled( viewStore.isConnected || viewStore.smartlink == false )
        Toggle("Use Default", isOn: viewStore.binding(get: \.useDefault, send: .toggle(\ApiModule.State.useDefault)))
          .disabled( viewStore.isConnected )
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct TopButtonsView_Previews: PreviewProvider {
  static var previews: some View {
    TopButtonsView(
      store: Store(
        initialState: ApiModule.State(),
        reducer: ApiModule()
      )
//      , viewModel: ViewModel.shared
    )
      .frame(minWidth: 975)
      .padding()
  }
}
