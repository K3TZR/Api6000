//
//  TnfView.swift
//  Api6000Components/ApiViewer/Subviews/ObjectsSubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import ComposableArchitecture
import SwiftUI

import Objects

// ----------------------------------------------------------------------------
// MARK: - View

struct TnfView: View {
  @ObservedObject var apiModel: ApiModel
  //  @Dependency(\.apiModel) var apiModel
  
  var body: some View {
    if apiModel.tnfs.count == 0 {
      Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 0) {
        GridRow {
          Group {
            Text("TNF")
            Text("None present").foregroundColor(.red)
          }
          .frame(width: 100, alignment: .leading)
        }
      }
      .padding(.leading, 20)
      
    } else {
      ForEach(apiModel.tnfs) { tnf in
        DetailView(tnf: tnf)
      }
      .padding(.leading, 20)
    }
  }
}
  
private struct DetailView: View {
  @ObservedObject var tnf: Tnf
  
  func depthName(_ depth: UInt) -> String {
    switch depth {
    case 1: return "Normal"
    case 2: return "Deep"
    case 3: return "Very Deep"
    default:  return "Invalid"
    }
  }

  var body: some View {

    Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 0) {
      GridRow {
        Group {
          HStack(spacing: 5) {
            Text("TNF")
            Text(String(format: "%02d", tnf.id)).foregroundColor(.green)
          }
          Text("\(tnf.frequency)").foregroundColor(.green)
          HStack(spacing: 5) {
            Text("Width")
            Text("\(tnf.width)").foregroundColor(.green)
          }
          HStack(spacing: 5) {
            Text("Depth")
            Text(depthName(tnf.depth)).foregroundColor(.green)
          }
          HStack(spacing: 5) {
            Text("Permanent")
            Text(tnf.permanent ? "Y" : "N").foregroundColor(tnf.permanent ? .green : .red)
          }
        }.frame(width: 100, alignment: .leading)
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct TnfView_Previews: PreviewProvider {
  static var previews: some View {
    TnfView(apiModel: ApiModel())
      .frame(minWidth: 1000)
      .padding()
  }
}
