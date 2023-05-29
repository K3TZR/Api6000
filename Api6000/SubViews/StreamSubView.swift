//
//  StreamSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApi
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

struct StreamSubView: View {
  @ObservedObject var objectModel: ObjectModel
  @ObservedObject var streamModel: StreamModel
  let handle: UInt32
  
  
  var body: some View {
    Grid(alignment: .leading, horizontalSpacing: 10) {
      // Meter
      MeterStreamView(streamModel: streamModel)
      
      // Panadapter
      ForEach(objectModel.panadapters) { panadapter in
        if handle == panadapter.clientHandle { PanadapterStreamView(panadapter: panadapter) }
      }
      
      // Waterfall
      ForEach(objectModel.waterfalls) { waterfall in
        if handle == waterfall.clientHandle { WaterfallStreamView(waterfall: waterfall) }
      }
      
      // RemoteRxAudioStream
      ForEach(streamModel.remoteRxAudioStreams) { stream in
        if handle == stream.clientHandle { RemoteRxStreamView(stream: stream) }
      }
      
      // RemoteTxAudioStream
      ForEach(streamModel.remoteTxAudioStreams) { stream in
        if handle == stream.clientHandle { RemoteTxStreamView(stream: stream) }
      }
      
      // DaxMicAudioStream
      ForEach(streamModel.daxMicAudioStreams) { stream in
        if handle == stream.clientHandle { DaxMicStreamView(stream: stream) }
      }
      
      // DaxRxAudioStream
      ForEach(streamModel.daxRxAudioStreams) { stream in
        if handle == stream.clientHandle { DaxRxStreamView(stream: stream) }
      }
      
      // DaxTxAudioStream
      ForEach(streamModel.daxTxAudioStreams) { stream in
        if handle == stream.clientHandle { DaxTxStreamView(stream: stream) }
      }
      
      // DaxIqStream
      ForEach(streamModel.daxIqStreams) { stream in
        if handle == stream.clientHandle { DaxIqStreamView(stream: stream) }
      }
    }
    .padding(.leading, 20)
  }
}

private struct MeterStreamView: View {
  @ObservedObject var streamModel: StreamModel
  
  var body: some View {
    
    GridRow {
      Group {
        Text("METER")
        Text(streamModel.meterStream == nil ? "0x--------" : streamModel.meterStream!.id.hex ).foregroundColor(.green)
        HStack(spacing: 5) {
          Text("Streaming")
          Text(streamModel.meterStream == nil ? "N" : "Y").foregroundColor(streamModel.meterStream == nil ? .red : .green)
        }
      }.frame(width: 100, alignment: .leading)
    }
  }
}

private struct PanadapterStreamView: View {
  @ObservedObject var panadapter: Panadapter
  
  var body: some View {
    
    GridRow {
      Group {
        Text("PANADAPTER")
        Text(panadapter.isStreaming ? panadapter.id.hex : "0x--------").foregroundColor(.green)
        HStack(spacing: 5) {
          Text("Streaming")
          Text(panadapter.isStreaming ? "Y" : "N").foregroundColor(panadapter.isStreaming ? .green : .red)
        }
      }.frame(width: 100, alignment: .leading)
    }
  }
}

private struct WaterfallStreamView: View {
  @ObservedObject var waterfall: Waterfall
  
  var body: some View {
    
    GridRow {
      Group {
        Text("WATERFALL")
        Text(waterfall.isStreaming ? waterfall.id.hex : "0x--------").foregroundColor(.green)
        HStack(spacing: 5) {
          Text("Streaming")
          Text(waterfall.isStreaming ? "Y" : "N").foregroundColor(waterfall.isStreaming ? .green : .red)
        }
      }.frame(width: 100, alignment: .leading)
    }
  }
}

private struct RemoteRxStreamView: View {
  @ObservedObject var stream: RemoteRxAudioStream
  
  var body: some View {
    
    GridRow {
      Group {
        Text("REMOTE Rx")
        Text(stream.isStreaming ? stream.id.hex : "0x--------").foregroundColor(.green)
        HStack(spacing: 5) {
          Text("Streaming")
          Text(stream.isStreaming ? "Y" : "N").foregroundColor(stream.isStreaming ? .green : .red)
        }
      }.frame(width: 100, alignment: .leading)
      Group {
        HStack(spacing: 5) {
          Text("Handle")
          Text("\(stream.clientHandle.hex)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Compression")
          Text("\(stream.compression)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Ip")
          Text("\(stream.ip)").foregroundColor(.green)
        }
      }.frame(width: 120, alignment: .leading)
    }
  }
}

private struct RemoteTxStreamView: View {
  @ObservedObject var stream: RemoteTxAudioStream
  
  var body: some View {
    
    GridRow {
      Group {
        Text("REMOTE Tx")
        Text(stream.isStreaming ? stream.id.hex : "0x--------").foregroundColor(.green)
        HStack(spacing: 5) {
          Text("Streaming")
          Text(stream.isStreaming ? "Y" : "N").foregroundColor(stream.isStreaming ? .green : .red)
        }
      }.frame(width: 100, alignment: .leading)
      Group {
        HStack(spacing: 5) {
          Text("Handle")
          Text("\(stream.clientHandle.hex)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Compression")
          Text("\(stream.compression)").foregroundColor(.green)
        }
      }.frame(width: 120, alignment: .leading)
    }
  }
}

private struct DaxMicStreamView: View {
  @ObservedObject var stream: DaxMicAudioStream
  
  var body: some View {
    
    GridRow {
      Group {
        Text("DAX Mic").frame(width: 80, alignment: .leading)
        Text(stream.isStreaming ? stream.id.hex : "0x--------").foregroundColor(.green)
        HStack(spacing: 5) {
          Text("Streaming")
          Text(stream.isStreaming ? "Y" : "N").foregroundColor(stream.isStreaming ? .green : .red)
        }
      }.frame(width: 100, alignment: .leading)
      Group {
        HStack(spacing: 5) {
          Text("Handle")
          Text("\(stream.clientHandle.hex)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Ip")
          Text("\(stream.ip)").foregroundColor(.green)
        }
      }.frame(width: 120, alignment: .leading)
    }
  }
}

private struct DaxRxStreamView: View {
  @ObservedObject var stream: DaxRxAudioStream
  
  var body: some View {
    
    GridRow {
      Group {
        Text("DAX Rx").frame(width: 80, alignment: .leading)
        Text(stream.isStreaming ? stream.id.hex : "0x--------").foregroundColor(.green)
        HStack(spacing: 5) {
          Text("Streaming")
          Text(stream.isStreaming ? "Y" : "N").foregroundColor(stream.isStreaming ? .green : .red)
        }
      }.frame(width: 100, alignment: .leading)
      Group {
        HStack(spacing: 5) {
          Text("Handle")
          Text("\(stream.clientHandle.hex)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Channel")
          Text("\(stream.daxChannel)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Ip")
          Text("\(stream.ip)").foregroundColor(.green)
        }
      }.frame(width: 120, alignment: .leading)
    }
  }
}

private struct DaxTxStreamView: View {
  @ObservedObject var stream: DaxTxAudioStream
  
  var body: some View {
    
    GridRow {
      Group {
        Text("DAX Tx").frame(width: 80, alignment: .leading)
        Text(stream.isStreaming ? stream.id.hex : "0x--------").foregroundColor(.green)
        HStack(spacing: 5) {
          Text("Streaming")
          Text(stream.isStreaming ? "Y" : "N").foregroundColor(stream.isStreaming ? .green : .red)
        }
      }.frame(width: 100, alignment: .leading)
      Group {
        HStack(spacing: 5) {
          Text("Handle")
          Text("\(stream.clientHandle.hex)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Ip")
          Text("\(stream.ip)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Transmit")
          Text("\(stream.isTransmitChannel ? "Y" : "N")").foregroundColor(stream.isTransmitChannel ? .green : .red)
        }
      }.frame(width: 120, alignment: .leading)
    }
  }
}

private struct DaxIqStreamView: View {
  @ObservedObject var stream: DaxIqStream
  
  var body: some View {
    
    GridRow {
      Group {
        Text("DAX IQ").frame(width: 80, alignment: .leading)
        Text(stream.isStreaming ? stream.id.hex : "0x--------").foregroundColor(.green)
        HStack(spacing: 5) {
          Text("Streaming")
          Text(stream.isStreaming ? "Y" : "N").foregroundColor(stream.isStreaming ? .green : .red)
        }
      }.frame(width: 100, alignment: .leading)
      Group {
        HStack(spacing: 5) {
          Text("Handle")
          Text("\(stream.clientHandle.hex)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Ip")
          Text("\(stream.ip)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Channel")
          Text("\(stream.channel)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Pan")
          Text(stream.pan.hex).foregroundColor(.green)
        }
      }.frame(width: 120, alignment: .leading)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct StreamSubView_Previews: PreviewProvider {
  static var previews: some View {
    StreamSubView(objectModel: ObjectModel(), streamModel: StreamModel(), handle: 1)
  }
}
