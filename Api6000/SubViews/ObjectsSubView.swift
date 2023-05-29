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
  @ObservedObject var streamModel: StreamModel

  @Dependency(\.listener) var listener
  
  @AppStorage("fontSize") var fontSize: Double = 12
  @AppStorage("isGui") var isGui = true

  var body: some View {
    
    WithViewStore(self.store, observe: {$0} ) { viewStore in
      ScrollView([.horizontal, .vertical]) {
        VStack(alignment: .leading) {
          if apiModel.radio == nil {
            Text("Objects will be displayed here")
          } else {
            RadioSubView(apiModel: apiModel, objectModel: objectModel, streamModel: streamModel, radio: apiModel.radio!)
            GuiClientSubView(store: store, apiModel: apiModel)
            if isGui == false { TesterSubView() }
          }
        }
      }.font(.system(size: fontSize, weight: .regular, design: .monospaced))
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
      objectModel: ObjectModel(), streamModel: StreamModel())
    .frame(minWidth: 975)
    .padding()
  }
}
