//
//  ViewController.swift
//  SocketIoClientSwift-demo
//
//  Created by kazunori.aoki on 2021/11/05.
//

import UIKit
import SocketIO

class ViewController: UIViewController {

    // MARK: UI
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var reconnectButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!


    // MARK: Property
    let manager = SocketManager(socketURL: URL(string:"http://192.168.10.2:3000")!,
                                config: [.log(true), .compress])
    var socket: SocketIOClient!
    var dataList = [String]()


    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        connectSocket()
    }


    // MARK: IBAction
    @IBAction func tapConnect(_ sender: Any) {
        socket.emit("from_client", "button pushed")
    }

    @IBAction func tapReconnect(_ sender: Any) {
        socket.connect()
    }

    @IBAction func tapDisconnect(_ sender: Any) {
        socket.disconnect()
    }
}


// MARK: - Setup
private extension ViewController {

    func setup() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}


// MARK: - Private
private extension ViewController {

    func connectSocket() {
        socket = manager.defaultSocket
        socket.connect()

        socket.on(clientEvent: .connect) { data, ack in
            print("socket connected!")
        }

        socket.on(clientEvent: .disconnect) { data, ack in
            print("socket disconnected!")
        }

        socket.on("from_server") {data, ack in
            if let message = data as? [String] {
                print(message[0])
                self.dataList.insert(message[0], at: 0)
                self.tableView.reloadData()
            }
        }
    }
}


// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")

        cell.textLabel?.text = dataList[indexPath.row]

        return cell
    }
}


// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {

}
