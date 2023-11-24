//
//  versionService.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 20/10/2023.
//

import Foundation

let GITHUB_TOKEN = "Bearer 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"
let BASE_URL = "https://api.github.com/repos/julianitow/SSHTunnelApp/git/"
let REPO_URL = "https://github.com/julianitow/SSHTunnelApp/releases"

struct TAG: Decodable, Equatable {
    let ref: String
    let url: String
    
    func compare(to: TAG) -> TAG {
        let tagVerStrTo = to.ref.split(separator: "/").last!.split(separator: "v").last!.split(separator: ".")
        let tagVerStrSelf = self.ref.split(separator: "/").last!.split(separator: "v").last!.split(separator: ".")
        
        var _tagVerStrTo: [Int] = []
        var _tagVerStrSelf: [Int] = []
        
        for i in 0..<3 {
            _tagVerStrTo.append(Int(tagVerStrTo[i])!)
            _tagVerStrSelf.append(Int(tagVerStrSelf[i])!)
        }
        
        for i in 0..<3 {
            // print("latest: \(_tagVerStrTo[i]) current: \(_tagVerStrSelf[i])")
            if _tagVerStrTo[i] > _tagVerStrSelf[i] {
                return to
            }
        }
        return self
    }
    
    static func == (lhs: TAG, rhs: TAG) -> Bool {
        return lhs.ref.split(separator: "/") == rhs.ref.split(separator: "/")
    }
}

class VersionService {
    
    static let tagsListUrl = URL(string: "\(BASE_URL)refs/tags");
    static var latestTag: TAG? = nil
    static var currentTag = TAG(ref: "/v0.1.7", url: "")

    static func fetchLatestTag(_ callback: @escaping(Bool) -> Void) -> Void {
        var urlRequest = URLRequest(url: tagsListUrl!)
        urlRequest.addValue(GITHUB_TOKEN, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            guard let response = response as? HTTPURLResponse else { return }
            if response.statusCode == 200 {
                guard let data = data else { return }
                do {
                    var latestTag: TAG = currentTag
                    let decodedTags = try JSONDecoder().decode([TAG].self, from: data)
                    for i in 0..<decodedTags.count - 1 {
                        latestTag = decodedTags[i].compare(to: decodedTags[i + 1])
                    }
                    VersionService.latestTag = latestTag
                    callback(!isLatest())
                } catch let error {
                    print("Decoding error: \(error)")
                }
            } else {
                print("NOT 200", response.statusCode)
            }
        }
        dataTask.resume()
    }
    
    static func isLatest() -> Bool {
        let latest = self.currentTag.compare(to: VersionService.latestTag!)
        print(latest.ref)
        if latest == VersionService.currentTag {
            return true
        }
        return false
    }
}
