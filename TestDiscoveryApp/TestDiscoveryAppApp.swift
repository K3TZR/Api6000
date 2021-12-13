//
//  TestDiscoveryAppApp.swift
//  TestDiscoveryApp
//
//  Created by Douglas Adams on 11/16/21.
//

import SwiftUI
import ComposableArchitecture

import Shared

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // disable tab view
        NSWindow.allowsAutomaticWindowTabbing = false
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // close when last window closed
        true
    }
}


@main
struct TestDiscoveryAppApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate

  var body: some Scene {
    WindowGroup {
      RootView(
        store: Store(
          initialState: RootState(),
          reducer: rootReducer,
          environment: RootEnvironment()
        )
      )
        .navigationTitle("TestDiscoveryApp   v" + Version().string)
        .frame(minWidth: 950, minHeight: 300, idealHeight: 400, maxHeight: 600)
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
  }
}
