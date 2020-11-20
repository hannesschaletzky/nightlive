//
//  LandingPageViewController.swift
//  nightlive
//
//  Created by Hannes Schaletzky on 27/01/2017.
//  Copyright © 2017 Hannes Schaletzky. All rights reserved.
//

import UIKit

class LandingPageViewController: UIViewController, UISearchBarDelegate {
    
    //MENU
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuViewHeightConstraint: NSLayoutConstraint!
    fileprivate var menuIsVisible = false
    fileprivate var menuHeight:CGFloat = 0
    @IBOutlet weak var menu_logoutButton: UIButton!
    
    //Container
    @IBOutlet weak var containerView: UIView!
    fileprivate var containerViewIsUp = true
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerSwipeUpView: UIView! 
    
    var slideConstantCalendar: CGFloat = 0
    var slideConstantCityFilter: CGFloat = 0
    let weekdayNumberStringDict = [1:"Mo",2:"Di",3:"Mi",4:"Do",5:"Fr",6:"Sa",7:"So"]
    let alphaValue = CGFloat(0.25)
    
    //Buttons in Panel
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    var lastButtonPressed = UIButton()
    
    //CityView
    @IBOutlet weak var cityView: UIView!
    
    //CalendarView
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    let testCalendar: Calendar! = Calendar(identifier: Calendar.Identifier.gregorian) //for Monthlabel
    let white = UIColor(colorWithHexValue: 0xECEAED)
    let darkPurple = UIColor(colorWithHexValue: 0x3A284C)
    let dimPurple = UIColor(colorWithHexValue: 0x574865)
    @IBOutlet weak var calendarViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var weekdayView: UIView!
    var newDateSelected = false
    
    //FilterView
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterScrollView: UIScrollView!
    @IBOutlet weak var removeAllButton: UIButton!
    @IBOutlet weak var filterViewHeightConstraint: NSLayoutConstraint!
    var eventsFilterView = UIView()
    var vouchersFilterView = UIView()
    var clubsFilterView = UIView()
    var barsFilterView = UIView()
    var mapFilterView = UIView()
    var searchFilterView = UIView()
    
    
    //EventsFilterView
    @IBOutlet weak var filterEvents_AscendingSortSegmentedControl: UISegmentedControl!
    
    
    
    //VouchersFilterView
    
    
    
    //ClubsFilterView
    @IBOutlet weak var filterClubs_openSegCon: UISegmentedControl!
    @IBOutlet weak var filterClubs_happyhourSegCon: UISegmentedControl!
    
    
    
    //BarsFilterView
    
    //MapFilterView
    @IBOutlet weak var filterMap_locationTypeSegCon: UISegmentedControl!
    @IBOutlet weak var filterMap_openSegCon: UISegmentedControl!
    @IBOutlet weak var filterMap_happyHourSegCon: UISegmentedControl!
    
    @IBOutlet weak var filterMap_radiusLabel: UILabel!
    @IBOutlet weak var filterMap_radiusSlider: UISlider!
    
    //Search
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    let searchButtonDummy = UIButton()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var searchResults = [(String,String)]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //save this instance to Model
        instance_landingPageVC = self
        
        //UI - NavigationBar
        setNavBarAppearance()
        
        //UI- Calendar
        containerViewHeightConstraint.constant = containerView.bounds.height //wegen anderen Device Modellen
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.cellInset = CGPoint(x: 0, y: 0)
        calendarView.calendarView.bounces = false
        calendarView.registerCellViewXib(file: "CellView") // Registering your cell is mandatory
        setMonthLabelWithDate(date: Date()) //today
        
        if dateIsInTheMiddleOfTheNight(date: Date()) { //if current time is in the middle of night
            let date = Date().addingTimeInterval(60*60*24 * -1)
            calendarView.selectDates(from: date, to: date)
        }
        else {
            let today = Date()
            calendarView.selectDates(from: today, to: today)
        }
        
        //Swipe Up CalendarView
        let swipeUpCalendar = UISwipeGestureRecognizer(target: self, action:#selector(handleSwipeUpGestureCalendar))
        swipeUpCalendar.direction = UISwipeGestureRecognizerDirection.up
        calendarView.addGestureRecognizer(swipeUpCalendar)
        
        //Swipe Up ContainerView
        let swipeUpContainer = UISwipeGestureRecognizer(target: self, action:#selector(handleSwipeUpGestureContainer))
        swipeUpContainer.direction = UISwipeGestureRecognizerDirection.up
        containerSwipeUpView.addGestureRecognizer(swipeUpContainer)
        
        //instantiate Filters
        eventsFilterView = UINib(nibName: "EventsFilterView", bundle: nil).instantiate(withOwner: instance_landingPageVC, options: nil)[0] as! UIView
        vouchersFilterView = UINib(nibName: "VouchersFilterView", bundle: nil).instantiate(withOwner: instance_landingPageVC, options: nil)[0] as! UIView
        clubsFilterView = UINib(nibName: "ClubsFilterView", bundle: nil).instantiate(withOwner: instance_landingPageVC, options: nil)[0] as! UIView
        barsFilterView = UINib(nibName: "BarsFilterView", bundle: nil).instantiate(withOwner: instance_landingPageVC, options: nil)[0] as! UIView
        mapFilterView = UINib(nibName: "MapFilterView", bundle: nil).instantiate(withOwner: instance_landingPageVC, options: nil)[0] as! UIView
        searchFilterView = UINib(nibName: "FilterSearchView", bundle: nil).instantiate(withOwner: instance_landingPageVC, options: nil)[0] as! UIView
        
        //UI Filters
        //EventsFilterView
        filterEvents_AscendingSortSegmentedControl.selectedSegmentIndex = 2
        
        //VouchersFilterView
        
        //ClubsFilterView
        filterClubs_openSegCon.selectedSegmentIndex = 2
        filterClubs_happyhourSegCon.selectedSegmentIndex = 2
        
        //BarsFilterView
        
        //Search
        searchBar.delegate = self
        searchView.addSubview(searchFilterView) 
        searchView.bounds.size = searchFilterView.bounds.size
        searchButtonDummy.tag = -1
        searchBar.returnKeyType = UIReturnKeyType.done
        
        //fetch Data
        setDateVariablesForHappyHourAndOpeningHourToCurrent()
        instance_eventsVC?.fetchEvents() //Events
        retrievePlaceIDsFromNightliveFor(isRequestForClubs: true) //Clubs
        retrievePlaceIDsFromNightliveFor(isRequestForClubs: false) //Bars
    }
    
    

    //MARK: - User Interaction
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        logoutUser()
    }
    
    @IBAction func menuButtonPressed() {
        print("Menu Button Pressed")
        
        if menuIsVisible {
            menuViewHeightConstraint.constant = 0
            menuIsVisible = false
            menu_logoutButton.isHidden = true
        }
        else {
            menuViewHeightConstraint.constant = view.layer.bounds.height
            menuIsVisible = true
            menu_logoutButton.isHidden = false
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    @IBAction func cityButtonPressed(_ sender: UIButton) {
        
        if lastButtonPressed == sender {
            //isClosing
            lastButtonPressed = UIButton()
            enableDisableCorrectButtons()
            containerSwipeUpView.isHidden = true
        }
        else {
            //isOpening
            lastButtonPressed = sender
            disableButtonsExceptForButtonWithTag(tag: sender.tag)
            containerSwipeUpView.isHidden = false
        }
        
        cityView.isHidden = false
        calendarView.isHidden = true
        filterView.isHidden = true
        searchView.isHidden = true
        slideContainer(isCalendar: false)
    }
    
    @IBAction func dateButtonPressed(_ sender: UIButton) {
        
        var isClosingClick = false
        
        if lastButtonPressed == sender {
            //isClosing
            lastButtonPressed = UIButton()
            enableDisableCorrectButtons()
            isClosingClick = true
            containerSwipeUpView.isHidden = true
        }
        else {
            //isOpening
            monthLabel.isHidden = false
            weekdayView.isHidden = false
            lastButtonPressed = sender
            disableButtonsExceptForButtonWithTag(tag: sender.tag)
            containerSwipeUpView.isHidden = false
        }
        
        cityView.isHidden = true
        calendarView.isHidden = false
        filterView.isHidden = true
        searchView.isHidden = true
        slideContainer(isCalendar: true)
        
        if isClosingClick && newDateSelected {
            disableButtonsExceptForButtonWithTag(tag: 3) //disable all
            instance_eventsVC?.fetchEvents()
        }
        newDateSelected = false
    }
    
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        
        if lastButtonPressed == sender {
            //isClosing
            lastButtonPressed = UIButton()
            enableDisableCorrectButtons()
            containerSwipeUpView.isHidden = true
        }
        else {
            //isOpening
            lastButtonPressed = sender
            disableButtonsExceptForButtonWithTag(tag: sender.tag)
            containerSwipeUpView.isHidden = false
        }
        
        cityView.isHidden = true
        calendarView.isHidden = true
        filterView.isHidden = false
        searchView.isHidden = true
        slideContainer(isCalendar: false)
    }
    
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        
        if lastButtonPressed == searchButtonDummy {
            //isClosing
            lastButtonPressed = UIButton()
            enableDisableCorrectButtons()
            containerSwipeUpView.isHidden = true
            view.endEditing(true)
        }
        else {
            //isOpening
            monthLabel.isHidden = true
            weekdayView.isHidden = true
            lastButtonPressed = searchButtonDummy
            disableButtonsExceptForButtonWithTag(tag: searchButtonDummy.tag)
            containerSwipeUpView.isHidden = false
            //Clear Seach Result Table View
            searchBar.text = ""
            searchResults.removeAll()
            tableView.reloadData()
            searchBar.becomeFirstResponder()
        }
        
        cityView.isHidden = true
        calendarView.isHidden = true
        filterView.isHidden = true
        searchView.isHidden = false
        slideContainer(isCalendar: false)
    }
    
    @IBAction func removeAllFiltersPressed(_ sender: UIButton) {
        if global_activeController == instance_eventsVC {
            filterEvents_AscendingSortSegmentedControl.selectedSegmentIndex = 2
            instance_eventsVC?.removeAllFilters()
        }
        
        if global_activeController == instance_clubsVC {
            filterClubs_openSegCon.selectedSegmentIndex = 2
            filterClubs_happyhourSegCon.selectedSegmentIndex = 2
            instance_clubsVC?.removeAllFilters()
        }
        if global_activeController == instance_mapVC {
            filterMap_locationTypeSegCon.selectedSegmentIndex = 2
            filterMap_openSegCon.selectedSegmentIndex = 2
            filterMap_happyHourSegCon.selectedSegmentIndex = 2
            filterMap_radiusSlider.value = 0.0
            filterMap_radiusLabel.text = "Umkreis: kein Filter"
            instance_mapVC?.removeAllFilters()
        }
    }
    
    //this is target function os swipeUpCalendar
    @objc func handleSwipeUpGestureCalendar() {
        dateButtonPressed(dateButton)
    }
    
    //this is target function os swipeUpContainer
    @objc func handleSwipeUpGestureContainer() {
        if lastButtonPressed == cityButton {
            cityButtonPressed(cityButton)
        }
        else if lastButtonPressed == dateButton {
            dateButtonPressed(dateButton)
        }
        else if lastButtonPressed == filterButton {
            filterButtonPressed(filterButton)
        }
        else if lastButtonPressed == searchButtonDummy {
            searchButtonPressed(searchButton)
        }
        
    }
    
    //MARK: - Filters
    //EVENTSFILTER
    @IBAction func filterEvents_setFilter() {
        let result = filterEvents_readFilterSelection()
        instance_eventsVC?.filterBy(name: "noFilter", sortAscending: result)
    }
    
    func filterEvents_readFilterSelection() -> String {
        let index_sortAscending = filterEvents_AscendingSortSegmentedControl.selectedSegmentIndex
        
        var sortAscendingString = "noFilter"
        
        if index_sortAscending == 0 {
            sortAscendingString = "att"
        }
        else if index_sortAscending == 1 {
            sortAscendingString = "int"
        }
        
        return sortAscendingString
    }
    
    //VOUCHERSFILTER
    
    
    
    //CLUBSFILTER
    @IBAction func filterClubs_setFilter() {
        setDateVariablesForHappyHourAndOpeningHourToCurrent()
        let result = filterClubs_readFilterSelection()
        instance_clubsVC?.filterBy(name: "noFilter", open: result.0, happyHour: result.1)
    }
    
    func filterClubs_readFilterSelection() -> (String,String) {
        let index_Open = filterClubs_openSegCon.selectedSegmentIndex
        let index_HappyHour = filterClubs_happyhourSegCon.selectedSegmentIndex
        
        var openString = "noFilter"
        var happyHourString = "noFilter"
        
        if index_Open == 0 {
            openString = "today"
        }
        else if index_Open == 1 {
            openString = "now"
        }
        
        if index_HappyHour == 0 {
            happyHourString = "today"
        }
        else if index_HappyHour == 1 {
            happyHourString = "now"
        }
        
        
        return (openString,happyHourString)
    }
    
    
    
    
    //BARSFILTER
    
    
    //MAPFILTER
    func setMapFilter() { 
        setDateVariablesForHappyHourAndOpeningHourToCurrent()
        let result = filterMap_readFilterSelection()
        instance_mapVC?.filterBy(name: "noFilter", type: result.0, open: result.1, happyHour: result.2, radius: result.3)
    }
    
    func filterMap_readFilterSelection() -> (String,String,String,Double) {
        let index_Type = filterMap_locationTypeSegCon.selectedSegmentIndex
        let index_Open = filterMap_openSegCon.selectedSegmentIndex
        let index_HappyHour = filterMap_happyHourSegCon.selectedSegmentIndex
        
        var typeString = "noFilter"
        var openString = "noFilter"
        var happyHourString = "noFilter"
        var radius = Double(filterMap_radiusSlider.value)*1000 //km to meter
        
        if index_Type == 0 {
            typeString = "clubs"
        }
        else if index_Type == 1 {
            typeString = "bars"
        }
        
        if index_Open == 0 {
            openString = "today"
        }
        else if index_Open == 1 {
            openString = "now"
        }
        
        if index_HappyHour == 0 {
            happyHourString = "today"
        }
        else if index_HappyHour == 1 {
            happyHourString = "now"
        }
        
        if radius == 0 {
            radius = -1.0 //no Radius filter Set
        }
        
        
        return (typeString,openString,happyHourString,radius)
        
    }
    
    //combine three functions to one
    @IBAction func mapFilter_LocationTypePressed(_ sender: UISegmentedControl) {
        setMapFilter()
    }
    
    @IBAction func mapFilter_OpenPressed(_ sender: UISegmentedControl) {
        setMapFilter()
    }
    
    @IBAction func mapFilter_HappyHourPressed(_ sender: UISegmentedControl) {
        setMapFilter()
    }
    
    @IBAction func radiusSliderTouchUp(_ sender: UISlider) {
        //set Filter with new radius
        print(sender.value)
        if sender.value != 0.0 {
            if isAppAuthorizedToUseLocation() {
                //go to Map and set Filter
                setMapFilter()
            }
            else {
                locationManager?.requestWhenInUseAuthorization()
                if didUserDenyLocationServices() {
                    let ac = UIAlertController(title: "Hinweis", message: "Sie müssen nightlive Ihre Erlaubnis zur Standortfreigabe in den Einstellungen ihres iPhones erteilen", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }
        else if sender.value == 0.0 {
            setMapFilter()
        }
    }
    
    @IBAction func radiusSliderValueChanged(_ sender: UISlider) {
        let value = sender.value
        if value == 0.0 {
            filterMap_radiusLabel.text = "Umkreis: kein Filter"
        }
        else {
            let roundedValue = Double(value).roundTo(places: 2)
            filterMap_radiusLabel.text = "Umkreis: \(roundedValue)km" 
        }
        
        
    }
    
    //GENERAL
    func setAllFilterToNoneFromFilterView(vc: UIViewController) {
        if vc == instance_eventsVC {
            filterEvents_AscendingSortSegmentedControl.selectedSegmentIndex = 2
        }
        else if vc == instance_vouchersVC {
            
        }
        else if vc == instance_clubsVC {
            filterClubs_openSegCon.selectedSegmentIndex = 2
            filterClubs_happyhourSegCon.selectedSegmentIndex = 2
        }
        else if vc == instance_barsVC {
            
        }
        else if vc == instance_mapVC {
            
        }
    }
    
    
    //MARK: - Logic
    func logoutSuccess() {
        //dismiss(animated: true) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let userVC = storyboard.instantiateViewController(withIdentifier: "userVC")
            let topController = self.getTopMostController()
            
            topController.present(userVC, animated: true, completion: nil)
        //}
    }
    
    func logoutError() {
        
    }
    
    func getTopMostController() -> UIViewController {
        //avoid the error: whose view is not in the window hierarchy
        var topController = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }
    
    //MARK: - UI
    //for city and filter view
    func slideContainer(isCalendar: Bool) {
        var constantCalendar:CGFloat = 0
        var constantCityFilter:CGFloat = 0
        if isCalendar {
            constantCalendar = calendarView.bounds.height + (calendarViewTopConstraint.constant - containerViewTopConstraint.constant)
        }
        else {
            constantCityFilter = filterView.bounds.height + (calendarViewTopConstraint.constant - containerViewTopConstraint.constant)
        }
        if slideConstantCalendar == 0 {
            slideConstantCalendar = CGFloat(constantCalendar)
        }
        if slideConstantCityFilter == 0 {
            slideConstantCityFilter = CGFloat(constantCityFilter)
        }
        
        if containerViewIsUp {
            if isCalendar {
                containerViewTopConstraint.constant += slideConstantCalendar
            }
            else {
                containerViewTopConstraint.constant += slideConstantCityFilter
            }
            
            containerViewBottomConstraint.isActive = false
            containerViewIsUp = false
        }
        else {
            if isCalendar {
                containerViewTopConstraint.constant -= slideConstantCalendar
            }
            else {
                containerViewTopConstraint.constant -= slideConstantCityFilter
            }
            containerViewBottomConstraint.isActive = true
            containerViewIsUp = true
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func setDateButtonTitle() {
        let comp = getComponentsOfDate(dateToWorkWith)
        let title = "\(comp.day!).\(comp.month!).\(comp.year!)"
        dateButton.setTitle(title, for: .normal)
    }
    
    func setNavBarAppearance() {
        let navBar = self.navigationController?.navigationBar
        navBar?.barStyle = UIBarStyle.blackTranslucent
        
        //WORKS, makes NavBar completely translucent
        //navBar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //navBar?.shadowImage = UIImage()
        //navBar?.alpha = 0.0
        
    }
    
    func changeEnableStateForButtonWithTag(tag: Int, enable: Bool) {
        switch tag {
        case -1: //search
            /*if enable {
                searchButton.alpha = 1
            }
            else {
                cityButton.alpha = alphaValue
            }*/
            searchButton.isEnabled = enable 
            break
        case 0: //city
            if enable {
                cityButton.alpha = 1
            }
            else {
                cityButton.alpha = alphaValue
            }
            cityButton.isEnabled = enable
            break
            
        case 1: //date
            if enable {
                dateButton.alpha = 1
            }
            else {
                dateButton.alpha = alphaValue
            }
            dateButton.isEnabled = enable
            break
            
        case 2: //filter
            if enable {
                filterButton.alpha = 1
            }
            else {
                filterButton.alpha = alphaValue
            }
            filterButton.isEnabled = enable
            break
            
        default:
            break
        }
    }
    
    func disableButtonsExceptForButtonWithTag(tag: Int) {
        
        switch tag {
        case -1: //search
            cityButton.isEnabled = false
            dateButton.isEnabled = false
            filterButton.isEnabled = false
            cityButton.alpha = alphaValue
            dateButton.alpha = alphaValue
            filterButton.alpha = alphaValue
            break
        case 0: //city
            dateButton.isEnabled = false
            filterButton.isEnabled = false
            searchButton.isEnabled = false
            dateButton.alpha = alphaValue
            filterButton.alpha = alphaValue
            break
            
        case 1: //date
            cityButton.isEnabled = false
            filterButton.isEnabled = false
            searchButton.isEnabled = false
            cityButton.alpha = alphaValue
            filterButton.alpha = alphaValue 
            break
            
        case 2: //filter
            cityButton.isEnabled = false
            dateButton.isEnabled = false
            searchButton.isEnabled = false
            cityButton.alpha = alphaValue
            dateButton.alpha = alphaValue
            break
        case 3:
            //disable all
            cityButton.isEnabled = false
            dateButton.isEnabled = false
            filterButton.isEnabled = false
            searchButton.isEnabled = false
            cityButton.alpha = alphaValue
            dateButton.alpha = alphaValue
            filterButton.alpha = alphaValue
        default:
            break
        }
    }
    
    func enableButtons() {
        cityButton.isEnabled = true
        dateButton.isEnabled = true
        filterButton.isEnabled = true
        searchButton.isEnabled = true
        cityButton.alpha = 1
        dateButton.alpha = 1
        filterButton.alpha = 1
    }
    
    func setFilterButtonStateTo(filterSet: Bool) {
        if filterSet {
            filterButton.setImage(UIImage(named: "Filter_Active"), for: UIControlState.selected)
            filterButton.setImage(UIImage(named: "Filter_Active"), for: UIControlState.normal)
        }
        else {
            filterButton.setImage(UIImage(named: "Filter"), for: UIControlState.selected)
            filterButton.setImage(UIImage(named: "Filter"), for: UIControlState.normal)
        }
    }
    
    func showCorrectFilterScrollView(newController: UIViewController) {
        
        //clear FilterScrollView
        eventsFilterView.removeFromSuperview()
        vouchersFilterView.removeFromSuperview()
        clubsFilterView.removeFromSuperview()
        barsFilterView.removeFromSuperview()
        mapFilterView.removeFromSuperview() 
        
        //set correct FilterView
        if newController is EventsViewController {
            filterScrollView.addSubview(eventsFilterView)
            filterScrollView.contentSize = eventsFilterView.bounds.size
        }
        else if newController is VouchersViewController {
            filterScrollView.addSubview(vouchersFilterView)
            filterScrollView.contentSize = vouchersFilterView.bounds.size
        }
        else if newController is ClubsViewController {
            filterScrollView.addSubview(clubsFilterView)
            filterScrollView.contentSize = clubsFilterView.bounds.size
        }
        else if newController is BarsViewController {
            filterScrollView.addSubview(barsFilterView)
            filterScrollView.contentSize = barsFilterView.bounds.size
        }
        else if newController is MapViewController {
            filterScrollView.addSubview(mapFilterView)
            filterScrollView.contentSize = mapFilterView.bounds.size
        }
        
        //scrollToTop
        filterScrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
    
    
    
    func enableDisableCorrectButtons() {
        
        //CityButton
        instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: 0, enable: true)
        
        if global_activeController == instance_eventsVC {
            //SearchButton
            instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: -1, enable: true)
            //CalendarButton
            instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: 1, enable: true)
            //FilterButton
            if !(instance_eventsVC?.isRetrievingItems)! {
                if !allFBEvents.isEmpty {
                    changeEnableStateForButtonWithTag(tag: 2, enable: true)
                    setFilterButtonStateTo(filterSet: (instance_eventsVC?.filterSet)!)
                }
                else {
                    //has no Items
                    changeEnableStateForButtonWithTag(tag: 2, enable: false)
                }
            }
            else {
                //isRetrievingItems
                changeEnableStateForButtonWithTag(tag: 2, enable: false)
            }
        }
        else if global_activeController == instance_vouchersVC {
            //SearchButton
            instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: -1, enable: true)
            //CalendarButton
            instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: 1, enable: true)
            //FilterButton
            changeEnableStateForButtonWithTag(tag: 2, enable: false)
            setFilterButtonStateTo(filterSet: false)
            
            
        }
        else if global_activeController == instance_clubsVC {
            //SearchButton
            instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: -1, enable: true)
            //CalendarButton
            instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: 1, enable: false)
            //FilterButton
            if !(instance_clubsVC?.isRetrievingItems)! {
                if !allClubs.isEmpty {
                    changeEnableStateForButtonWithTag(tag: 2, enable: true)
                    setFilterButtonStateTo(filterSet: (instance_clubsVC?.filterSet)!)
                }
                else {
                    //has no Items
                    changeEnableStateForButtonWithTag(tag: 2, enable: false)
                }
            }
            else {
                //isRetrievingItems
                changeEnableStateForButtonWithTag(tag: 2, enable: false)
            }
            
        }
        else if global_activeController == instance_barsVC {
            //SearchButton
            instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: -1, enable: true)
            //CalendarButton
            instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: 1, enable: false)
            //FilterButton
            if !(instance_barsVC?.isRetrievingItems)! {
                if !allBars.isEmpty {
                    changeEnableStateForButtonWithTag(tag: 2, enable: true)
                    setFilterButtonStateTo(filterSet: (instance_barsVC?.filterSet)!)
                }
                else {
                    //has no Items
                    changeEnableStateForButtonWithTag(tag: 2, enable: false)
                }
            }
            else {
                //isRetrievingItems
                changeEnableStateForButtonWithTag(tag: 2, enable: false)
            }
        }
        else if global_activeController == instance_mapVC {
            //SearchButton
            instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: -1, enable: true)
            //CalendarButton
            instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: 1, enable: false)
            //FilterButton
            if !(instance_mapVC?.isRetrievingItems)! {
                if !clubAnnotations.isEmpty || !barAnnotations.isEmpty {
                    changeEnableStateForButtonWithTag(tag: 2, enable: true)
                    setFilterButtonStateTo(filterSet: (instance_mapVC?.filterSet)!)
                }
                else {
                    //has no Items
                    changeEnableStateForButtonWithTag(tag: 2, enable: false)
                }
            }
            else {
                //isRetrievingItems
                changeEnableStateForButtonWithTag(tag: 2, enable: false)
            }
        }
    }
    
    
    func adjustViewToTabBarSelection(newController: UIViewController) {
        
        if global_activeController == newController {
            //when you change by swipe, it will get called from didEndDecelerating and viewDidappear, so only do one time
            print("return")
            return
        }
        
        showCorrectFilterScrollView(newController: newController)
        
        switch newController {
        case is EventsViewController:
            global_activeController = instance_eventsVC!
            print("Current active ViewController in TabBar: Events")
            break
        case is VouchersViewController:
            global_activeController = instance_vouchersVC!
            print("Current active ViewController in TabBar: Vouchers")
            
            break
        case is ClubsViewController:
            global_activeController = instance_clubsVC!
            print("Current active ViewController in TabBar: Clubs")
            
            break
        case is BarsViewController:
            global_activeController = instance_barsVC!
            print("Current active ViewController in TabBar: Bars")
            
            break
        case is MapViewController:
            global_activeController = instance_mapVC!
            print("Current active ViewController in TabBar: Map")
            
            break
        default:
            break
        }
        
        enableDisableCorrectButtons()
        
    }
    
}

//MARK: - Calendar
extension LandingPageViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        //let startDate = formatter.date(from: "2016 02 01")! // You can use date generated from a formatter
        //let endDate = Date()                                // You can also use dates created from this function
        
        let startDate = Date().addingTimeInterval(60*60*24 * -1) //starts one day before today
        let dateTwoYearsAfter = Date().addingTimeInterval(Double(60*60*24*7*365*2))
        let endDate = dateTwoYearsAfter
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6, // Only 1, 2, 3, & 6 are allowed
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfGrid ,
            firstDayOfWeek: .monday)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        let myCustomCell = cell as! CellView
        
        // Setup Cell text
        myCustomCell.dayLabel.text = cellState.text
        handleCellTextColor(view: cell, cellState: cellState)
        
        handleCellSelection(view: cell, cellState: cellState) //single Selection
        //handleSelection(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellTextColor(view: cell, cellState: cellState)
        
        handleCellSelection(view: cell, cellState: cellState) //singleSelection
        //handleSelection(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellTextColor(view: cell, cellState: cellState)
        
        handleCellSelection(view: cell, cellState: cellState) //singleSelection
        //handleSelection(cell: cell, cellState: cellState)
    }
    
    // Function to handle the text color of the calendar
    func handleCellTextColor(view: JTAppleDayCellView?, cellState: CellState) {
        
        guard let myCustomCell = view as? CellView  else {
            return
        }
        
        if cellState.isSelected {
            myCustomCell.dayLabel.textColor = darkPurple
            myCustomCell.isHidden = false
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dayLabel.textColor = UIColor.lightGray
                myCustomCell.isUserInteractionEnabled = true
            }
            else {
                myCustomCell.dayLabel.textColor = UIColor.wgwLowAlphaWhite()
                myCustomCell.isUserInteractionEnabled = true
            }
            
            let hideDate = checkIfDateOfCalendarHasToBeHidden(currentDate: Date(), cellDate: cellState.date)
            if hideDate {
                myCustomCell.dayLabel.textColor = UIColor.clear
                myCustomCell.isUserInteractionEnabled = false
            }
        }
    }
    
    func checkIfDateOfCalendarHasToBeHidden(currentDate: Date, cellDate: Date) -> Bool {
        
        let compCurrent = getComponentsOfDate(currentDate)
        let compCellDate = getComponentsOfDate(cellDate)
        
        let currentDay = compCurrent.day!
        let currentMonth = compCurrent.month!
        let currentYear = compCurrent.year!
        let cellDay = compCellDate.day!
        let cellMonth = compCellDate.month!
        let cellYear = compCellDate.year!
        
        let oneDayBeforeCurrent = currentDate.addingTimeInterval(60*60*24 * -1) //one day before today
        let compOfOneDayBeforeCurrent = getComponentsOfDate(oneDayBeforeCurrent)
        
        var hideDate = false
        
        if compOfOneDayBeforeCurrent.day! == cellDay && compOfOneDayBeforeCurrent.month! == cellMonth && compOfOneDayBeforeCurrent.year! == cellYear {
            //don't hide, because it's day before today
        }
        else if currentDay == cellDay && currentMonth == cellMonth && currentYear == cellYear {
            //don't hide, because it's day today
            
        }
        else if currentYear == cellYear && currentMonth == cellMonth && cellDay > currentDay {
            //don't hide, because it's all days left in the month that are in the future
        }
        else if currentYear == cellYear && currentMonth < cellMonth {
            //don't hide, because it's all months left in this year that are in the future
        }
        else if currentYear < cellYear {
            //don't hide, because it's all days in the next year
        }
        else {
            hideDate = true
        }
        
        return hideDate
        
    }

    
    //Single Selection
    func handleCellSelection(view: JTAppleDayCellView?, cellState: CellState) {
        guard let myCustomCell = view as? CellView  else {
            return
        }
        if cellState.isSelected {
            //myCustomCell.selectedView.layer.cornerRadius = 25
            myCustomCell.selectedView.isHidden = false
            dateToWorkWith = cellState.date
            setDateButtonTitle()
            newDateSelected = true
            
        } else {
            myCustomCell.selectedView.isHidden = true
        }
    }
    
    //Mutiple Selection
    func handleSelection(cell: JTAppleDayCellView?, cellState: CellState) {
        let myCustomCell = cell as! CellView // You created the cell view if you followed the tutorial
        switch cellState.selectedPosition() {
        case .full, .left, .right:
            myCustomCell.selectedView.isHidden = false
            myCustomCell.selectedView.backgroundColor = UIColor.lightGray // Or you can put what ever you like for your rounded corners, and your stand-alone selected cell
        case .middle:
            myCustomCell.selectedView.isHidden = false
            myCustomCell.selectedView.backgroundColor = UIColor.lightGray // Or what ever you want for your dates that land in the middle
        default:
            myCustomCell.selectedView.isHidden = true
            myCustomCell.selectedView.backgroundColor = nil // Have no selection when a cell is not selected
        }
        
    }
    
    //Showing Month Label
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        var date = Date()
        if visibleDates.indates.count > 0 {
            date = visibleDates.indates.last!.addingTimeInterval(60*60*24*2)
        }
        else if visibleDates.outdates.count > 0 {
            date = visibleDates.outdates.first!.addingTimeInterval(60*60*24 * -2)
        }
        setMonthLabelWithDate(date: date)
    }
    
    func setMonthLabelWithDate(date: Date) {
        let month = testCalendar.component(Calendar.Component.month, from: date)
        let year  = testCalendar.component(Calendar.Component.year, from: date)
        let monthName = DateFormatter().monthSymbols[(month-1) % 12] // 0 indexed array
        monthLabel.text = "\(monthName) \(year)"
    }
    
}


//MARK: - Search
extension LandingPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResults.removeAll()
        searchResults = searchForLocation_Event(searchString: searchText)
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchButtonPressed(searchButton) //go to normal function to close view
        view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchButtonPressed(searchButton) //go to normal function to close view
        view.endEditing(true)
    }
    
    //DATA SOURCE
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell? = nil
        
        cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SearchCell")
        }
        cell?.backgroundColor = UIColor.clear
        
        let entry = searchResults[indexPath.row]
        
        cell?.textLabel?.text = entry.0
        cell?.detailTextLabel?.text = entry.1
        
        cell?.textLabel?.textColor = UIColor.lightGray
        
        if entry.1 == "Event" {
            cell?.detailTextLabel?.textColor = UIColor.darkGray
            cell?.accessoryType = UITableViewCellAccessoryType.none
        }
        else if entry.1 == "Club" {
            cell?.detailTextLabel?.textColor = UIColor.wgwDarkBlueClubCell()
            cell?.accessoryType = UITableViewCellAccessoryType.detailButton
        }
        else if entry.1 == "Bar" {
            cell?.detailTextLabel?.textColor = UIColor.darkRed()
            cell?.accessoryType = UITableViewCellAccessoryType.detailButton
        }
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    //DELEGATE
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //close the searchView
        searchButtonPressed(searchButton)
        
        //move to view according to selected entry
        let entry = searchResults[indexPath.row]
        if entry.1 == "Event" {
            instance_eventsVC?.filterBy(name: entry.0, sortAscending: "noFilter")
            instance_pagerVC?.moveToViewController(at: 0)
        }
        else if entry.1 == "Club" {
            global_filteredClub = entry.0
            global_clubsFilterSet = true
            instance_clubsVC?.filterBy(name: entry.0, open: "noFilter", happyHour: "noFilter")
            instance_pagerVC?.moveToViewController(at: 2)
        }
        else if entry.1 == "Bar" {
            instance_pagerVC?.moveToViewController(at: 3)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        //close the searchView
        searchButtonPressed(searchButton)
        
        let entry = searchResults[indexPath.row]
        global_mapsFilterSet = true
        global_mapsFilteredLocation = entry.0
        instance_mapVC?.filterBy(name: entry.0, type: "noFilter", open: "noFilter", happyHour: "noFilter", radius: 0)
        instance_pagerVC?.moveToViewController(at: 4)
    }
    
    
    
    
    
    
}

