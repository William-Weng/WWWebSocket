//
//  WWWebSocket.swift
//  WWWebSocket
//
//  Created by William.Weng on 2023/4/24.
//

import UIKit

// MARK: - WWWebSocketDelegate
public protocol WWWebSocketDelegate {
    
    func didOpenWithProtocol(_ protocol: String?)                                               // [連線開啟](https://www.appcoda.com.tw/swiftui-websocket/)
    func didCloseWith(_ closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)            // [連線關閉](https://ithelp.ithome.com.tw/articles/10208531)
    func receiveMessageResult(_ result: Result<URLSessionWebSocketTask.Message, Error>)         // [傳送訊息](https://ithelp.ithome.com.tw/articles/10230335)
}

// MARK: - Utility (單例)
open class WWWebSocket: NSObject {
    
    public static let shared = WWWebSocket()
    
    private var task: URLSessionWebSocketTask?                                                  // 連線的Task
    private var delegate: WWWebSocketDelegate?
    
    private var didOpenWithProtocolBlock: ((String?) -> Void)?                                  // 已開啟連接
    private var didCloseWithCodeBlock: ((URLSessionWebSocketTask.CloseCode, Data?) -> Void)?    // 已關閉連接
    
    private override init() {}
    
    deinit { delegate = nil }
}

// MARK: - URLSessionWebSocketDelegate
extension WWWebSocket: URLSessionWebSocketDelegate {
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        delegate?.didOpenWithProtocol(`protocol`)
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        delegate?.didCloseWith(closeCode, reason: reason)
    }
}

// MARK: - 開放工具
public extension WWWebSocket {
    
    /// [WebSocket連線 => 接收訊息](https://medium.com/@jqkqq7895/websocket-swift-71ed0104ab81)
    /// - Parameters:
    ///   - socketUrl: [連線URL - ws://](https://medium.com/彼得潘的-swift-ios-app-開發教室/websocket-swift-84c47e90bb49)
    ///   - configuration: URLSessionConfiguration
    ///   - queue: OperationQueue?
    func connent(with socketUrl: String, delegate: WWWebSocketDelegate?, configuration: URLSessionConfiguration = .default, delegateQueue queue: OperationQueue? = .main) {
        
        self.delegate = delegate
        
        guard let url = URL(string: socketUrl) else { delegate?.receiveMessageResult(.failure(Constant.MyError.notUrlFormat)); return }
        
        let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
        let request = URLRequest(url: url)
                
        task = urlSession.webSocketTask(with: request)
        receiveMessage(with: task) { delegate?.receiveMessageResult($0) }
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
