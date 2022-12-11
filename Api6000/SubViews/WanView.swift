//
//  WanView.swift
//  Api6000Tester
//
//  Created by Douglas Adams on 8/10/22.
//

import SwiftUI

import Objects

// ----------------------------------------------------------------------------
// MARK: - View

struct WanView: View {
  @ObservedObject var wan: Wan
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        Text("WAN").frame(width: 100, alignment: .leading)
        Group {
          HStack(spacing: 5) {
            Text("Radio Authenticated")
            Text(wan.radioAuthenticated ? "Y" : "N").foregroundColor(wan.radioAuthenticated ? .green : .red)
          }
          HStack(spacing: 5) {
            Text("Server Connected")
            Text(wan.serverConnected ? "Y" : "N").foregroundColor(wan.serverConnected ? .green : .red)
          }
        }.frame(width: 210, alignment: .leading)
      }
    }
    .padding(.leading, 20)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct WanView_Previews: PreviewProvider {
  static var previews: some View {
    WanView(wan: Wan())
  }
}