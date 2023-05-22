//
//  CwxSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 8/10/22.
//

import SwiftUI

import FlexApi

// ----------------------------------------------------------------------------
// MARK: - View

struct CwxSubView: View {
  @ObservedObject var cwx: Cwx
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        Group {
          Text("CWX")
          HStack(spacing: 5) {
            Text("Bkin_Delay")
            Text("\(cwx.breakInDelay)").foregroundColor(.green)
          }
          HStack(spacing: 5) {
            Text("QSK")
            Text(cwx.qskEnabled ? "Y" : "N").foregroundColor(cwx.qskEnabled ? .green : .red)
          }
          HStack(spacing: 5) {
            Text("WPM")
            Text("\(cwx.wpm)").foregroundColor(.green)
          }
        }
      }
      .frame(width: 100, alignment: .leading)
    }
    .padding(.leading, 20)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct CwxSubView_Previews: PreviewProvider {
  static var previews: some View {
    CwxSubView(cwx: Cwx())
  }
}
