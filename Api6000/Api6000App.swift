//
//  Api6000App.swift
//  Api6000
//
//  Created by Douglas Adams on 11/28/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApi
import LeftSideFeature
import LogFeature
import PanFeature
import RightSideFeature
import SettingsFeature
import Shared

enum WindowType: String {
  case left = "Left View"
  case log = "Log View"
  case panadapter = "Panadapter View"
  case right = "Right View"
  case settings = "Settings"
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
  @Dependency(\.objectModel) var objectModel
  @Dependency(\.streamModel) var streamModel

  var body: some Scene {

    // Main window
    WindowGroup("Api6000  (v" + Version().string + ")") {
      ApiView(store: Store(
        initialState: ApiModule.State(),
        reducer: ApiModule())
      )
      .frame(minWidth: 975)
      .padding(.horizontal, 20)
      .padding(.vertical, 10)
    }

    // Log window
    Window(WindowType.log.rawValue, id: WindowType.log.rawValue) {
      LogView(store: Store(initialState: LogFeature.State(), reducer: LogFeature()) )
      .frame(minWidth: 975)
    }
    .windowStyle(.hiddenTitleBar)
    .defaultPosition(.bottomTrailing)

    // Rightside window
    Window(WindowType.right.rawValue, id: WindowType.right.rawValue) {
      RightSideView(store: Store(initialState: RightSideFeature.State(), reducer: RightSideFeature()), apiModel: apiModel, objectModel: objectModel)
      .frame(minHeight: 210)
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(WindowResizability.contentSize)
    .defaultPosition(.topTrailing)
        
    // Leftside window
    Window(WindowType.left.rawValue, id: WindowType.left.rawValue) {
      LeftSideView(store: Store(initialState: LeftSideFeature.State(panadapterId: objectModel.activePanadapter?.id, waterfallId: objectModel.activePanadapter?.waterfallId), reducer: LeftSideFeature()))
        .frame(minWidth: 75, minHeight: 250)
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(WindowResizability.contentSize)
    .defaultPosition(.topLeading)
    
    // Panadapter window
    Window(WindowType.panadapter.rawValue, id: WindowType.panadapter.rawValue) {
      PanView(store: Store(initialState: PanFeature.State(), reducer: PanFeature()), objectModel: objectModel)
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(WindowResizability.contentSize)
    .defaultPosition(.center)

    // Settings window
    Settings {
      SettingsView(store: Store(initialState: SettingsFeature.State(), reducer: SettingsFeature()), objectModel: objectModel)
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
