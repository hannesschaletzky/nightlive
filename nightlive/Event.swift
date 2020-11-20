//
//  Event.swift
//  wasgehtwo
//
//  Created by Hannes Schaletzky on 20/06/16.
//  Copyright © 2016 Hannes Schaletzky. All rights reserved.
//

import Foundation

class Event {
    
    var nightlive_facebook_id: String //mandatory
    var nightlive_club_visible: Bool //mandatory
    var nightlive_club_display_name: String?
    var nightlive_club_googlePlaceID: String?
    
    
    var facebook_name: String?
    var facebook_description: String?
    var facebook_start_time: String?
    var facebook_end_time: String?
    var facebook_interested_count: Int32?
    var facebook_attending_count: Int32?
    var is_canceled: Bool?
    var facebook_cover: [Any]? //Cover Photo
    var facebook_place: [Any]? //Location
    
    //for sorting reasons
    var compareDateStartTime: Date?
    
    init(nightlive_facebook_id: String, nightlive_club_visible: Bool) {
        self.nightlive_facebook_id = nightlive_facebook_id
        self.nightlive_club_visible = nightlive_club_visible
    }
    
    
}
