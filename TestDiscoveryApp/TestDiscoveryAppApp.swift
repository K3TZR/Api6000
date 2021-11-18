//
//  TestDiscoveryAppApp.swift
//  TestDiscoveryApp
//
//  Created by Douglas Adams on 11/16/21.
//

import SwiftUI
import ComposableArchitecture
import Picker

@main
struct TestDiscoveryAppApp: App {
    var body: some Scene {
        WindowGroup {
          PickerView(store: Store(initialState: PickerState(),
                                      reducer: pickerReducer,
                                      environment: PickerEnvironment()
                                 )
          ).frame(width: 600, height: 300)
        }
    }
}
