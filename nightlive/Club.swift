//
//  Club.swift
//  nightlive
//
//  Created by Hannes Schaletzky on 28/03/2017.
//  Copyright © 2017 Hannes Schaletzky. All rights reserved.
//

import Foundation

class Club: Location {
    
    var upcomingEvents = [Event]()
    
    override init(nightlive_display_name: String) {
        super.init(nightlive_display_name: nightlive_display_name)
    }
    
}
