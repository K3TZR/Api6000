//
//  ApiView.swift
//  Api6000
//
//  Created by Douglas Adams on 12/1/21.
//

import ComposableArchitecture
import SwiftUI

import ClientFeature
import LeftSideFeature
import LoginFeature
import LogFeature
import PickerFeature
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

public struct ApiView: View {
  let store: StoreOf<ApiModule>
  
  @Environment(\.openWindow) var openWindow
  
  @Dependency(\.messagesModel) var messagesModel
  @Dependency(\.apiModel) var apiModel
  
  public init(store: StoreOf<ApiModule>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: {$0} ) { viewStore in
      VStack(alignment: .leading) {
        TopButtonsView(store: store)
        SendView(store: store)
        FiltersView(store: store)
        
        Divider().background(Color(.gray))
        
        VSplitView {
          if viewStore.isConnected {
            ObjectsView(store: store, apiModel: apiModel, packet: apiModel.activePacket!, radio: apiModel.radio!)
              .frame(minWidth: 900, maxWidth: .infinity, alignment: .leading)
            Divider().background(Color(.cyan))
            MessagesView(store: store, messagesModel: messagesModel)
              .frame(minWidth: 900, maxWidth: .infinity, alignment: .leading)
            
          } else {
            Text("Radio objects will be displayed here")
              .frame(minWidth: 900, maxWidth: .infinity, minHeight: 200, alignment: .center)
            
            Divider().background(Color(.cyan))
            Text("Tcp Messages will be displayed here")
              .frame(minWidth: 900, maxWidth: .infinity, minHeight: 200, alignment: .center)
          }
        }
        Spacer()
        Divider().background(Color(.gray))
        BottomButtonsView(store: store)
        
        if viewStore.showLeftButtons {
          LeftSideView(store: Store(
            initialState: LeftSideFeature.State(panadapterId: apiModel.activePanadapter?.id, waterfallId: apiModel.activePanadapter?.waterfallId, vertical: false),
            reducer: LeftSideFeature()
          ), apiModel: apiModel)
        }
      }
      
      // ---------- Initialization ----------
      // initialize on first appearance
      .onAppear() {
        if viewStore.openLogWindow { openWindow(id: WindowType.log.rawValue) }
//        if viewStore.openLeftWindow { openWindow(id: WindowType.left.rawValue) }
        if viewStore.openRightWindow { openWindow(id: WindowType.right.rawValue) }
        viewStore.send(.onAppear)
      }
      
      // ---------- Sheet Management ----------
      // alert dialogs
      .alert(
        self.store.scope(state: \.alertState),
        dismiss: .alertDismissed
      )
      
      // Picker sheet
      .sheet(
        isPresented: viewStore.binding(
          get: { $0.pickerState != nil },
          send: ApiModule.Action.picker(.cancelButton)),
        content: {
          IfLetStore(
            store.scope(state: \.pickerState, action: ApiModule.Action.picker),
            then: PickerView.init(store:)
          )
        }
      )
      
      // Login sheet
      .sheet(
        isPresented: viewStore.binding(
          get: { $0.loginState != nil },
          send: ApiModule.Action.login(.cancelButton)),
        content: {
          IfLetStore(
            store.scope(state: \.loginState, action: ApiModule.Action.login),
            then: LoginView.init(store:)
          )
        }
      )
      
      // Client connection sheet
      .sheet(
        isPresented: viewStore.binding(
          get: { $0.clientState != nil },
          send: ApiModule.Action.client(.cancelButton)),
        content: {
          IfLetStore(
            store.scope(state: \.clientState, action: ApiModule.Action.client),
            then: ClientView.init(store:)
          )
        }
      )
      
      // ---------- Window Management ----------
      .toolbar {
        Spacer()
        Button("Log") { openWindow(id: WindowType.log.rawValue) }
        Button("Pan") { openWindow(id: WindowType.panadapter.rawValue) }
        Button("Left") { openWindow(id: WindowType.left.rawValue) }
        Button("Right") { openWindow(id: WindowType.right.rawValue) }
      }
      
      .onDisappear {
        viewStore.send(.closeAllWindows)
      }
      
      .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { notification in
        // observe openings
        if let window = notification.object as? NSWindow {
          switch window.identifier?.rawValue {
          case WindowType.log.rawValue: viewStore.send(.set(\.openLogWindow, true))
          case WindowType.left.rawValue: viewStore.send(.set(\.openLeftWindow, true))
          case WindowType.right.rawValue: viewStore.send(.set(\.openRightWindow, true))
          default:  break
          }
        }
      }
      .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
        // observe closings unless the entire app is closing
        if !viewStore.isClosing, let window = notification.object as? NSWindow {
          switch window.identifier?.rawValue {
          case WindowType.log.rawValue: viewStore.send(.set(\.openLogWindow, false))
          case WindowType.left.rawValue: viewStore.send(.set(\.openLeftWindow, false))
          case WindowType.right.rawValue: viewStore.send(.set(\.openRightWindow, false))
          default:  break
          }
        }
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - SubView(s)

private struct TopButtonsView: View {
  let store: StoreOf<ApiModule>
  
  struct ViewState: Equatable {
    let isGui: Bool
    let showTimes: Bool
    let showPings: Bool
    let rxAudio: Bool
    let txAudio: Bool
    let localEnabled: Bool
    let smartlinkEnabled: Bool
    let loginRequired: Bool
    let useDefault: Bool
    let isConnected: Bool
    
    init(state: ApiModule.State) {
      self.isGui = state.isGui
      self.showTimes = state.showTimes
      self.showPings = state.showPings
      self.rxAudio = state.rxAudio
      self.txAudio = state.txAudio
      self.localEnabled = state.localEnabled
      self.smartlinkEnabled = state.smartlinkEnabled
      self.loginRequired = state.loginRequired
      self.useDefault = state.useDefault
      self.isConnected = state.isConnected
    }
  }
  
  public  var body: some View {
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      HStack(spacing: 20) {
        Button(viewStore.isConnected ? "Stop" : "Start") {
          viewStore.send(.startStopButton)
        }
        .keyboardShortcut(viewStore.isConnected ? .cancelAction : .defaultAction)
        
        HStack(spacing: 10) {
          Toggle("Gui", isOn: viewStore.binding(get: \.isGui, send: .toggle(\.isGui)))
            .frame(width: 60)
            .disabled( viewStore.isConnected )
          Group {
            Toggle("Show Times", isOn: viewStore.binding(get: \.showTimes, send: .toggle(\.showTimes)))
            Toggle("Show Pings", isOn: viewStore.binding(get: \.showPings, send: .toggle(\.showPings)))
          }
          .frame(width: 100)
        }
        
        Spacer()
        ControlGroup {
          Toggle(isOn: viewStore.binding(get: \.rxAudio, send: .toggle(\.rxAudio) )) {
            Text("Rx Audio") }
          Toggle(isOn: viewStore.binding(get: \.txAudio, send: .toggle(\.txAudio) )) {
            Text("Tx Audio") }
        }
        .frame(width: 130)
        
        Spacer()
        ControlGroup {
          Toggle(isOn: viewStore.binding(get: \.localEnabled, send: .toggle(\.localEnabled))) {
            Text("Local") }
          Toggle(isOn: viewStore.binding(get: \.smartlinkEnabled, send: .toggle(\.smartlinkEnabled) )) {
            Text("Smartlink") }
        }
        .disabled( viewStore.isConnected )
        .frame(width: 130)
        
        Spacer()
        Toggle("Smartlink Login", isOn: viewStore.binding(get: \.loginRequired, send: .toggle(\.loginRequired)))
          .disabled( viewStore.isConnected || viewStore.smartlinkEnabled == false )
        Toggle("Use Default", isOn: viewStore.binding(get: \.useDefault, send: .toggle(\.useDefault)))
          .disabled( viewStore.isConnected )
      }
    }
  }
}

private struct BottomButtonsView: View {
  let store: StoreOf<ApiModule>
  
  struct ViewState: Equatable {
    let alertOnError: Bool
    let clearOnStart: Bool
    let clearOnStop: Bool
    let fontSize: CGFloat
    let gotoLast: Bool
    let showLeftButtons: Bool
    init(state: ApiModule.State) {
      self.alertOnError = state.alertOnError
      self.clearOnStart = state.clearOnStart
      self.clearOnStop = state.clearOnStop
      self.fontSize = state.fontSize
      self.gotoLast = state.gotoLast
      self.showLeftButtons = state.showLeftButtons
    }
  }
  
  var body: some View {
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      HStack {
        Stepper("Font Size",
                value: viewStore.binding(
                  get: \.fontSize,
                  send: { value in .fontSizeStepper(value) }),
                in: 8...12)
        Text(String(format: "%2.0f", viewStore.fontSize)).frame(alignment: .leading)
        
        Spacer()
        HStack {
          Text("Go to \(viewStore.gotoLast ? "Last" : "First")")
          Image(systemName: viewStore.gotoLast ? "arrow.up.square" : "arrow.down.square").font(.title)
            .onTapGesture { viewStore.send(.toggle(\.gotoLast)) }
        }
        Spacer()
        
        HStack {
          Button("Save") { viewStore.send(.saveButton) }
        }
        Spacer()
        
        HStack(spacing: 30) {
          Toggle("Alert on Error", isOn: viewStore.binding(get: \.alertOnError, send: .toggle(\.alertOnError)))
          Toggle("Clear on Start", isOn: viewStore.binding(get: \.clearOnStart, send: .toggle(\.clearOnStart)))
          Toggle("Clear on Stop", isOn: viewStore.binding(get: \.clearOnStop, send: .toggle(\.clearOnStop)))
          Button("Clear Now") { viewStore.send(.clearNowButton)}
          Image(systemName: "rectangle.bottomthird.inset.filled")
            .onTapGesture { viewStore.send(.toggle(\.showLeftButtons)) }
        }
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct ApiView_Previews: PreviewProvider {
  static var previews: some View {
    ApiView(
      store: Store(
        initialState: ApiModule.State(),
        reducer: ApiModule()
      )
    )
    .frame(minWidth: 975, minHeight: 600)
    .padding()
  }
}

private func closeWindow(_ id: String) {
  for window in NSApp.windows where window.identifier?.rawValue == id {
    log("Api6000: \(window.identifier!.rawValue) window closed", .debug, #function, #file, #line)
    window.close()
  }
}
