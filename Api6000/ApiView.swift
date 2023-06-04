//
//  ApiView.swift
//  Api6000
//
//  Created by Douglas Adams on 12/1/21.
//

import ComposableArchitecture
import SwiftUI

import ClientDialog
import LoginDialog
import LogView
import MessagesView
import ObjectsView
import RadioPicker
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

public struct ApiView: View {
  let store: StoreOf<ApiModule>
  
  @Environment(\.openWindow) var openWindow
  
  @AppStorage("openControlWindow") var openControlWindow = false
  @AppStorage("openLogWindow") var openLogWindow = false
  @AppStorage("openPanafallsWindow") var openPanafallsWindow = false
  
  @Dependency(\.apiModel) var apiModel
  @Dependency(\.messagesModel) var messagesModel
  @Dependency(\.objectModel) var objectModel
  @Dependency(\.streamModel) var streamModel

  public init(store: StoreOf<ApiModule>) {
    self.store = store
  }
  
  struct ViewState: Equatable {
    let pickerState: PickerFeature.State?
    let loginState: LoginFeature.State?
    let clientState: ClientFeature.State?
    let isClosing: Bool
    init(state: ApiModule.State) {
      pickerState = state.pickerState
      loginState = state.loginState
      clientState = state.clientState
      isClosing = state.isClosing
    }
  }

  public var body: some View {
    WithViewStore(self.store, observe: ViewState.init ) { viewStore in
      VStack(alignment: .leading) {
        TopButtonsView(store: store)
        SendView(store: store)
        
        Divider()
          .frame(height: 4)
          .background(Color(.gray))
        
        VSplitView {
          ObjectsView(store: Store(initialState: ObjectsFeature.State(), reducer: ObjectsFeature()),
                      apiModel: apiModel,
                      objectModel: objectModel,
                      streamModel: streamModel)
          .frame(maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
          
          Divider()
            .frame(height: 4)
            .background(Color(.gray))

          MessagesView(store: Store(initialState: MessagesFeature.State(), reducer: MessagesFeature()),
                       messagesModel: messagesModel)
          .frame(maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
        }
        Spacer()
        Divider()
          .frame(height: 4)
          .background(Color(.gray))
        BottomButtonsView(store: store)
      }
      
      // ---------- Initialization ----------
      // initialize on first appearance
      .onAppear() {
        if openLogWindow { openWindow(id: WindowType.log.rawValue) }
        if openPanafallsWindow { openWindow(id: WindowType.panafalls.rawValue) }
        if openControlWindow { openWindow(id: WindowType.control.rawValue) }
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
//      .toolbar {
//        Button("Log") { openWindow(id: WindowType.log.rawValue) }
//        Button("Pan") { openWindow(id: WindowType.panafalls.rawValue) }
//        Button("Control") { openWindow(id: WindowType.control.rawValue) }
//      }
      
      .onDisappear {
        viewStore.send(.closeAllWindows)
      }
      
//      .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { notification in
//        // observe openings of secondary windows
//        if let window = notification.object as? NSWindow {
//          switch window.identifier?.rawValue {
//          case WindowType.log.rawValue: openLogWindow = true
//          case WindowType.panafalls.rawValue: openPanafallsWindow = true
//          case WindowType.control.rawValue: openControlWindow = true
//          default:  break
//          }
//        }
//      }
//      .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
//        // observe closings of secondary windows (unless the entire app is closing)
//        if !viewStore.isClosing, let window = notification.object as? NSWindow {
//          switch window.identifier?.rawValue {
//          case WindowType.log.rawValue: openLogWindow = false
//          case WindowType.panafalls.rawValue: openPanafallsWindow = false
//          case WindowType.control.rawValue: openControlWindow = false
//          default:  break
//          }
//        }
//      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - SubView(s)

private struct TopButtonsView: View {
  let store: StoreOf<ApiModule>
  
  @AppStorage("localEnabled") var localEnabled = false
  @AppStorage("loginRequired") var loginRequired = false
  @AppStorage("isGui") var isGui = false
  @AppStorage("rxAudio") var rxAudio = false
  @AppStorage("showPings") var showPings = false
  @AppStorage("showTimes") var showTimes = false
  @AppStorage("smartlinkEnabled") var smartlinkEnabled = false
  @AppStorage("txAudio") var txAudio = false
  @AppStorage("useDefault") var useDefault = false

  struct ViewState: Equatable {
    let isConnected: Bool
    let startStopDisabled: Bool
    
    init(state: ApiModule.State) {
      self.isConnected = state.isConnected
      self.startStopDisabled = state.startStopDisabled
    }
  }
  
  public  var body: some View {
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      HStack(spacing: 20) {
        Button(viewStore.isConnected ? "Stop" : "Start") {
          viewStore.send(.startStop)
        }
        .disabled(viewStore.startStopDisabled)
        .keyboardShortcut(viewStore.isConnected ? .cancelAction : .defaultAction)
        
        HStack(spacing: 10) {
          Toggle("Gui", isOn: $isGui)
            .frame(width: 60)
            .disabled( viewStore.isConnected )
          Group {
            Toggle("Show Times", isOn: $showTimes)
            Toggle("Show Pings", isOn: $showPings)
          }
          .frame(width: 100)
        }
        
        Spacer()
        ControlGroup {
          Toggle(isOn: viewStore.binding(get: {_ in rxAudio}, send: .rxAudio) ) {
            Text("Rx Audio") }
          Toggle(isOn: viewStore.binding(get: {_ in txAudio}, send: .txAudio) ) {
            Text("Tx Audio") }
        }
        .frame(width: 130)
        
        Spacer()
        ControlGroup {
          Toggle(isOn: $localEnabled) {
            Text("Local") }
          Toggle(isOn: $smartlinkEnabled) {
            Text("Smartlink") }
        }
        .disabled( viewStore.isConnected )
        .frame(width: 130)
        
        Spacer()
        Toggle("Smartlink Login", isOn: $loginRequired)
          .disabled( viewStore.isConnected || smartlinkEnabled == false )
        Toggle("Use Default", isOn: $useDefault)
          .disabled( viewStore.isConnected )
      }
    }
  }
}

private struct SendView: View {
  let store: StoreOf<ApiModule>
  
  @AppStorage("clearOnSend") var clearOnSend = false
  
  struct ViewState: Equatable {
    let commandToSend: String
    let isConnected: Bool
    init(state: ApiModule.State) {
      self.commandToSend = state.commandToSend
      self.isConnected = state.isConnected
    }
  }

  var body: some View {

    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      HStack(spacing: 25) {
        Group {
          Button("Send") { viewStore.send(.commandSend) }
          .keyboardShortcut(.defaultAction)

          HStack(spacing: 0) {
            Image(systemName: "x.circle")
              .onTapGesture {
                viewStore.send(.commandClear)
              }
            
            Stepper("", onIncrement: {
              viewStore.send(.commandPrevious)
            }, onDecrement: {
              viewStore.send(.commandNext)
            })
            
            TextField("Command to send", text: viewStore.binding(
              get: \.commandToSend,
              send: {.commandText($0)} ))
          }
        }
        .disabled(viewStore.isConnected == false)

        Spacer()
        Toggle("Clear on Send", isOn: $clearOnSend)
      }
    }
  }
}

private struct BottomButtonsView: View {
  let store: StoreOf<ApiModule>
  
  @AppStorage("alertOnError") var alertOnError = false
  @AppStorage("clearOnStart") var clearOnStart = false
  @AppStorage("clearOnStop") var clearOnStop = false
  @AppStorage("fontSize") var fontSize: Double = 12
  @AppStorage("gotoLast") public var gotoLast = true

  struct ViewState: Equatable {
    init(state: ApiModule.State) {
    }
  }

  var body: some View {
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      HStack {
        Stepper("Font Size",
                value: $fontSize,
                in: 8...12)
        Text(String(format: "%2.0f", fontSize)).frame(alignment: .leading)
        
        Spacer()
        HStack {
          Text("Go to \(gotoLast ? "Last" : "First")")
          Image(systemName: gotoLast ? "arrow.up.square" : "arrow.down.square").font(.title)
            .onTapGesture { gotoLast.toggle() }
        }
        Spacer()
        
        HStack {
          Button("Save") { viewStore.send(.messagesSave) }
        }
        Spacer()
        
        HStack(spacing: 30) {
          Toggle("Alert on Error", isOn: $alertOnError)
          Toggle("Clear on Start", isOn: $clearOnStart)
          Toggle("Clear on Stop", isOn: $clearOnStop)
          Button("Clear Now") { viewStore.send(.messagesClear)}
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
//    .frame(minWidth: 975, minHeight: 600)
    .padding()
  }
}
