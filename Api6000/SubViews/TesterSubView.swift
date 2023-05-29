//
//  TesterSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/25/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApi

// ----------------------------------------------------------------------------
// MARK: - View

struct TesterSubView: View {
  
  @Dependency(\.apiModel) var apiModel
  @Dependency(\.objectModel) var objectModel
    
  var body: some View {
    if apiModel.radio != nil {
      VStack(alignment: .leading) {
        Divider().background(Color(.green))
        HStack(spacing: 10) {
          
          Text("Api6000Tester").foregroundColor(.green)
            .font(.title)
          
//          HStack(spacing: 5) {
//            Text("Bound to Station")
//            Text("\(objectModel.activeStation ?? "none")").foregroundColor(.secondary)
//          }
          TesterRadioViewView(apiModel: apiModel) }
        }
//      }
    }
  }
}

struct TesterRadioViewView: View {
  @ObservedObject var apiModel: ApiModel
  
  var body: some View {
//    HStack(spacing: 10) {
      
      HStack(spacing: 5) {
        Text("Handle")
        Text(apiModel.connectionHandle?.hex ?? "").foregroundColor(.secondary)
      }
      
      HStack(spacing: 5) {
        Text("Client Id")
        Text("\(apiModel.boundClientId ?? "none")").foregroundColor(.secondary)
      }
//    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct TesterSubView_Previews: PreviewProvider {
  static var previews: some View {
    TesterSubView()
    .frame(minWidth: 1000)
    .padding()
  }
}
