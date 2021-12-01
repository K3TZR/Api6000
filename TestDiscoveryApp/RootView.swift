//
//  RootView.swift
//  TestDiscoveryApp
//
//  Created by Douglas Adams on 11/20/21.
//

import SwiftUI
import ComposableArchitecture
import Picker
import LogViewer

struct RootView: View {
  let store: Store<RootState, RootAction>
  
  @State var activeRadio = false
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      
//      if viewStore.rootViewType == .apiTester {
        
//        ApiTesterView(store: store)
//      } else {
        LogViewer(
          store: Store(
            initialState: LogState(),
            reducer: logReducer,
            environment: LogEnvironment()
          )
        )
//      }
    }
  }
}

struct TopButtonsView: View {
  let store: Store<RootState, RootAction>
  
  @State var smartlinkIsLoggedIn = false
  @State var smartlinkIsEnabled = false
  
  var body: some View {
    
    WithViewStore(self.store) { viewStore in
      HStack(spacing: 30) {
        Button(viewStore.connectedPacket == nil ? "Start" : "Stop") {
          viewStore.send(.buttonTapped(.startStop))
        }
        .keyboardShortcut(viewStore.connectedPacket == nil ? .defaultAction : .cancelAction)
        .help("Using the Default connection type")
        
        HStack(spacing: 20) {
          Toggle("Gui", isOn: viewStore.binding(get: \.isGui, send: .buttonTapped(.gui)))
          Toggle("Times", isOn: viewStore.binding(get: \.showTimes, send: .buttonTapped(.times)))
          Toggle("Pings", isOn: viewStore.binding(get: \.showPings, send: .buttonTapped(.pings)))
          Toggle("Replies", isOn: viewStore.binding(get: \.showReplies, send: .buttonTapped(.replies)))
          Toggle("Buttons", isOn: viewStore.binding(get: \.showButtons, send: .buttonTapped(.buttons)))
        }
        
        Spacer()
        HStack(spacing: 10) {
          Text("SmartLink")
          Button(smartlinkIsLoggedIn ? "Logout" : "Login") { viewStore.send(.buttonTapped(.smartlink)) }
          
          Button("Status") { viewStore.send(.buttonTapped(.status)) }
        }.disabled(viewStore.connectedPacket != nil)
        
        Spacer()
        Button("Clear Default") { viewStore.send(.buttonTapped(.clearDefault)) }
      }
    }
  }
}




struct ApiTesterView: View {
  let store: Store<RootState, RootAction>
  
  var body: some View {
        
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading) {
        TopButtonsView(store: store)
        //        SendView(tester: tester, radioManager: radioManager)
        //        FiltersView(tester: tester)
        
        Divider().background(Color(.red))
        
        VSplitView {
          Text("----- Objects go here -----").frame(minWidth: 950, minHeight: 100, idealHeight: 200, maxHeight: 300, alignment: .leading)
          Divider().background(Color(.green))
          Text("----- Messages go here -----").frame(minWidth: 950, minHeight: 100, idealHeight: 200, maxHeight: 300, alignment: .leading)
        }
        Spacer()
        Divider().background(Color(.red))
        BottomButtonsView(store: store)
      }
      .toolbar {
        Button("Log Viewer") { viewStore.send(.buttonTapped(.logViewer)) }
      }
      .sheet(
        isPresented: viewStore.binding(
          get: { $0.showPicker },
          send: RootAction.sheetClosed),
        content: {
          IfLetStore(
            store.scope(state: \.pickerState, action: RootAction.pickerAction),
            then: PickerView.init(store:)
          )
        }
      ).onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}


//struct LogViewerView: View {
//  let store: Store<RootState, RootAction>
//
//  var body: some View {
//
//    WithViewStore(self.store) { viewStore in
//      Text("Log Viewer")
//        .toolbar {
//          Button("Api Tester") { viewStore.send(.buttonTapped(.apiTester)) }
//        }
//
//    }
//  }
//}





struct BottomButtonsView: View {
  let store: Store<RootState, RootAction>
  
  @State var fontSize: CGFloat = 12
  
  var body: some View {
    
    WithViewStore(self.store) { viewStore in
      HStack(spacing: 40) {
        Stepper("Font Size", value: $fontSize, in: 8...16)
        Text(String(format: "%2.0f", fontSize)).frame(alignment: .leading)
        Spacer()
        Toggle("Clear on Connect", isOn: viewStore.binding(get: \.clearOnConnect, send: .buttonTapped(.clearOnConnect)))
        Toggle("Clear on Disconnect", isOn: viewStore.binding(get: \.clearOnDisconnect, send: .buttonTapped(.clearOnDisconnect)))
        Button("Clear Now") { viewStore.send(.buttonTapped(.clearNow))}
      }
    }
  }
}

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView(
      store: Store(
        initialState: RootState(),
        reducer: rootReducer,
        environment: RootEnvironment()
      )
    )
  }
}

struct TopButtonsView_Previews: PreviewProvider {
  static var previews: some View {
    TopButtonsView(
      store: Store(
        initialState: RootState(),
        reducer: rootReducer,
        environment: RootEnvironment()
      )
    )
  }
}

struct BottomButtonsView_Previews: PreviewProvider {
  static var previews: some View {
    BottomButtonsView(
      store: Store(
        initialState: RootState(),
        reducer: rootReducer,
        environment: RootEnvironment()
      )
    )
  }
}
