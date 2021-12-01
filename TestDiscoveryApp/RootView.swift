//
//  RootView.swift
//  TestDiscoveryApp
//
//  Created by Douglas Adams on 11/20/21.
//

import SwiftUI
import ComposableArchitecture
import Picker
import LogViewer

struct RootView: View {
  let store: Store<RootState, RootAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      
      switch viewStore.rootViewType {
      case .apiTester:
        ApiViewer(store: store)
      
      case .logViewer:
        IfLetStore(
          store.scope(state: \.logState, action: RootAction.logAction),
          then: LogViewer.init(store:)
        )
      }
    }
  }
}

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView(
      store: Store(
        initialState: RootState(),
        reducer: rootReducer,
        environment: RootEnvironment()
      )
    )
  }
}
