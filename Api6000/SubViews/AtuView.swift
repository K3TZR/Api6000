//
//  AtuView.swift
//  Api6000Components/ApiViewer/Subviews/ObjectsSubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import Objects
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

struct AtuView: View {
  @ObservedObject var atu: Atu
  @ObservedObject var radio: Radio
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        if radio.atuPresent {
          Group {
            Text("ATU")
            HStack(spacing: 5) {
              Text("Enabled")
              Text(atu.enabled ? "Y" : "N").foregroundColor(atu.enabled ? .green : .red)
            }
            HStack(spacing: 5) {
              Text("Status")
              Text(atu.status == "" ? "none" : atu.status).foregroundColor(.green)
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

struct AtuView_Previews: PreviewProvider {
  
  static var previews: some View {
    
    AtuView(atu: Atu(), radio: Radio(Packet()))
  }
}


