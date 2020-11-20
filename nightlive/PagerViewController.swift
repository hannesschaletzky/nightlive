//
//  PagerViewController.swift
//  wasgehtwo
//
//  Created by Hannes Schaletzky on 09/07/16.
//  Copyright © 2016 Hannes Schaletzky. All rights reserved.
//

import UIKit

class PagerViewController: ButtonBarPagerTabStripViewController {
    
    override func viewDidLoad() {
        
        setPagerBarSettings() //before view did load
        
        super.viewDidLoad()
        
        instance_pagerVC = self
    }

    
    func setPagerBarSettings() {
        settings.style.buttonBarBackgroundColor = UIColor.clear
        settings.style.buttonBarItemTitleColor = UIColor.white
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = UIColor.wgwReducedAlphaWhite()
        settings.style.buttonBarItemFont = UIFont(name: "Avenir", size: 18)!
        
        //settings.style.buttonBarItemsShouldFillAvailableWidth = true
        //settings.style.buttonBarRightContentInset = CGFloat(-12)
        //settings.style.buttonBarLeftContentInset = CGFloat(50)
    }
    
    // MARK: - PagerTabStripDataSource
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc_1 = storyboard.instantiateViewController(withIdentifier: "eventsVC")
        let vc_2 = storyboard.instantiateViewController(withIdentifier: "vouchersVC")
        let vc_3 = storyboard.instantiateViewController(withIdentifier: "clubsVC")
        let vc_4 = storyboard.instantiateViewController(withIdentifier: "barsVC")
        let vc_5 = storyboard.instantiateViewController(withIdentifier: "mapVC")
        
        return [vc_1, vc_2, vc_3, vc_4, vc_5]
    }
    
    //to cover the case when user scrolled with finger and didn't scroll until the end, and falls back
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        switch currentIndex {
        case 0:
            instance_landingPageVC?.adjustViewToTabBarSelection(newController: instance_eventsVC!)
            break
        case 1:
            instance_landingPageVC?.adjustViewToTabBarSelection(newController: instance_vouchersVC!)
            break
        case 2:
            instance_landingPageVC?.adjustViewToTabBarSelection(newController: instance_clubsVC!) 
            break
        case 3:
            instance_landingPageVC?.adjustViewToTabBarSelection(newController: instance_barsVC!)
            break
        case 4:
            instance_landingPageVC?.adjustViewToTabBarSelection(newController: instance_mapVC!)
            break
        default:
            break
        }
    }
    
}



