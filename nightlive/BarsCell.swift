//
//  BarsCell.swift
//  nightlive
//
//  Created by Hannes Schaletzky on 27/03/2017.
//  Copyright © 2017 Hannes Schaletzky. All rights reserved.
//

import UIKit

class BarsCell: FoldingCell {
    
    @IBOutlet weak var barNameLabel: UILabel!
    @IBOutlet weak var openNowLabel: UILabel!
    @IBOutlet weak var attributionTV: UITextView!
    
    override func awakeFromNib() {
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        
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
