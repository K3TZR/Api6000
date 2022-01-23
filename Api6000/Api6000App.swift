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
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // close when last window closed
        true
    }
}

@main
struct Api6000App: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate
  
  var body: some Scene {

    let bundleIdentifier = Bundle.main.bundleIdentifier ?? "someDomain.SomeApp"
    let separator = bundleIdentifier.lastIndex(of: ".")!
    let appName = String(bundleIdentifier.suffix(from: bundleIdentifier.index(separator, offsetBy: 1)))
    let domain = String(bundleIdentifier.prefix(upTo: separator))

    WindowGroup {
      ApiView(
        store: Store(
          initialState: ApiState(domain: domain, appName: appName),
          reducer: apiReducer,
          environment: ApiEnvironment()
        )
      )
      .navigationTitle(appName + "   v" + Version().string)
      .frame(minWidth: 975, minHeight: 400)
      .padding()
    }
    .commands {
      //remove the "New" menu item
      CommandGroup(replacing: CommandGroupPlacement.newItem) {}
    }
  }
}
