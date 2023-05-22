//
//  MeterStreamSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 9/23/22.
//

import ComposableArchitecture
import SwiftUI

import Shared
import FlexApi

// ----------------------------------------------------------------------------
// MARK: - View

struct MeterStreamSubView: View {
  @ObservedObject var objectModel: ObjectModel
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        Group {
          Text("METERS")
          Text("\(objectModel.meterStreamId == 0 ? "0x--------" : objectModel.meterStreamId.hex)").foregroundColor(.green)
          HStack(spacing: 5) {
            Text("Streaming")
            Text(objectModel.meterStreamId == 0 ? "N" : "Y").foregroundColor(objectModel.meterStreamId == 0 ? .red : .green)
          }
        }.frame(width: 100, alignment: .leading)
      }
    }
    .padding(.leading, 20)
  }
}

struct MeterStreamSubView_Previews: PreviewProvider {
  static var previews: some View {
    MeterStreamSubView(objectModel: ObjectModel())
  }
}
