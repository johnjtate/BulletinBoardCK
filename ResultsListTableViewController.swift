//
//  ResultsListTableViewController.swift
//  BulletinBoardCK
//
//  Created by John Tate on 9/25/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import UIKit

class ResultsListTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: MessageController.shared.messagesWereUpdatedNotification, object: nil)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        MessageController.shared.fetchAllMessageRecordsFromCloudKit()
    }

    @objc func updateView() {
        DispatchQueue.main.async {
            // by this point we know that the fetch is done because the notification has been sent
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
        }
    }

    // make it optional so we don't have to initialize it
    var resultsArray: [Message]?
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text else { return }
        let messages = MessageController.shared.messages
        
        // iterate through text from our model object
        let filteredMessages = messages.filter{ $0.matches(searchTerm: searchText) }
        let results = filteredMessages.map{ $0 as Message}
        resultsArray = results
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        resultsArray = MessageController.shared.messages
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultsArray = MessageController.shared.messages
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let searchResults = resultsArray else { return 0 }
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath)

        guard let searchResults = resultsArray else { return UITableViewCell() }
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.text
        return cell
    }
 

}
