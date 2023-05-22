//
//  MessagesModel.swift
//  Api6000
//
//  Created by Douglas Adams on 10/15/22.
//

import ComposableArchitecture
import Foundation
import SwiftUI

import Tcp
//import Api6000
import Shared

// ----------------------------------------------------------------------------
// MARK: - Dependency decalarations

extension MessagesModel: DependencyKey {
  public static let liveValue = MessagesModel.shared
}

extension DependencyValues {
  var messagesModel: MessagesModel {
    get { self[MessagesModel.self] }
    set { self[MessagesModel.self] = newValue }
  }
}

//@MainActor
public final class MessagesModel: ObservableObject, TesterDelegate {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization (Singleton)
  
  public static var shared = MessagesModel()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  @Published var filteredMessages = IdentifiedArrayOf<TcpMessage>()

  @AppStorage("showPings") var showPings = false
  @AppStorage("messageFilter") var messageFilter = MessageFilter.all.rawValue
  @AppStorage("messageFilterText") var messageFilterText = ""

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _messages = IdentifiedArrayOf<TcpMessage>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Clear all messages
  public func clearAll(_ enabled: Bool = true) {
    if enabled {
      self._messages.removeAll()
      Task { await removeAllFilteredMessages() }
    }
  }

  /// Set the messages filter parameters and re-filter
  public func reFilter(filter: String) {
    messageFilter = filter
    Task { await self.filterMessages() }
  }

  /// Set the messages filter parameters and re-filter
  public func reFilter(filterText: String) {
    messageFilterText = filterText
    Task { await self.filterMessages() }
  }

  /// Begin to process TcpMessages
  public func start() {
//    Tcp.shared.testerDelegate = self
    subscribeToTcpMessages()
  }
  
  /// Stop processing TcpMessages
  public func stop() {
//    Tcp.shared.testerDelegate = nil
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Rebuild the entire filteredMessages array
  @MainActor private func filterMessages() {
    // re-filter the entire messages array
    switch (messageFilter, messageFilterText) {

    case (MessageFilter.all.rawValue, _):        filteredMessages = _messages
    case (MessageFilter.prefix.rawValue, ""):    filteredMessages = _messages
    case (MessageFilter.prefix.rawValue, _):     filteredMessages = _messages.filter { $0.text.localizedCaseInsensitiveContains("|" + messageFilterText) }
    case (MessageFilter.includes.rawValue, _):   filteredMessages = _messages.filter { $0.text.localizedCaseInsensitiveContains(messageFilterText) }
    case (MessageFilter.excludes.rawValue, ""):  filteredMessages = _messages
    case (MessageFilter.excludes.rawValue, _):   filteredMessages = _messages.filter { !$0.text.localizedCaseInsensitiveContains(messageFilterText) }
    case (MessageFilter.command.rawValue, _):    filteredMessages = _messages.filter { $0.text.prefix(1) == "C" }
    case (MessageFilter.S0.rawValue, _):         filteredMessages = _messages.filter { $0.text.prefix(3) == "S0|" }
    case (MessageFilter.status.rawValue, _):     filteredMessages = _messages.filter { $0.text.prefix(1) == "S" && $0.text.prefix(3) != "S0|"}
    case (MessageFilter.reply.rawValue, _):      filteredMessages = _messages.filter { $0.text.prefix(1) == "R" }
    default:                                     filteredMessages = _messages
    }
  }
  
  @MainActor private func removeAllFilteredMessages() {
    self.filteredMessages.removeAll()
  }
}

extension MessagesModel {
  // ----------------------------------------------------------------------------
  // MARK: - TesterDelegate methods
  
  /// Receive a TcpMessage from Tcp
  /// - Parameter message: a TcpMessage struct
  public func testerMessages(_ message: TcpMessage) {
    
    // ignore routine replies (i.e. replies with no error or no attached data)
    func ignoreReply(_ text: String) -> Bool {
      if text.first != "R" { return false }     // not a Reply
      let parts = text.components(separatedBy: "|")
      if parts.count < 3 { return false }       // incomplete
      if parts[1] != kNoError { return false }  // error of some type
      if parts[2] != "" { return false }        // additional data present
      return true                               // otherwise, ignore it
    }
    
    // ignore received replies unless they are non-zero or contain additional data
    if message.direction == .received && ignoreReply(message.text) { return }
    // ignore sent "ping" messages unless showPings is true
    if message.text.contains("ping") && showPings == false { return }
    // add it to the backing collection
    _messages.append(message)
    Task {
      await MainActor.run {
        // add it to the published collection if appropriate
        switch (messageFilter, messageFilterText) {
          
        case (MessageFilter.all.rawValue, _):        filteredMessages.append(message)
        case (MessageFilter.prefix.rawValue, ""):    filteredMessages.append(message)
        case (MessageFilter.prefix.rawValue, _):     if message.text.localizedCaseInsensitiveContains("|" + messageFilterText) { filteredMessages.append(message) }
        case (MessageFilter.includes.rawValue, _):   if message.text.localizedCaseInsensitiveContains(messageFilterText) { filteredMessages.append(message) }
        case (MessageFilter.excludes.rawValue, ""):  filteredMessages.append(message)
        case (MessageFilter.excludes.rawValue, _):   if !message.text.localizedCaseInsensitiveContains(messageFilterText) { filteredMessages.append(message) }
        case (MessageFilter.command.rawValue, _):    if message.text.prefix(1) == "C" { filteredMessages.append(message) }
        case (MessageFilter.S0.rawValue, _):         if message.text.prefix(3) == "S0|" { filteredMessages.append(message) }
        case (MessageFilter.status.rawValue, _):     if message.text.prefix(1) == "S" && message.text.prefix(3) != "S0|" { filteredMessages.append(message) }
        case (MessageFilter.reply.rawValue, _):      if message.text.prefix(1) == "R" { filteredMessages.append(message) }
        default:                                     filteredMessages.append(message)
        }
      }
    }
  }
  
  
  private func subscribeToTcpMessages()  {
    Task(priority: .high) {
      log("MessagesModel: TcpMessage subscription STARTED", .debug, #function, #file, #line)
      for await tcpMessage in Tcp.shared.testerStream {
        testerMessages(tcpMessage)
      }
      log("MessagesModel: : TcpMessage subscription STOPPED", .debug, #function, #file, #line)
    }
  }
}
