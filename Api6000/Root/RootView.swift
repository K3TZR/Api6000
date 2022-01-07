//
//  RootView.swift
//  TestDiscoveryApp/Root
//
//  Created by Douglas Adams on 11/20/21.
//

import SwiftUI
import ComposableArchitecture

import ApiViewer
import LogViewer

// ----------------------------------------------------------------------------
// MARK: - View(s)

struct RootView: View {
  let store: Store<RootState, RootAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      
      switch viewStore.viewType {
      case .api:
        IfLetStore(
          store.scope(
            state: \.apiState,
            action: RootAction.apiAction
          ),
          then: ApiView.init(store:)
        )
      
      case .log:
        IfLetStore(
          store.scope(
            state: \.logState,
            action: RootAction.logAction
          ),
          then: LogView.init(store:)
        )
      }
    }
    .frame(minWidth: 975, minHeight: 400)
    .padding()
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview(s)

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
