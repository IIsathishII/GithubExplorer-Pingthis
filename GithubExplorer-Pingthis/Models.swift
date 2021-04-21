//
//  Models.swift
//  GithubExplorer-Pingthis
//
//  Created by SathishKumar on 21/04/21.
//

import Foundation

struct Repository : Codable {
    var id: String
    var name : String
    var description : String?
}
