//
//  Extensions.swift
//  back4app
//
//  Created by Hannes Schaletzky on 30/05/16.
//  Copyright © 2016 Hannes Schaletzky. All rights reserved.
//

import Foundation
import UIKit


//MARK: - UIColor
public extension UIColor {
    class func wgwOrange() -> UIColor{
        return UIColor(red: 255/255, green: 128/255, blue: 0/255, alpha: 1)
    }
    class func wgwReducedAlphaOrange() -> UIColor{
        return UIColor(red: 255/255, green: 128/255, blue: 0/255, alpha: 0.6)
    }
    class func wgwLowAlphaOrange() -> UIColor{
        return UIColor(red: 255/255, green: 128/255, blue: 0/255, alpha: 0.15)
    }
    
    class func wgwDarkBlue() -> UIColor{
        return UIColor(colorWithHexValue: 000080, alpha: 1)
    }
    class func wgwReducedAlphaDarkBlue() -> UIColor{
        return UIColor(colorWithHexValue: 000080, alpha: 0.6)
    }
    class func wgwLowAlphaDarkBlue() -> UIColor{
        return UIColor(colorWithHexValue: 000080, alpha: 0.15)
    }
    class func wgwDarkBlueClubCell() -> UIColor{
        return UIColor(red: 0/255, green: 0/255, blue: 160/255, alpha: 1.0)
    }
    
    
    class func wgwReducedAlphaWhite() -> UIColor{
        return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.6)
    }
    class func wgwLowAlphaWhite() -> UIColor{
        return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.15)
    }
    
    class func wgwGreen() -> UIColor{
        return UIColor(red: 64/255, green: 128/255, blue: 0/255, alpha: 1)
    }
    
    class func wgwRed() -> UIColor{
        return UIColor(red: 128/255, green: 0/255, blue: 0/255, alpha: 1)
    }
    
    class func darkGrayReducedAlpha() -> UIColor {
        return UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 0.6)
    }
    class func darkRedLowAlpha() -> UIColor {
        return UIColor(red: 186/255, green: 0/255, blue: 0/255, alpha: 0.15)
    }
    class func darkRed() -> UIColor {
        return UIColor(red: 186/255, green: 0/255, blue: 0/255, alpha: 1)
    }
    
    //test
    class func backgroundGreen() -> UIColor {
        return UIColor(red: 60/255, green: 90/255, blue: 120/255, alpha: 1)
    }
    
}

extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

//MARK: - Double
extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

//MARK: - UIDevice
//when you want to get the device type:
//let modelName = UIDevice.currentDevice().modelName
public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        /*case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"*/
            
            
        //Enhanced by: returning the device generation types, because I only care about screen size
        case "iPod5,1":                                 return "iPod Touch 5" //which screen size is that?
        case "iPod7,1":                                 return "iPod Touch 6" //which screen size is that?
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6+"
        case "iPhone8,1":                               return "iPhone 6"
        case "iPhone8,2":                               return "iPhone 6+"
        case "iPhone8,4":                               return "iPhone 5" //iPhone SE
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}

//MARK: - Navigation Bar
extension UINavigationBar {
    
    func setBottomBorderColor(_ color: UIColor, height: CGFloat) {
        let bottomBorderRect = CGRect(x: 0, y: frame.height, width: frame.width, height: height)
        let bottomBorderView = UIView(frame: bottomBorderRect)
        bottomBorderView.backgroundColor = color
        addSubview(bottomBorderView)
    }
}


//MARK: - String
extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}

//MARK: - Time Tracking
public struct tTCom {
    static let start = "Start"
    static let end  = "End"
    
    static let facebookRequest = "FB - Request"
    static let fbEventsOfPages = "FB - Request - Events of Pages"
    static let fbDetailsOfEvents = "FB - Request - Details of Events"
    static let fbDetailsOfPages = "FB - Request - Details of Pages"
}
private var timeTrackersDict = ["initial":Date()]

public func startTimeTracking(_ action: String) -> (Date, String) {
    let start = Date()
    print("")
    print("Start: \(action)")
    return (start, action)
}

public func endTimeTracking(_ tuple: (Date, String)) {
    let end = Date() //end time
    let timeInterval: Double = round(1000*(end.timeIntervalSince(tuple.0)))/1000 //Seconds
    print("End: \(tuple.1) | time: \(timeInterval.roundTo(places:3)) seconds")
}

public func extendedTimeTracking(action: String, timeTrackingType: String) {
    if timeTrackingType == tTCom.start {
        //START
        let start = Date()
        if timeTrackersDict[action] != nil {
            //action was executed before, update starting time
            timeTrackersDict.updateValue(start, forKey: action)
        }
        else {
            //first execution
            timeTrackersDict[action] = start
        }
    }
    else {
        //END
        let start = timeTrackersDict[action]
        endTimeTracking((start!, action))
    }
}
















