//
//  ObjectsSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/8/22.
//

import ComposableArchitecture
import SwiftUI

import Listener
import FlexApi
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

struct ObjectsSubView: View {
  let store: StoreOf<ApiModule>
  @ObservedObject var apiModel: ApiModel
  @ObservedObject var objectModel: ObjectModel

  @Dependency(\.listener) var listener
  
  @AppStorage("fontSize") var fontSize: Double = 12

//  struct ViewState: Equatable {
//    let isGui: Bool
//    let fontSize: CGFloat
//    let isStopped: Bool
//    init(state: ApiModule.State) {
//      self.isGui = state.isGui
//      self.fontSize = state.fontSize
//      self.isStopped = state.isStopped
//    }
//  }

  var body: some View {
    
    WithViewStore(self.store, observe: {$0} ) { viewStore in
        ScrollView([.horizontal, .vertical]) {
          if apiModel.activePacket == nil {
            Text("Objects will be displayed here")
          } else {
            VStack(alignment: .leading) {
              RadioSubView(objectModel: objectModel, packet: apiModel.activePacket!, radio: apiModel.radio!)
              GuiClientSubView(store: store, apiModel: apiModel, packet: apiModel.activePacket!)
              //          if viewStore.isGui == false { TesterView() }
            }
          }
        }
        .font(.system(size: fontSize, weight: .regular, design: .monospaced))
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct ObjectsSubView_Previews: PreviewProvider {

  static var previews: some View {
    ObjectsSubView(
      store:
        Store(
          initialState: ApiModule.State(),
          reducer: ApiModule()), apiModel: ApiModel(),
      objectModel: ObjectModel())
    .frame(minWidth: 975)
    .padding()
  }
}
