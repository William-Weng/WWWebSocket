//
//  WWWebSocket.swift
//  WWWebSocket
//
//  Created by William.Weng on 2023/4/24.
//

import UIKit

// MARK: - Utility (單例)
open class WWWebSocket: NSObject {
    
    public static let shared = WWWebSocket()
    
    private var task: URLSessionWebSocketTask?                                                  // 連線的Task
    
    private var didOpenWithProtocolBlock: ((String?) -> Void)?                                  // 已開啟連接
    private var didCloseWithCodeBlock: ((URLSessionWebSocketTask.CloseCode, Data?) -> Void)?    // 已關閉連接
    
    private override init() {}
}

// MARK: - URLSessionWebSocketDelegate
extension WWWebSocket: URLSessionWebSocketDelegate {
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        didOpenWithProtocolBlock?(`protocol`)
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        didCloseWithCodeBlock?(closeCode, reason)
    }
}

// MARK: - 開放工具
public extension WWWebSocket {
    
    /// [WebSocket連線 => 收接訊息](https://medium.com/@jqkqq7895/websocket-swift-71ed0104ab81)
    /// - Parameters:
    ///   - socketUrl: [連線URL - ws://](https://medium.com/彼得潘的-swift-ios-app-開發教室/websocket-swift-84c47e90bb49)
    ///   - configuration: URLSessionConfiguration
    ///   - queue: OperationQueue?
    ///   - didOpenWithProtocol: [連線開啟](https://www.appcoda.com.tw/swiftui-websocket/)
    ///   - didCloseWithCode: [連線關閉](https://ithelp.ithome.com.tw/articles/10208531)
    ///   - receiveResult: Result<URLSessionWebSocketTask.Message, Error>
    func connent(with socketUrl: String, configuration: URLSessionConfiguration = .default, delegateQueue queue: OperationQueue? = .main, didOpenWithProtocol: ((String?) -> Void)?, didCloseWithCode: ((URLSessionWebSocketTask.CloseCode, Data?) -> Void)?, receiveResult: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void) {
        
        guard let url = URL(string: socketUrl) else { receiveResult(.failure(Constant.MyError.notUrlFormat)); return }
        
        let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
        let request = URLRequest(url: url)
        
        didOpenWithProtocolBlock = didOpenWithProtocol
        didCloseWithCodeBlock = didCloseWithCode
        
        task = urlSession.webSocketTask(with: request)
        
        receiveMessage(with: task) { result in
            switch result {
            case .failure(let error): receiveResult(.failure(error))
            case .success(let message): receiveResult(.success(message))
            }
        }
        
        task?.resume()
    }
    
    /// [傳送訊息](https://creativecoding.in/2020/03/25/用-socket-io-做一個即時聊天室吧！（直播筆記）/)
    /// - Parameters:
    ///   - message: URLSessionWebSocketTask.Message
    ///   - result: Error?
    func sendMessage(_ message: URLSessionWebSocketTask.Message, result: @escaping (Error?) -> Void) {
        
        let taskMessage: URLSessionWebSocketTask.Message
        
        switch message {
        case .data(let data): taskMessage = URLSessionWebSocketTask.Message.data(data)
        case .string(let string): taskMessage = URLSessionWebSocketTask.Message.string(string)
        @unknown default: fatalError()
        }
        
        task?.send(taskMessage) { result($0) }
    }
    
    /// 關閉連線
    /// - Parameters:
    ///   - closeCode: URLSessionWebSocketTask.CloseCode
    ///   - reason: Data?
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode = .goingAway, reason: Data? = nil) {
        task?.cancel(with: closeCode, reason: reason)
    }
}

// MARK: - 小工具
private extension WWWebSocket {
    
    /// 收接訊息
    /// - Parameters:
    ///   - task: URLSessionWebSocketTask?
    ///   - result: Result<URLSessionWebSocketTask.Message, Error>
    func receiveMessage(with task: URLSessionWebSocketTask?, result: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void) {
        
        task?.receive(completionHandler: { _result in
            switch _result {
            case .failure(let error):
                result(.failure(error))
            case .success(let message):
                result(.success(message))
                self.receiveMessage(with: task, result: result)
            }
        })
    }
}
