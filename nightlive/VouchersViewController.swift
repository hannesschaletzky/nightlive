//
//  VouchersViewController.swift
//  nightlive
//
//  Created by Hannes Schaletzky on 27/01/2017.
//  Copyright © 2017 Hannes Schaletzky. All rights reserved.
//

import Foundation

class VouchersViewController: UIViewController, IndicatorInfoProvider {
    
    var isRetrievingItems = true
    //Filter
    var filterSet = false
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("vouchersVC viewDidLoad")
        
        //save this instance to Model
        instance_vouchersVC = self
    }
    
    //this is to cover the case when user tapped on a item in the TabBar
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear Vouchers")
        instance_landingPageVC?.adjustViewToTabBarSelection(newController: self)
    }
    
    //MARK: - User Interaction
    
    //MARK: - Logic
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Vouchers")
    }
    
    
    
}
