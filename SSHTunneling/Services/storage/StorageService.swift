//
//  StorageService.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 28/09/2023.
//

import Foundation

class StorageService {
    
    static func erase() -> Void {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue([], forKey: "configs")
    }
    
    static func updateConfig(id: UUID) {
        
    }
    
    static func saveConfig(config: SSHTunnelConfig) -> Void {
        do {
            let userDefaults = UserDefaults.standard
            var configs = try getConfigs()
            if configs.count == 0 {
                configs = []
            }
            configs.append(config)
            let encodedConfigs = try JSONEncoder().encode(configs)
            userDefaults.setValue(encodedConfigs, forKey: "configs")
        } catch {
            print("Error saving configs \(error)")
        }
    }
    
    static func getConfigs() throws -> [SSHTunnelConfig] {
        let userDefaults = UserDefaults.standard
        if let savedData = userDefaults.object(forKey: "configs") as? Data {
            do {
                let savedConfigs = try JSONDecoder().decode([SSHTunnelConfig].self, from: savedData)
                return savedConfigs
            } catch {
                throw error
            }
        }
        return []
    }
}
