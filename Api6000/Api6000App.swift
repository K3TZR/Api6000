//
//  Api6000App.swift
//  Api6000
//
//  Created by Douglas Adams on 11/28/22.
//

import ComposableArchitecture
import SwiftUI

import Objects
import LeftSideFeature
import LogFeature
import RightSideFeature
import SettingsFeature
import Shared

enum WindowType: String {
  case leftView = "Left View"
  case logView = "Log View"
  case panadapterView = "Panadapter View"
  case rightView = "Right View"
  case settingsView = "Settings"
}

final class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    // disable tab view
    NSWindow.allowsAutomaticWindowTabbing = false
  }
    
  func applicationWillTerminate(_ notification: Notification) {
    log("Api6000: application terminated", .debug, #function, #file, #line)
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
}

@main
struct Api6000App: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate
  
  @Dependency(\.apiModel) var apiModel
  
  var body: some Scene {

    WindowGroup("Api6000  (v" + Version().string + ")") {
      ApiView(store: Store(
        initialState: ApiModule.State(),
        reducer: ApiModule())
      )
      .frame(minWidth: 975)
      .padding(.horizontal, 20)
      .padding(.vertical, 10)
    }

    Window(WindowType.logView.rawValue, id: WindowType.logView.rawValue) {
      LogView(store: Store(initialState: LogFeature.State(), reducer: LogFeature()) )
      .frame(minWidth: 975)
    }
    .windowStyle(.hiddenTitleBar)
    .defaultPosition(.bottomTrailing)

    Window(WindowType.rightView.rawValue, id: WindowType.rightView.rawValue) {
      RightSideView(store: Store(initialState: RightSideFeature.State(), reducer: RightSideFeature()), apiModel: apiModel)
      .frame(minHeight: 210)
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(WindowResizability.contentSize)
    .defaultPosition(.topTrailing)
        
    Window(WindowType.leftView.rawValue, id: WindowType.leftView.rawValue) {
      LeftSideView(store: Store(initialState: LeftSideFeature.State(), reducer: LeftSideFeature()), apiModel: apiModel)
      .frame(minHeight: 210)
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(WindowResizability.contentSize)
    .defaultPosition(.topLeading)
    
    Settings {
      SettingsView(store: Store(initialState: SettingsFeature.State(), reducer: SettingsFeature()), apiModel: apiModel)
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(WindowResizability.contentSize)
    .defaultPosition(.bottomLeading)

    .commands {
      //remove the "New" menu item
      CommandGroup(replacing: CommandGroupPlacement.newItem) {}
    }
  }
}
