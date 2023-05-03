//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2022/12/15.
//  ~/Library/Caches/org.swift.swiftpm/
//  file:///Users/william/Desktop/WWWebSocket

import UIKit
import WWPrint
import WWWebSocket

final class ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    
    private let url = "wss://demo.piesocket.com/v3/channel_123?api_key=VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connect(with: url)
    }
}

// MARK: - 小工具
private extension ViewController {
    
    /// [WebSocket連線](https://www.piesocket.com/websocket-tester)
    /// - Parameter url: String
    func connect(with url: String) {
        
        WWWebSocket.shared.connent(with: url) { value in
            wwPrint("connected => \(String(describing: value))")
        } didCloseWithCode: { code, data in
            wwPrint("disconnected => \(code), \(String(describing: data))")
        } receiveResult: { result in
            switch result {
            case .failure(let error): wwPrint(error)
            case .success(let message):
                
                switch message {
                case .string(let string):
                    self.resultLabel.text = string
                    wwPrint(string)
                case .data(let data):
                    wwPrint(data)
                @unknown default:
                    break
                }
            }
        }
    }
}
