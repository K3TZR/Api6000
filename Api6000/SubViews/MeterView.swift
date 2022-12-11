//
//  MeterView.swift
//  Api6000Components/ApiViewer
//
//  Created by Douglas Adams on 1/24/22.
//

import ComposableArchitecture
import SwiftUI

import Objects
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

struct MeterView: View {
  @ObservedObject var apiModel: ApiModel
  let sliceId: UInt32?
  let sliceClientHandle: UInt32?
  let handle: Handle
  
  
  func showMeter(_ id: UInt32?, _ clientHandle: UInt32?, _ source: String, _ group: String) -> Bool {
    if id == nil { return true }
    if clientHandle != handle { return false }
    if source != "slc" { return false }
    if UInt32(group) != id { return false }
    return true
  }
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      HeadingView(sliceId: sliceId)
      ForEach(apiModel.meters ) { meter in
        if showMeter(sliceId, sliceClientHandle, meter.source, meter.group) {
          DetailView(meter: meter, sliceId: sliceId)
        }
      }
      .foregroundColor(.secondary)
    }
    .padding(.leading, 40)
  }
}

private struct HeadingView: View {
  let sliceId: UInt32?
  
  var body: some View {
    GridRow {
      Group {
        Text("METER #")
        if sliceId == nil {
          Text("Group")
          Text("Source")
        }
      }.frame(width: 60, alignment: .leading)
      
      Text("Name").frame(width: 110)
      Group {
        Text("Value")
        Text("Units")
        Text("Fps")
      }.frame(width: 70)
      Text("Description")
    }
  }
}


private struct DetailView: View {
  @ObservedObject var meter: Meter
  let sliceId: UInt32?
  
  func valueColor(_ value: Float, _ low: Float, _ high: Float) -> Color {
    if value > high { return .red }
    if value < low { return .yellow }
    return .green
  }
  
  var body: some View {
    
    GridRow {
      Group {
        Text(String(format: "% 3d", meter.id))
        if sliceId == nil {
          Text(meter.group)
          Text(meter.source)
        }
      }.frame(width: 60, alignment: .center)
      Text(meter.name).frame(width: 110, alignment: .leading)
      Group {
        Text(String(format: "%-4.2f", meter.value))
          .help("        range: \(String(format: "%-4.2f", meter.low)) to \(String(format: "%-4.2f", meter.high))")
          .foregroundColor(valueColor(meter.value, meter.low, meter.high))
        Text(meter.units)
        Text(String(format: "% 2d", meter.fps))
      }.frame(width: 70, alignment: .trailing)
      Text(meter.desc).foregroundColor(.primary)
    }
  }
}

//    HStack(spacing: 10) {
//      Group {
//        Text(String(format: "% 3d", meter.id))
//        if sliceId == nil {
//          Text(meter.group)
//          Text(meter.source)
//        }
//      }.frame(width: 60, alignment: .trailing)
//      Text(meter.name).frame(width: 110, alignment: .leading)
//      Text(String(format: "%-4.2f", meter.value))
//        .help("        range: \(String(format: "%-4.2f", meter.low)) to \(String(format: "%-4.2f", meter.high))")
//        .foregroundColor(valueColor(meter.value, meter.low, meter.high))
//        .frame(width: 70, alignment: .trailing)
//      Text(meter.units).frame(width: 70, alignment: .trailing)
//      Text(String(format: "% 2d", meter.fps)).frame(width: 70, alignment: .trailing)
//      Text(meter.desc).foregroundColor(.primary)
//    }
//    .padding(.leading, 60)
//  }
//}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct MeterView_Previews: PreviewProvider {
  static var previews: some View {
    MeterView(apiModel: ApiModel(), sliceId: 1, sliceClientHandle: nil, handle: 1)
      .frame(minWidth: 1000)
      .padding()
  }
}
