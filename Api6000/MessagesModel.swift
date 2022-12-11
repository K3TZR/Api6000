//
//  MessagesModel.swift
//  Api6000Tester-C
//
//  Created by Douglas Adams on 10/15/22.
//

import ComposableArchitecture
import Foundation

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

@MainActor
public final class MessagesModel: ObservableObject, TesterDelegate {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization (Singleton)
  
  public static var shared = MessagesModel()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  @Published var filteredMessages = IdentifiedArrayOf<TcpMessage>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _filter: MessageFilter = .all
  private var _filterText: String = ""
  private var _messages = IdentifiedArrayOf<TcpMessage>()
  private var _showPings = false
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Append a TcpMessage to the messages array and re-filter the filteredMessages pulished value
  /// - Parameter message: a TcpMessage struct
  public func addMessage(_ message: TcpMessage) {
    self._messages.append(message)
    self.filterMessage(message)
  }
  
  /// Clear all messages
  public func clearAll() {
    self._messages.removeAll()
    self.filteredMessages.removeAll()
  }
  
  /// FIlter a TcpMessage, optionally placing it in the filteredMessages array
  /// - Parameter message: a TcpMessage struct
  public func filterMessage(_ message: TcpMessage) {
    
    // append to the messages array
    switch (_filter, _filterText) {
      
    case (.all, _):        filteredMessages.append(message)
    case (.prefix, ""):    filteredMessages.append(message)
    case (.prefix, _):     if message.text.localizedCaseInsensitiveContains("|" + _filterText) { filteredMessages.append(message) }
    case (.includes, _):   if message.text.localizedCaseInsensitiveContains(_filterText) { filteredMessages.append(message) }
    case (.excludes, ""):  filteredMessages.append(message)
    case (.excludes, _):   if !message.text.localizedCaseInsensitiveContains(_filterText) { filteredMessages.append(message) }
    case (.command, _):    if message.text.prefix(1) == "C" { filteredMessages.append(message) }
    case (.S0, _):         if message.text.prefix(3) == "S0|" { filteredMessages.append(message) }
    case (.status, _):     if message.text.prefix(1) == "S" && message.text.prefix(3) != "S0|" { filteredMessages.append(message) }
    case (.reply, _):      if message.text.prefix(1) == "R" { filteredMessages.append(message) }
    }
  }
  
  /// Rebuild the entire filteredMessages array
  public func filterMessages() {
    // re-filter the entire messages array
    switch (_filter, _filterText) {
      
    case (.all, _):        filteredMessages = _messages
    case (.prefix, ""):    filteredMessages = _messages
    case (.prefix, _):     filteredMessages = _messages.filter { $0.text.localizedCaseInsensitiveContains("|" + _filterText) }
    case (.includes, _):   filteredMessages = _messages.filter { $0.text.localizedCaseInsensitiveContains(_filterText) }
    case (.excludes, ""):  filteredMessages = _messages
    case (.excludes, _):   filteredMessages = _messages.filter { !$0.text.localizedCaseInsensitiveContains(_filterText) }
    case (.command, _):    filteredMessages = _messages.filter { $0.text.prefix(1) == "C" }
    case (.S0, _):         filteredMessages = _messages.filter { $0.text.prefix(3) == "S0|" }
    case (.status, _):     filteredMessages = _messages.filter { $0.text.prefix(1) == "S" && $0.text.prefix(3) != "S0|"}
    case (.reply, _):      filteredMessages = _messages.filter { $0.text.prefix(1) == "R" }
    }
  }
  
  /// Set the messages filter parameters and re-filter
  /// - Parameters:
  ///   - filter: a MessageFilter instance
  ///   - filterText: a text String
  public func setFilter(_ filter: MessageFilter, _ filterText: String) {
    _filter = filter
    _filterText = filterText
    self.filterMessages()
  }
  
  /// Set the Show Pings Bool
  /// - Parameter value: a Bool value
  public func setShowPings(_ value: Bool) {
    _showPings = value
  }
  
  /// Initialize the filter parameters and begin to process TcpMessages
  /// - Parameters:
  ///   - filter: a MessageFilter instance
  ///   - filterText: a text String
  public func start(_ filter: MessageFilter = .all, _ filterText: String = "") {
    _filter = filter
    _filterText = filterText
    Tcp.shared.testerDelegate = self
  }
  
  /// Stop processing TcpMessages
  public func stop() {
    Tcp.shared.testerDelegate = nil
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
    if message.text.contains("ping") && _showPings == false { return }
    self.addMessage(message)
  }
}
