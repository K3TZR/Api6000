//
//  XvtrView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 8/5/22.
//

import ComposableArchitecture
import SwiftUI

import Objects

// ----------------------------------------------------------------------------
// MARK: - View

struct XvtrView: View {
  @ObservedObject var apiModel: ApiModel
  
  var body: some View {
    
    if apiModel.xvtrs.count == 0 {
      HStack(spacing: 20) {
        Text("XVTRs").frame(width: 80, alignment: .leading)
        Text("None present").foregroundColor(.red)
      }
      .padding(.leading, 40)
      
    } else {
      HStack(spacing: 20) {
        Text("XVTR").frame(width: 80, alignment: .leading)
        Text("NOT IMPLEMENTED").foregroundColor(.red)
      }
      .padding(.leading, 40)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct XvtrView_Previews: PreviewProvider {
  static var previews: some View {
    XvtrView(apiModel: ApiModel())
  }
}
