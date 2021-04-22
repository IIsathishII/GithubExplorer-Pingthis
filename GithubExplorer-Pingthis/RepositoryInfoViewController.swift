//
//  RepositoryInfoViewController.swift
//  GithubExplorer-Pingthis
//
//  Created by SathishKumar on 22/04/21.
//

import Foundation
import UIKit

class RepositoryInfoViewController : UITableViewController {
    
    var repository : Repository
    
    init(repo: Repository) {
        self.repository = repo
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let group = DispatchGroup.init()
        group.enter()
        NetworkRequest.main.getRepoIssues(name: self.repository.name) { (issues) in
            DispatchQueue.main.async {
                self.repository.issues = issues
                group.leave()
            }
        }
        group.enter()
        NetworkRequest.main.getRepoPullRequests(name: self.repository.name) { (count) in
            DispatchQueue.main.async {
                self.repository.pullRequestCount = count
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = repository.name
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if let count = self.repository.issues?.count {
                return min(count, 5)+1
            }
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell.init(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = "Open PR's"
            cell.selectionStyle = .none
            if let count = self.repository.pullRequestCount {
                cell.detailTextLabel?.text = "\(count)"
            } else {
                cell.detailTextLabel?.text = "--"
            }
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = UITableViewCell.init(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = "Create a new issue"
                cell.separatorInset = .zero
                return cell
            } else {
                let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: nil)
                cell.selectionStyle = .none
                cell.textLabel?.text = self.repository.issues![indexPath.row-1].title
                cell.detailTextLabel?.text = self.repository.issues![indexPath.row-1].description
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row == 0 && indexPath.section == 1 else { return }
        let createVC = CreateIssueViewController.init(repoName: self.repository.name)
        createVC.insertionCallback = { (issue, status) in
            createVC.dismiss(animated: true, completion: nil)
            guard issue != nil else {
                self.showIssueFailedAlert(status: status)
                return
            }
            if self.repository.issues == nil {
                self.repository.issues = []
            }
            self.repository.issues?.insert(issue!, at: 0)
            self.tableView.reloadData()
        }
        let navigationController = UINavigationController.init(rootViewController: createVC)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func showIssueFailedAlert(status: IssueStatus) {
        if status == .FAILED {
            let alert = UIAlertController.init(title: "Failed!", message: "Creating an issue failed for some reason.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if status == .FORBIDDEN {
            let alert = UIAlertController.init(title: "Failed!", message: "Creating an issue is not allowed for this repo.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        return
    }
}
