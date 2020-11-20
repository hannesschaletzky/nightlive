//
//  EventsCell.swift
//  nightlive
//
//  Created by Hannes Schaletzky on 21/03/2017.
//  Copyright © 2017 Hannes Schaletzky. All rights reserved.
//

import UIKit

class EventsCell: FoldingCell {
    
    var event = Event(nightlive_facebook_id: "...", nightlive_club_visible: false)

    //foreground View - outer Cell
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventClubButton: UIButton!
    @IBOutlet weak var atTimeLabel: UILabel!
    @IBOutlet weak var interestedLabel: UILabel!
    @IBOutlet weak var attendingLabel: UILabel!
    @IBOutlet weak var favoriteButton: DOFavoriteButton!
    
    //inner Cell
    @IBOutlet weak var inner_eventNameLabel: UILabel!
    @IBOutlet weak var inner_eventClubButton: UIButton!
    @IBOutlet weak var inner_atTimeLabel: UILabel!
    @IBOutlet weak var inner_interestedLabel: UILabel!
    @IBOutlet weak var inner_attendingLabel: UILabel!
    @IBOutlet weak var inner_favoriteButton: DOFavoriteButton!
    @IBOutlet weak var inner_event_description: UITextView!
    
    
    override func awakeFromNib() {
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        
        eventClubButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
        inner_eventClubButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }

}
