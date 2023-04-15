//
//  SwiftUIView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/24/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApi

// ----------------------------------------------------------------------------
// MARK: - View

struct AmplifierView: View {
 
  @Dependency(\.objectModel) var objectModel
  
  var body: some View {
    if objectModel.amplifiers.count == 0 {
      Grid(alignment: .leading, horizontalSpacing: 10) {
        GridRow {
          Group {
            Text("AMPLIFIERs")
            Text("None present").foregroundColor(.red)
          }
          .frame(width: 100, alignment: .leading)
        }
      }
      .padding(.leading, 20)
      
    } else {
      ForEach(objectModel.amplifiers) { amplifier in
        DetailView(amplifier: amplifier)
      }
    }
  }
}

private struct DetailView: View {
  @ObservedObject var amplifier: Amplifier
  
  var body: some View {
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        Group {
          Text("AMPLIFIER")
          Text(amplifier.id.hex)
          Text(amplifier.model)
          Text(amplifier.ip)
          Text("Port \(amplifier.port)")
          Text(amplifier.state)
        }
        .frame(width: 100, alignment: .leading)
      }
    }
    .padding(.leading, 20)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct AmplifierView_Previews: PreviewProvider {
  static var previews: some View {
    AmplifierView()
  }
}
