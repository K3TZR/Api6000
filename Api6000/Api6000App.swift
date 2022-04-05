//
//  Api6000App.swift
//  Api6000
//
//  Created by Douglas Adams on 11/16/21.
//

import SwiftUI
import ComposableArchitecture

import ApiViewer
import LogViewer
import RemoteViewer
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

    WindowGroup(getBundleInfo().appName + " (Api Viewer) v" + Version().string) {
      ApiView(
        store: Store(
          initialState: ApiState(),
          reducer: apiReducer,
          environment: ApiEnvironment()
        )
      )
      .toolbar {
        Button("Remote View") { OpenWindows.RemoteViewer.open()  }
        Button("Log View") { OpenWindows.LogViewer.open() }
        Button("Close") { NSApplication.shared.keyWindow?.close()  }
        Button("Close All") { NSApplication.shared.terminate(self)  }
      }
        .frame(minWidth: 975, minHeight: 400)
        .padding()
    }
    
    WindowGroup(getBundleInfo().appName + " (Log Viewer) v" + Version().string) {
      LogView(store: Store(
        initialState: LogState(),
        reducer: logReducer,
        environment: LogEnvironment() )
      )
      .toolbar {
        Button("Close") { NSApplication.shared.keyWindow?.close()  }
      }
      .frame(minWidth: 975, minHeight: 400)
      .padding()
    }.handlesExternalEvents(matching: Set(arrayLiteral: "LogViewer"))
    
    WindowGroup(getBundleInfo().appName + " (Remote Viewer) v" + Version().string) {
      RemoteView(store: Store(
        initialState: RemoteState( "Relay Status" ),
        reducer: remoteReducer,
        environment: RemoteEnvironment() )
      )
      .toolbar {
        Button("Close") { NSApplication.shared.keyWindow?.close()  }
      }

      .frame(minWidth: 975, minHeight: 400)
      .padding()
    }.handlesExternalEvents(matching: Set(arrayLiteral: "RemoteViewer"))

    
    .commands {
      //remove the "New" menu item
      CommandGroup(replacing: CommandGroupPlacement.newItem) {}
    }
  }
}

enum OpenWindows: String, CaseIterable {
  case LogViewer = "LogViewer"
  case RemoteViewer = "RemoteViewer"
  
  func open() {
    if let url = URL(string: "Api6000://\(self.rawValue)") {
      NSWorkspace.shared.open(url)
    }
  }
}
