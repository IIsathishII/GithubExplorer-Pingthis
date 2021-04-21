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
    var filteredRepos : [Repository]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Github Repositories"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let searchController = UISearchController.init()
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.filteredRepos != nil {
            return self.filteredRepos!.count
        }
        return self.repos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: nil)
        let currentRepo = self.filteredRepos ?? self.repos
        cell.textLabel?.text = currentRepo[indexPath.row].name
        cell.detailTextLabel?.text = currentRepo[indexPath.row].description ?? "No description available."
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        insertionCallback?(self.repos[indexPath.row])
    }
}

extension ExploreRepoViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.filteredRepos = nil
            return
        }
        self.filteredRepos = self.repos.filter({ $0.name.lowercased().contains(searchText.lowercased()) })
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.filteredRepos = nil
    }
}
