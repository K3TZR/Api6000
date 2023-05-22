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
import RadioPicker
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

public struct ApiView: View {
  let store: StoreOf<ApiModule>
  
  @Environment(\.openWindow) var openWindow
  
  @AppStorage("openControlWindow") var openControlWindow = false
  @AppStorage("openLogWindow") var openLogWindow = false
  @AppStorage("openPanadapterWindow") var openPanadapterWindow = false
  
  @Dependency(\.apiModel) var apiModel
  @Dependency(\.messagesModel) var messagesModel
  @Dependency(\.objectModel) var objectModel
  
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
          ObjectsSubView(store: store, apiModel: apiModel, objectModel: objectModel)
          Divider().background(Color(.cyan))
          MessagesSubView(store: store, messagesModel: messagesModel)
        }
        Spacer()
        Divider().background(Color(.gray))
        BottomButtonsView(store: store)
      }
      
      // ---------- Initialization ----------
      // initialize on first appearance
      .onAppear() {
        if openLogWindow { openWindow(id: WindowType.log.rawValue) }
        if openPanadapterWindow { openWindow(id: WindowType.panadapter.rawValue) }
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
      .toolbar {
        Button("Log") { openWindow(id: WindowType.log.rawValue) }
        Button("Pan") { openWindow(id: WindowType.panadapter.rawValue) }
        Button("Control") { openWindow(id: WindowType.control.rawValue) }
      }
      
      .onDisappear {
        viewStore.send(.closeAllWindows)
      }
      
      .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { notification in
        // observe openings
        if let window = notification.object as? NSWindow {
          switch window.identifier?.rawValue {
          case WindowType.log.rawValue: openLogWindow = true
          case WindowType.panadapter.rawValue: openPanadapterWindow = true
          case WindowType.control.rawValue: openControlWindow = true
          default:  break
          }
        }
      }
      .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
        // observe closings unless the entire app is closing
        if !viewStore.isClosing, let window = notification.object as? NSWindow {
          switch window.identifier?.rawValue {
          case WindowType.log.rawValue: openLogWindow = false
          case WindowType.panadapter.rawValue: openPanadapterWindow = false
          case WindowType.control.rawValue: openControlWindow = false
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
  
  @AppStorage("showPings") var showPings = false
  @AppStorage("showTimes") var showTimes = false
  @AppStorage("useDefault") var useDefault = false
  @AppStorage("smartlinkEnabled") var smartlinkEnabled = false
  @AppStorage("localEnabled") var localEnabled = false
  @AppStorage("isGui") var isGui = false
  @AppStorage("rxAudio") var rxAudio = false

  struct ViewState: Equatable {
    let rxAudio: Bool
    let txAudio: Bool
    let loginRequired: Bool
    let isConnected: Bool
    let startStopDisabled: Bool
    
    init(state: ApiModule.State) {
      self.rxAudio = state.rxAudio
      self.txAudio = state.txAudio
      self.loginRequired = state.loginRequired
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
          Toggle(isOn: viewStore.binding(get: \.rxAudio, send: .rxAudio) ) {
            Text("Rx Audio") }
          Toggle(isOn: viewStore.binding(get: \.txAudio, send: .txAudio) ) {
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
        Toggle("Smartlink Login", isOn: viewStore.binding(get: \.loginRequired, send: .loginRequired))
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

private struct FiltersView: View {
  let store: StoreOf<ApiModule>
  
  var body: some View {
    HStack(spacing: 100) {
      FilterObjectsView(store: store)
      FilterMessagesView(store: store)
    }
  }
}

private struct FilterObjectsView: View {
  let store: StoreOf<ApiModule>
  
  @AppStorage("objectFilter") var objectFilter = ObjectFilter.core.rawValue
  
  var body: some View {
    
    WithViewStore(self.store, observe: {$0} ) { viewStore in
      HStack {
        Picker("Show Radio Objects of type", selection: $objectFilter ) {
            ForEach(ObjectFilter.allCases, id: \.self) {
              Text($0.rawValue).tag($0.rawValue)
            }
          }
          .frame(width: 300)
      }
    }
    .pickerStyle(MenuPickerStyle())
  }
}

private struct FilterMessagesView: View {
  let store: StoreOf<ApiModule>

  @AppStorage("messageFilter") var messageFilter = MessageFilter.all.rawValue
  @AppStorage("messageFilterText") var messageFilterText = ""

  var body: some View {

    WithViewStore(self.store, observe: {$0}) { viewStore in
      HStack {
        Picker("Show Tcp Messages of type", selection: viewStore.binding(
          get: {_ in messageFilter },
          send: { value in .messagesFilter(value) } )) {
            ForEach(MessageFilter.allCases, id: \.self) {
              Text($0.rawValue).tag($0.rawValue)
            }
          }
          .frame(width: 300)
        Image(systemName: "x.circle")
          .onTapGesture {
            viewStore.send(.messagesFilterText(""))
          }
        TextField("filter text", text: viewStore.binding(
          get: {_ in messageFilterText },
          send: { ApiModule.Action.messagesFilterText($0) }))
      }
    }
    .pickerStyle(MenuPickerStyle())
  }
}

private struct BottomButtonsView: View {
  let store: StoreOf<ApiModule>
  
  @AppStorage("alertOnError") var alertOnError = false
  @AppStorage("clearOnStart") var clearOnStart = false
  @AppStorage("clearOnStop") var clearOnStop = false
  @AppStorage("fontSize") var fontSize: Double = 12

  struct ViewState: Equatable {
    let gotoLast: Bool
    init(state: ApiModule.State) {
      self.gotoLast = state.gotoLast
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
          Text("Go to \(viewStore.gotoLast ? "Last" : "First")")
          Image(systemName: viewStore.gotoLast ? "arrow.up.square" : "arrow.down.square").font(.title)
            .onTapGesture { viewStore.send(.gotoLast) }
        }
        Spacer()
        
        HStack {
          Button("Save") { viewStore.send(.messagesSave) }
        }
        Spacer()
        
        HStack(spacing: 30) {
          //          Toggle("Alert on Error", isOn: viewStore.binding(get: \.alertOnError, send: .stateToggle(\.alertOnError)))
          Toggle("Alert on Error", isOn: $alertOnError)
          Toggle("Clear on Start", isOn: $clearOnStart)
          Toggle("Clear on Stop", isOn: $clearOnStop)
          Button("Clear Now") { viewStore.send(.messagesClear)}
          //          Image(systemName: "rectangle.bottomthird.inset.filled")
          //            .onTapGesture { viewStore.send(.stateToggle(\.showLeftButtons)) }
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
