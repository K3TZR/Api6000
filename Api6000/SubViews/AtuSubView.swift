//
//  AtuSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import FlexApi
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

struct AtuSubView: View {
  @ObservedObject var atu: Atu
  @ObservedObject var apiModel: ApiModel
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        if apiModel.atuPresent {
          Group {
            Text("ATU")
            HStack(spacing: 5) {
              Text("Enabled")
              Text(atu.enabled ? "Y" : "N").foregroundColor(atu.enabled ? .green : .red)
            }
            HStack(spacing: 5) {
              Text("Mem enabled")
              Text(atu.memoriesEnabled ? "Y" : "N").foregroundColor(atu.memoriesEnabled ? .green : .red)
            }
            HStack(spacing: 5) {
              Text("Using Mem")
              Text(atu.usingMemory ? "Y" : "N").foregroundColor(atu.usingMemory ? .green : .red)
            }
          }
          .frame(width: 100, alignment: .leading)
          HStack(spacing: 5) {
            Text("Status")
            Text(atu.status.rawValue).foregroundColor(.green)
          }
        } else {
          Group {
            Text("ATU")
            Text("Not installed").foregroundColor(.red)
          }
          .frame(width: 100, alignment: .leading)
        }
      }
    }
    .padding(.leading, 20)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct AtuSubView_Previews: PreviewProvider {
  
  static var previews: some View {
    AtuSubView(atu: Atu(), apiModel: ApiModel())
  }
}
