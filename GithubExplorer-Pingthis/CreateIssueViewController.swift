//
//  CreateIssueViewController.swift
//  GithubExplorer-Pingthis
//
//  Created by SathishKumar on 22/04/21.
//

import Foundation
import UIKit

class CreateIssueViewController : UITableViewController {
    
    var insertionCallback : ((Issue?, IssueStatus) -> ())?
    var repositoryName : String
    
    var titleField: UITextField!
    var descriptionTextView: UITextView!
    
    init(repoName: String) {
        self.repositoryName = repoName
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create an issue"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let done = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(createIssue))
        self.navigationItem.rightBarButtonItem = done
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 48
        } else {
            return 150
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell.init(style: .default, reuseIdentifier: nil)
            self.titleField = UITextField.init()
            titleField.placeholder = "Title"
            cell.contentView.addSubview(titleField)
            titleField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                titleField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                titleField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                titleField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                titleField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
            return cell
        } else {
            let cell = UITableViewCell.init(style: .default, reuseIdentifier: nil)
            self.descriptionTextView = UITextView.init()
            descriptionTextView.backgroundColor = UIColor.secondarySystemBackground
            descriptionTextView.font = UIFont.systemFont(ofSize: 16)
            cell.contentView.addSubview(descriptionTextView)
            descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                descriptionTextView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                descriptionTextView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                descriptionTextView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                descriptionTextView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Description"
        }
        return ""
    }
    
    @objc func createIssue() {
        if self.titleField.text == nil { return }
        if self.titleField.text!.isEmpty {
            //Show alert
            return
        }
        NetworkRequest.main.createRepoIssue(name: self.repositoryName, title: self.titleField.text!, description: self.descriptionTextView.text) { (issue, status) in
            DispatchQueue.main.async {
                self.insertionCallback?(issue, status)
            }
        }
    }
}

enum IssueStatus {
    case SUCCESS
    case FORBIDDEN
    case FAILED
}
