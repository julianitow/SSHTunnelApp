//
//  versionService.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 20/10/2023.
//

import Foundation

let BASE_URL = "https://version-server.julianitow.ovh"
let REPO_URL = "https://github.com/julianitow/SSHTunnelApp/releases"

struct TAG: Decodable, Equatable {
    let version: String
    let url: String
    
    func compare(to: TAG) -> TAG {
        let tagVerStrTo = to.version.split(separator: "v").last!.split(separator: ".")
        let tagVerStrSelf = self.version.split(separator: "v").last!.split(separator: ".")
        
        var _tagVerStrTo: [Int] = []
        var _tagVerStrSelf: [Int] = []
        
        for i in 0..<3 {
            _tagVerStrTo.append(Int(tagVerStrTo[i])!)
            _tagVerStrSelf.append(Int(tagVerStrSelf[i])!)
        }
        
        for i in 0..<3 {
            //print("latest: \(_tagVerStrTo[i]) current: \(_tagVerStrSelf[i])")
            if _tagVerStrTo[i] > _tagVerStrSelf[i] {
                return to
            }
        }
        return self
    }
    
    static func == (lhs: TAG, rhs: TAG) -> Bool {
        return lhs.version == rhs.version
    }
}

class VersionService {
    
    static let tagsListUrl = URL(string: "\(BASE_URL)/latest");
    static var latestTag: TAG? = nil
    static var currentTag = TAG(version: "v0.3.2", url: "")

    static func fetchLatestTag(_ callback: @escaping(Bool) -> Void) -> Void {
        let urlRequest = URLRequest(url: tagsListUrl!)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            guard let response = response as? HTTPURLResponse else { return }
            if response.statusCode == 200 {
                guard let data = data else { return }
                do {
                    print(data)
                    let decodedTag = try JSONDecoder().decode(TAG.self, from: data)
                    self.latestTag = self.currentTag.compare(to: decodedTag)
                    VersionService.latestTag = self.latestTag
                    callback(!isLatest())
                } catch let error {
                    print("Decoding error: \(error)")
                }
            }
        }
        dataTask.resume()
    }
    
    static func isLatest() -> Bool {
        if VersionService.latestTag == VersionService.currentTag {
            return true
        }
        return false
    }
}
