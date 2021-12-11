//
//  InfosRefresh.swift
//
//  Created by Cyril DELAMARE on 01/11/2019.
//  Copyright © 2019 Cyril DELAMARE. All rights reserved.
//

import Foundation


public struct InfosRefresh:Codable {
    public var refreshDates: Date
    public var refreshIMDB: Date
    public var refreshViewed: Date


    public init(refreshDates: Date, refreshIMDB: Date, refreshViewed: Date) {
        self.refreshDates = refreshDates
        self.refreshIMDB = refreshIMDB
        self.refreshViewed = refreshViewed
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(refreshDates, forKey: .refreshDates)
        try container.encode(refreshIMDB, forKey: .refreshIMDB)
        try container.encode(refreshViewed, forKey: .refreshViewed)
    }
}
