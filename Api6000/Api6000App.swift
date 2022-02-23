//
//  Api6000App.swift
//  Api6000
//
//  Created by Douglas Adams on 11/16/21.
//

import SwiftUI
import ComposableArchitecture

import ApiViewer
import Shared

final class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    // disable tab view
    NSWindow.allowsAutomaticWindowTabbing = false
  }
  
  func applicationWillTerminate(_ notification: Notification) {
    LogProxy.sharedInstance.log("Api6000: application terminated", .debug, #function, #file, #line)
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
}

@main
struct Api6000App: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate

  var body: some Scene {

    WindowGroup {
      ApiView(
        store: Store(
          initialState: ApiState(),
          reducer: apiReducer,
          environment: ApiEnvironment()
        )
      )
        .navigationTitle(getBundleInfo().appName + "   v" + Version().string)
        .frame(minWidth: 975, minHeight: 400)
        .padding()
    }
    .commands {
      //remove the "New" menu item
      CommandGroup(replacing: CommandGroupPlacement.newItem) {}
    }
  }
}
