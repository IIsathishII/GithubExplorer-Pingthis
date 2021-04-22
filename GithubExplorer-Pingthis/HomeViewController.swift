//
//  HomeViewController.swift
//  GithubExplorer-Pingthis
//
//  Created by SathishKumar on 21/04/21.
//

import Foundation
import UIKit

class HomeViewController : UIViewController {
    
    var tableView = UITableView.init()
    
    var watchlistRepos : [Repository] = {
        if let data = UserDefaults.standard.data(forKey: "watchlist_repositories"), let repos = try? JSONDecoder.init().decode([Repository].self, from: data) {
            return repos
        }
        return []
    }()
    var filteredWatchlistRepos : [Repository]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Watchlist"
        self.setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let addRepoButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(openExploreRepos))
        self.navigationItem.rightBarButtonItem = addRepoButton
        
        let searchController = UISearchController.init()
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
    }
    
    @objc func openExploreRepos() {
        let exploreRepoVC = ExploreRepoViewController.init()
        exploreRepoVC.insertionCallback = { (repo) in
            exploreRepoVC.dismiss(animated: true, completion: nil)
            self.addRepositoryToWatchlist(repo: repo)
        }
        let navigationController = UINavigationController.init(rootViewController: exploreRepoVC)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func addRepositoryToWatchlist(repo: Repository) {
        if self.watchlistRepos.contains(where: { $0.id == repo.id }) {
            let alert = UIAlertController.init(title: "Duplicate", message: "This repository is already available in the watchlist", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.watchlistRepos.append(repo)
        if let data = try? JSONEncoder.init().encode(self.watchlistRepos) {
            UserDefaults.standard.setValue(data, forKey: "watchlist_repositories")
            self.tableView.reloadData()
        }
    }
    
    func removeRepositoryFromWatchList(index: Int) {
        self.watchlistRepos.remove(at: index)
        if let data = try? JSONEncoder.init().encode(self.watchlistRepos) {
            UserDefaults.standard.setValue(data, forKey: "watchlist_repositories")
            self.tableView.reloadData()
        }
    }
}


extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentRepo = self.filteredWatchlistRepos ?? self.watchlistRepos
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = currentRepo[indexPath.row].name
        cell.detailTextLabel?.text = currentRepo[indexPath.row].description
        cell.detailTextLabel?.numberOfLines = 0
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.filteredWatchlistRepos != nil {
            return self.filteredWatchlistRepos!.count
        }
        return self.watchlistRepos.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.removeRepositoryFromWatchList(index: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let infoVC = RepositoryInfoViewController.init(repo: self.watchlistRepos[indexPath.row])
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
}

extension HomeViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.filteredWatchlistRepos = nil
            return
        }
        self.filteredWatchlistRepos = self.watchlistRepos.filter({ $0.name.lowercased().contains(searchText.lowercased()) })
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.filteredWatchlistRepos = nil
    }
}
