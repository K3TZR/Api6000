//
//  Api6000App.swift
//  Api6000
//
//  Created by Douglas Adams on 11/28/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApi
import LogView
import Panafalls
import Panafall
import Panadapter
import SidePanel
import SettingsPanel
import Shared

enum WindowType: String {
  case log = "Log"
  case panafalls = "Panafalls"
  case control = "Controls"
  case settings = "Settings"
}

final class AppDelegate: NSObject, NSApplicationDelegate {
  public var isClosing = false
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    // disable tab view
    NSWindow.allowsAutomaticWindowTabbing = false
    // disable restoring windows
    UserDefaults.standard.register(defaults: ["NSQuitAlwaysKeepsWindows" : false])
  }
    
  func applicationWillTerminate(_ notification: Notification) {
    isClosing = true
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

  @AppStorage("leftSideIsOpen") var leftSideIsOpen = false
  @AppStorage("rightSideIsOpen") var rightSideIsOpen = false
  
  @Environment(\.openWindow) var openWindow

  @AppStorage("openControlWindow") var controlWindowIsOpen = false
  @AppStorage("openLogWindow") var openLogWindow = false
  @AppStorage("openPanafallsWindow") var openPanafallsWindow = false

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
      
      .toolbar{
        ToolbarItem(placement: .navigation) {
          Button {
            leftSideIsOpen.toggle()
          } label: {
            Image(systemName: "sidebar.squares.left")
              .font(.system(size: 20))
          }
          .keyboardShortcut("l", modifiers: [.control, .command])
        }
        
        ToolbarItem {
          Spacer()
        }
        
        ToolbarItemGroup {
          Button("Log") { openWindow(id: WindowType.log.rawValue) }
          Button("Pan") { openWindow(id: WindowType.panafalls.rawValue) }
//          Button("Control") { openWindow(id: WindowType.control.rawValue) }
        }
        
        ToolbarItem {
          Spacer()
        }
        
        ToolbarItem {
          Button {
//            rightWidth = rightWidth == 100 ? 0 : 100
            if controlWindowIsOpen {
              closeWindow(WindowType.control.rawValue)
            } else {
              openWindow(id: WindowType.control.rawValue)
            }
          } label: {
            Image(systemName: "sidebar.squares.right")
              .font(.system(size: 20))
          }
        }
      }
      
      .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { notification in
        // observe openings of secondary windows
        if let window = notification.object as? NSWindow {
          switch window.identifier?.rawValue {
          case WindowType.log.rawValue: openLogWindow = true
          case WindowType.panafalls.rawValue: openPanafallsWindow = true
          case WindowType.control.rawValue: controlWindowIsOpen = true
          default:  break
          }
        }
      }
      .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
        // observe closings of secondary windows (unless the entire app is closing)
//        if !viewStore.isClosing, let window = notification.object as? NSWindow {
        if !appDelegate.isClosing, let window = notification.object as? NSWindow {
          switch window.identifier?.rawValue {
          case WindowType.log.rawValue: openLogWindow = false
          case WindowType.panafalls.rawValue: openPanafallsWindow = false
          case WindowType.control.rawValue: controlWindowIsOpen = false
          default:  break
          }
        }
      }

    }

    // Log window
    Window(WindowType.log.rawValue, id: WindowType.log.rawValue) {
      LogView(store: Store(initialState: LogFeature.State(), reducer: LogFeature()) )
      .frame(minWidth: 975)
    }
    .windowStyle(.hiddenTitleBar)
    .defaultPosition(.bottomTrailing)

    // SideControl window
    Window(WindowType.control.rawValue, id: WindowType.control.rawValue) {
      SideControlView(store: Store(initialState: SideControlFeature.State(), reducer: SideControlFeature()), apiModel: apiModel, objectModel: objectModel)
      .frame(minHeight: 210)
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(WindowResizability.contentSize)
    .defaultPosition(.topTrailing)
            
    // Panafalls window
    Window(WindowType.panafalls.rawValue, id: WindowType.panafalls.rawValue) {
      PanafallsView(store: Store(initialState: PanafallsFeature.State(), reducer: PanafallsFeature()),
                    objectModel: objectModel)
    }

    .windowStyle(.hiddenTitleBar)
    .windowResizability(WindowResizability.contentSize)
    .defaultPosition(.center)

    // Settings window
    Settings {
      SettingsView(store: Store(initialState: SettingsFeature.State(), reducer: SettingsFeature()), objectModel: objectModel, apiModel: apiModel)
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(WindowResizability.contentSize)
    .defaultPosition(.bottomLeading)

    .commands {
      //remove the "New" menu item
      CommandGroup(replacing: CommandGroupPlacement.newItem) {}
    }
  }

  private func closeWindow(_ id: String) {
    for window in NSApp.windows where window.identifier?.rawValue == id {
      window.close()
    }
  }
}
