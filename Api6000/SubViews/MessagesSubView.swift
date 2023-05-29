//
//  MessageSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/8/22.
//

import ComposableArchitecture
import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View

struct MessagesSubView: View {
  let store: StoreOf<ApiModule>
  @ObservedObject var messagesModel: MessagesModel
  
  @AppStorage("showTimes") var showTimes = false
  @AppStorage("fontSize") var fontSize: Double = 12
  
  @Namespace var topID
  @Namespace var bottomID
  
  struct ViewState: Equatable {
    let gotoLast: Bool
    init(state: ApiModule.State) {
      self.gotoLast = state.gotoLast
    }
  }
  
  func messageColor(_ text: String) -> Color {
    if text.prefix(1) == "C" { return Color(.systemGreen) }                         // Commands
    if text.prefix(1) == "R" && text.contains("|0|") { return Color(.systemGray) }  // Replies no error
    if text.prefix(1) == "R" && !text.contains("|0|") { return Color(.systemRed) }  // Replies w/error
    if text.prefix(2) == "S0" { return Color(.systemOrange) }                       // S0
    
    return Color(.textColor)
  }
  
  func intervalFormat(_ interval: Double) -> String {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 6
    formatter.positiveFormat = " * ##0.000000"
    return formatter.string(from: NSNumber(value: interval))!
  }
  
  var body: some View {
    
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      ScrollViewReader { proxy in
        ScrollView([.vertical, .horizontal]) {
          VStack(alignment: .leading) {
            if messagesModel.filteredMessages.count == 0 {
              Text("TCP Message will be displayed here")
            } else {
              Text("Top").hidden()
                .id(topID)
              ForEach(messagesModel.filteredMessages.reversed(), id: \.id) { message in
                HStack {
                  if showTimes { Text(intervalFormat(message.interval)) }
                  Text(message.text)
                }
                .foregroundColor( messageColor(message.text) )
              }
              Text("Bottom").hidden()
                .id(bottomID)
            }
          }
          .textSelection(.enabled)
          
          .onChange(of: viewStore.gotoLast, perform: { _ in
            let id = viewStore.gotoLast ? bottomID : topID
            proxy.scrollTo(id, anchor: viewStore.gotoLast ? .bottomLeading : .topLeading)
          })
          .onChange(of: messagesModel.filteredMessages.count, perform: { _ in
            let id = viewStore.gotoLast ? bottomID : topID
            proxy.scrollTo(id, anchor: viewStore.gotoLast ? .bottomLeading : .topLeading)
          })
          .font(.system(size: fontSize, weight: .regular, design: .monospaced))
        }
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct MessagesSubView_Previews: PreviewProvider {
  
  static var previews: some View {
    MessagesSubView(
      store: Store(
        initialState: ApiModule.State(),
        reducer: ApiModule()
      )
      ,
      messagesModel: MessagesModel()
    )
    .frame(minWidth: 975)
    .padding()
  }
}
