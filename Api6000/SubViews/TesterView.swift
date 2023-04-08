//
//  NonGuiClientView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/25/22.
//

import ComposableArchitecture
import SwiftUI

import Objects

// ----------------------------------------------------------------------------
// MARK: - View

struct TesterView: View {
  
  @Dependency(\.apiModel) var apiModel
    
  var body: some View {
    if apiModel.radio != nil {
      VStack(alignment: .leading) {
        Divider().background(Color(.green))
        HStack(spacing: 10) {
          
          HStack {
            Text("NonGui").foregroundColor(.green)
              .font(.title)
            Text("Api6000Tester").foregroundColor(.green)
          }

          HStack(spacing: 5) {
            Text("Bound to Station")
            Text("\(apiModel.activeStation ?? "none")").foregroundColor(.secondary)
          }
          if apiModel.radio != nil { TesterRadioViewView(radio: apiModel.radio!) }
        }
      }
    }
  }
}

struct TesterRadioViewView: View {
  @ObservedObject var radio: Radio
  
  @Dependency(\.apiModel) var apiModel

  var body: some View {
    HStack(spacing: 10) {
      
      HStack(spacing: 5) {
        Text("Handle")
        Text(apiModel.connectionHandle?.hex ?? "").foregroundColor(.secondary)
      }
      
      HStack(spacing: 5) {
        Text("Client Id")
        Text("\(radio.boundClientId ?? "none")").foregroundColor(.secondary)
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct NonGuiClientView_Previews: PreviewProvider {
  static var previews: some View {
    TesterView()
    .frame(minWidth: 1000)
    .padding()
  }
}
