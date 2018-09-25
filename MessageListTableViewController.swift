//
//  MessageListTableViewController.swift
//  BulletinBoardCK
//
//  Created by John Tate on 9/24/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import UIKit

class MessageListTableViewController: UITableViewController {

    @IBOutlet weak var messageTextField: UITextField!
    
    let formatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        return dateFormatter
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: MessageController.shared.messagesWereUpdatedNotification, object: nil)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        MessageController.shared.fetchAllMessageRecordsFromCloudKit()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return MessageController.shared.messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        let message = MessageController.shared.messages[indexPath.row]
        cell.textLabel?.text = message.text
        cell.detailTextLabel?.text = formatter.string(from: message.timestamp)
        return cell
    }
    
    @objc func updateView() {
        DispatchQueue.main.async {
            // by this point we know that the fetch is done because the notification has been sent
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
        }
    }
    
    @IBAction func postMessageButtonTapped(_ sender: Any) {

        guard let messageText = messageTextField.text,
            !messageText.isEmpty else { return }
        MessageController.shared.createMessage(text: messageText)
        tableView.reloadData()
        messageTextField.text = ""
        messageTextField.resignFirstResponder()
    }
}
