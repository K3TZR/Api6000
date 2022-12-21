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


//extension StreamModel: DependencyKey {
//  public static let liveValue = StreamModel.shared
//}
//
//extension DependencyValues {
//  var streamModel: StreamModel {
//    get { self[StreamModel.self] }
//    set { self[StreamModel.self] = newValue }
//  }
//}

//extension PacketModel: DependencyKey {
//  public static let liveValue = PacketModel.shared
//}
//
//extension DependencyValues {
//  var packetModel: PacketModel {
//    get { self[PacketModel.self] }
//    set { self[PacketModel.self] = newValue }
//  }
//}
//

//private struct isConnectedKey: EnvironmentKey {
//  static let defaultValue = false
//}
//extension EnvironmentValues {
//  var isConnected: Bool {
//    get { self[isConnectedKey.self] }
//    set { self[isConnectedKey.self] = newValue }
//  }
//}

enum WindowType: String {
  case leftSideView = "Left View"
  case logView = "Log View"
  case panadapterView = "Panadapter View"
  case rightSideView = "Right View"
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
  
  @Environment(\.openWindow) var openWindow
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

      .toolbar {
        Spacer()
//        Button(WindowType.panadapterView.rawValue) { openWindow(id: WindowType.panadapter.ViewrawValue) }
        Button(WindowType.logView.rawValue) { openWindow(id: WindowType.logView.rawValue) }
        Button(WindowType.leftSideView.rawValue) { openWindow(id: WindowType.leftSideView.rawValue) }
        Button(WindowType.rightSideView.rawValue) { openWindow(id: WindowType.rightSideView.rawValue) }
        Button("Close") { NSApplication.shared.terminate(self)  }
      }
    }

    Window(WindowType.logView.rawValue, id: WindowType.logView.rawValue) {
      LogView(store: Store(initialState: LogFeature.State(), reducer: LogFeature()) )
      .toolbar {
        Button("Close") { NSApplication.shared.keyWindow?.close()  }
        Button("Close All") { NSApplication.shared.terminate(self)  }
      }
      .frame(minWidth: 975)
    }
    .windowStyle(.hiddenTitleBar)
    .defaultPosition(.bottomTrailing)

    Window(WindowType.rightSideView.rawValue, id: WindowType.rightSideView.rawValue) {
      RightSideView(store: Store(initialState: RightSideFeature.State(), reducer: RightSideFeature()), apiModel: apiModel)
      .toolbar {
        Button("Close") { NSApplication.shared.keyWindow?.close()  }
        Button("Close All") { NSApplication.shared.terminate(self)  }
      }
      .frame(minHeight: 210)
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(WindowResizability.contentSize)
    .defaultPosition(.topTrailing)
    
    
    // FIXME: need a real Panadapter ID
    
    Window(WindowType.leftSideView.rawValue, id: WindowType.leftSideView.rawValue) {
      LeftSideView(store: Store(initialState: LeftSideFeature.State(panadapterId: "0x99999999".streamId!), reducer: LeftSideFeature()), apiModel: apiModel)
      .toolbar {
        Button("Close") { NSApplication.shared.keyWindow?.close()  }
        Button("Close All") { NSApplication.shared.terminate(self)  }
      }
      .frame(minHeight: 210)
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(WindowResizability.contentSize)
    .defaultPosition(.topLeading)
    
    Settings {
      SettingsView(store: Store(initialState: SettingsFeature.State(), reducer: SettingsFeature()), apiModel: apiModel)
    }
//    Window(WindowType.panadapterView.rawValue, id: WindowType.panadapterView.rawValue) {
//      VStack {
//        Text("\(WindowType.panadapterView.rawValue) goes here")
//      }
//      .toolbar {
//        Button("Close") { NSApplication.shared.keyWindow?.close()  }
//        Button("Close All") { NSApplication.shared.terminate(self)  }
//      }
//      .frame(minWidth: 975)
//      .padding()
//    }
//    .windowStyle(.hiddenTitleBar)
//    .defaultPosition(.topTrailing)

    .commands {
      //remove the "New" menu item
      CommandGroup(replacing: CommandGroupPlacement.newItem) {}
    }
  }
}
