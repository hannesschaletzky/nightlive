//
//  BarsViewController.swift
//  nightlive
//
//  Created by Hannes Schaletzky on 27/01/2017.
//  Copyright © 2017 Hannes Schaletzky. All rights reserved.
//

import Foundation

class BarsViewController: UIViewController, IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate {
    
    var isRetrievingItems = true
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Filter
    var filterSet = false
    var amountOfFiltersSet = 0
    
    var gradientLayer: CAGradientLayer!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("barsVC viewDidLoad")
        
        //save this instance to Model
        instance_barsVC = self
        
        createCellHeightsArray()
        
        //Check if clubs are already loaded, if not show activity Indicator
        if allBars.isEmpty {
            activityIndicator.startAnimating()
            isRetrievingItems = true
            instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: 2, enable: false)
        }
        else {
            displayAllBars()
        }
    }
    
    //this is to cover the case when user tapped on a item in the TabBar
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear Bars")
        instance_landingPageVC?.adjustViewToTabBarSelection(newController: self)
        
    }
    
    //MARK: - Logic
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Bars")
    }
    
    
    //MARK: - User Interaction
    
    //MARK: - UI
    func displayAllBars() {
        isRetrievingItems = false
        if !allBars.isEmpty {
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                //Animation
                self.tableView.alpha = 0
                self.tableView.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    self.self.tableView.alpha = 1
                }
            })
        }
        else {
            print("allBars is empty")
        }
    }
    
    
    //MARK: - Table View
    
    let kCloseCellHeight: CGFloat = 170
    let kOpenCellHeight: CGFloat = 350
    
    let kRowsCount = 100
    
    var cellHeights = [CGFloat]()
    
    // MARK: configure
    func createCellHeightsArray() {
        for _ in 0...kRowsCount {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !allBars.isEmpty {
            return allBars.count
        }
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard case let cell as BarsCell = cell else {
            return
        }
        
        cell.backgroundColor = UIColor.clear
        
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight {
            cell.selectedAnimation(false, animated: false, completion:nil)
        } else {
            cell.selectedAnimation(true, animated: false, completion: nil)
        }
        
        //Display Items
        if !allBars.isEmpty {
            let bar = allBars[indexPath.row]
            cell.barNameLabel.text = bar.nightlive_display_name
            cell.attributionTV.text = bar.google_formattedAddress
            
            
            //GRADIENT
            gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.black.cgColor, UIColor.darkRed().cgColor, UIColor.lightGray.cgColor]
            gradientLayer.locations = [0.0, 2.5]
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
            gradientLayer.opacity = 1
            gradientLayer.isOpaque = false
            gradientLayer.frame = cell.foregroundView.bounds
            cell.foregroundView.layer.insertSublayer(gradientLayer, below: cell.barNameLabel.layer)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BarsCell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[(indexPath as NSIndexPath).row]
    }
    
    // MARK: Table vie delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight {
            // open cell
            cellHeights[(indexPath as NSIndexPath).row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            // close cell
            cellHeights[(indexPath as NSIndexPath).row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
        
        
    }

    
    
}
