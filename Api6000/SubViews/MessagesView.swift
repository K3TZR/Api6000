//
//  MessageView.swift
//  Api6000Components/ApiViewer/Subviews/ViewerSubViews
//
//  Created by Douglas Adams on 1/8/22.
//

import ComposableArchitecture
import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View

struct MessagesView: View {
  let store: StoreOf<ApiModule>
  @ObservedObject var messagesModel: MessagesModel

  @Namespace var topID
  @Namespace var bottomID

  struct ViewState: Equatable {
    let gotoLast: Bool
    let showTimes: Bool
    let fontSize: CGFloat
    init(state: ApiModule.State) {
      self.gotoLast = state.gotoLast
      self.showTimes = state.showTimes
      self.fontSize = state.fontSize
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
          VStack(alignment: .center) {
            if messagesModel.filteredMessages.count == 0 {
              VStack(alignment: .center) {
                Text("Tcp Messages will be displayed here")
              }
              .frame(minWidth: 900, maxWidth: .infinity, alignment: .center)
              
            } else {
              VStack(alignment: .leading) {
                Text("Top").hidden()
                  .id(topID)
                ForEach(messagesModel.filteredMessages.reversed(), id: \.id) { message in
                  HStack {
                    if viewStore.showTimes { Text(intervalFormat(message.interval)) }
                    Text(message.text)
                  }
                  .foregroundColor( messageColor(message.text) )
                }
                Text("Bottom").hidden()
                  .id(bottomID)
              }
              .frame(minWidth: 900, maxWidth: .infinity, alignment: .leading)
              .textSelection(.enabled)
              
              .onChange(of: viewStore.gotoLast, perform: { _ in
                let id = viewStore.gotoLast ? bottomID : topID
                proxy.scrollTo(id, anchor: viewStore.gotoLast ? .bottomLeading : .topLeading)
              })
              .onChange(of: messagesModel.filteredMessages.count, perform: { _ in
                let id = viewStore.gotoLast ? bottomID : topID
                proxy.scrollTo(id, anchor: viewStore.gotoLast ? .bottomLeading : .topLeading)
              })
            }
          }
          .font(.system(size: viewStore.fontSize, weight: .regular, design: .monospaced))
        }
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct MessagesView_Previews: PreviewProvider {
  
  static var previews: some View {
    MessagesView(
      store: Store(
        initialState: ApiModule.State(),
        reducer: ApiModule()
      )
      ,
      messagesModel: MessagesModel.shared
    )
    .frame(minWidth: 975)
    .padding()
  }
}
