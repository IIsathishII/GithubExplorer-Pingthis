//
//  ExploreRepoViewController.swift
//  GithubExplorer-Pingthis
//
//  Created by SathishKumar on 21/04/21.
//

import Foundation
import UIKit

class ExploreRepoViewController : UITableViewController {
    
    var repos : [Repository] = []
    
    var insertionCallback : ((Repository) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkRequest.main.getUserRepos { (repos) in
            DispatchQueue.main.async {
                self.repos = repos
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "ExploreRepoCell")
        cell.textLabel?.text = self.repos[indexPath.row].name
        cell.detailTextLabel?.text = self.repos[indexPath.row].description ?? "No description available."
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel.init()
        label.text = "Select a repository to be added to your Watchlist"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        var view = UIView.init()
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
        ])
        return view
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        insertionCallback?(self.repos[indexPath.row])
    }
}
