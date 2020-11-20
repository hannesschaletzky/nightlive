//
//  SignUpLoginViewController.swift
//  back4app
//
//  Created by Hannes Schaletzky on 27/05/16.
//  Copyright © 2016 Hannes Schaletzky. All rights reserved.
//

import UIKit
import Parse

class SignUpLoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userTF: UITextField!
    @IBOutlet weak var mailTF: UITextField!
    @IBOutlet weak var areYouStudentLabel: UILabel!
    @IBOutlet weak var pwTF: UITextField!
    @IBOutlet weak var confirmpwTF: UITextField!
    @IBOutlet weak var yearOfBirthTF: UITextField!
    @IBOutlet weak var isStudentControl: UISegmentedControl!
    @IBOutlet weak var hintTF: UITextField!
    
    @IBOutlet weak var hintTFMarginYConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var userTFActInd: UIActivityIndicatorView!
    @IBOutlet weak var mailTFActInd: UIActivityIndicatorView!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var mailImgView: UIImageView!
    @IBOutlet weak var pwImgView: UIImageView!
    @IBOutlet weak var confirmpwImgView: UIImageView!
    @IBOutlet weak var yearOfBirthImgView: UIImageView!
    @IBOutlet weak var hintInfoButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var action = "" //defines whether it's "Sign Up" or "Login" or "Anonymously"
    var userNameSet = Bool()
    var mailSet = Bool()
    var yearOfBirthSet = Bool()
    var isStudentSet = Bool()
    var pwSet = Bool()
    var pwConfirmed = Bool()
    var userTappedOrSwiped = Bool()
    
    var hintForTF: [Int: String] = [:]
    var userIsStudent = Bool()
    
    //Colors
    let wgwReducedAlphaWhite = UIColor.wgwReducedAlphaWhite()
    let wgwLowAlphaWhite = UIColor.wgwLowAlphaWhite()
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        //Looks for single and swipe up
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpLoginViewController.dismissKeyboard))
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(SignUpLoginViewController.dismissKeyboard))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipeUp)
        
        //TF delegates
        userTF.delegate = self
        mailTF.delegate = self
        pwTF.delegate = self
        confirmpwTF.delegate = self
        yearOfBirthTF.delegate = self
        
        //Control-Flow Variables
        userNameSet = false
        mailSet = false
        pwSet = false
        pwConfirmed = false
        yearOfBirthSet = false
        isStudentSet = false
        userTappedOrSwiped = false
        
        hintForTF.removeAll()
        hintForTF = [userTF.tag:"", mailTF.tag:"", pwTF.tag:"", confirmpwTF.tag:"", yearOfBirthTF.tag:""]
        
        //configure appearance
        userImgView.isHidden = true
        mailImgView.isHidden = true
        pwImgView.isHidden = true
        confirmpwImgView.isHidden = true
        yearOfBirthImgView.isHidden = true
        hintTF.isHidden = true
        hintInfoButton.isHidden = true
        setControlInactive(actionButton)
        actionButton.setTitle(action, for: UIControlState())
        
        //distinguish action
        //Sign Up
        if action == StringConstants.signup {
            setplaceHolderWithColor(userTF, text: "username", color: wgwLowAlphaWhite)
            setplaceHolderWithColor(mailTF, text: "e-mail (optional)", color: wgwLowAlphaWhite)
            setplaceHolderWithColor(pwTF, text: "password", color: wgwLowAlphaWhite)
            setplaceHolderWithColor(confirmpwTF, text: "confirm pw", color: wgwLowAlphaWhite)
            setplaceHolderWithColor(yearOfBirthTF, text: "year of birth", color: wgwLowAlphaWhite)
            
            userTF.becomeFirstResponder()
        }
            
        //Login
        else if action == StringConstants.login {
            setplaceHolderWithColor(mailTF, text: "username", color: wgwLowAlphaWhite)
            setplaceHolderWithColor(pwTF, text: "password", color: wgwLowAlphaWhite)
            
            userTF.isHidden = true
            confirmpwTF.isHidden = true
            yearOfBirthTF.isHidden = true
            areYouStudentLabel.isHidden = true
            isStudentControl.isHidden = true
            mailTF.keyboardType = UIKeyboardType.default
            hintTFMarginYConstraint.constant = 8
            
            mailTF.becomeFirstResponder()
        }
        
        //Anonymous
        else if action == StringConstants.anonymously {
            setControlsInViewInactive()
            activityIndicator.startAnimating()
            loginWithAnonymousUser()
        }
        
        else {
            print("Error Occured during viewDidLoad")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    //MARK: - UI
    func setplaceHolderWithColor(_ textField: UITextField, text: String, color: UIColor) {
        textField.attributedPlaceholder =
            NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName : color])
    }
    
    func setImgViewForTF(_ result: String, tf: UITextField) {
        let imgView = getTFImgViewForTF(tf.tag)
        if result == StringConstants.correctEntry {
            let image = UIImage(named: "arrow")
            imgView.image = image
        }
        if result == StringConstants.wrongEntry {
            let image = UIImage(named: "cross")
            imgView.image = image
        }
        imgView.isHidden = false
        
    }
    
    func setControlInactive(_ element: UIControl) {
        element.isEnabled = false
        element.alpha = 0.4
    }
    
    func setControlActive(_ element: UIControl) {
        element.isEnabled = true
        element.alpha = 1
    }
    
    func setControlsInViewInactive() {
        setControlInactive(userTF)
        setControlInactive(mailTF)
        setControlInactive(pwTF)
        setControlInactive(confirmpwTF)
        setControlInactive(yearOfBirthTF)
        setControlInactive(isStudentControl)
        areYouStudentLabel.alpha = 0.4
        setControlInactive(actionButton)
        setControlInactive(cancelButton)
    }
    
    func setControlsInViewActive() {
        setControlActive(userTF)
        setControlActive(mailTF)
        setControlActive(pwTF)
        setControlActive(confirmpwTF)
        setControlActive(yearOfBirthTF)
        setControlActive(isStudentControl)
        areYouStudentLabel.alpha = 1
        setControlActive(actionButton)
        setControlActive(cancelButton)
    }
    
    func setActionButtonActive() {
        setControlActive(actionButton)
    }
    
    /*func castTF(_ tf: UITextField) -> AnimatableTextField? {
        return tf as? AnimatableTextField
    }*/
    
    func getTFImgViewForTF(_ tag: Int) -> UIImageView {
        switch tag {
        case 1:
            return userImgView
        case 2:
            return mailImgView
        case 3:
            return pwImgView
        case 4:
            return confirmpwImgView
        case 5:
            return yearOfBirthImgView
        default:
            return UIImageView()
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        if !userTappedOrSwiped {
            userTappedOrSwiped = true
            view.endEditing(true)
        }
    }
    
    //MARK: - User Interaction
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        let action = sender.currentTitle!
        
        switch action {
        case StringConstants.signup:
            print("Sign Up User")
            setControlsInViewInactive()
            activityIndicator.startAnimating()
            signUpUser()
        case StringConstants.login:
            print("Login User")
            setControlsInViewInactive()
            activityIndicator.startAnimating()
            loginUser()
        default:
            print("Error occured during Action Button pressed")
        }
        
    }
    @IBAction func cancelButtonPressed() {
        //clear View maybe
        segueToInitialPage()
    }
    
    //confirmPWTF
    @IBAction func textFieldValueDidChange(_ sender: UITextField) {
        if sender.text != nil {
            let pwConfirmText = sender.text!
            if pwTF.text != nil {
                let pwText = pwTF.text!
                if pwConfirmText == pwText {
                    setImgViewForTF(StringConstants.correctEntry, tf: confirmpwTF)
                    pwConfirmed = true
                    
                    //go on to year of birth TF
                    if !yearOfBirthSet {
                        yearOfBirthTF.becomeFirstResponder()
                    }
                    //if year is set, then dismiss keyboard
                    else {
                        dismissKeyboard()
                    }
                    
                }
                else {
                    if pwConfirmed {
                        let imgView = getTFImgViewForTF(confirmpwTF.tag)
                        imgView.isHidden = true
                        pwConfirmed = false
                    }
                }
            }
        }
    }
    
    //yearOfBirthTF
    @IBAction func yearOfBirthTFValueDidChange(_ sender: UITextField) {
        let yearOfBirthText = NSString(string: sender.text!)
        if yearOfBirthText.length == 4 && isUserInValidAgeRange(Int(yearOfBirthText as String)!) {
            //correct 
            print("correct age")
            yearOfBirthSet = true
            setImgViewForTF(StringConstants.correctEntry, tf: yearOfBirthTF)
            dismissKeyboard()
        }
        else {
            if yearOfBirthSet {
                let imgView = getTFImgViewForTF(yearOfBirthTF.tag)
                imgView.isHidden = true
                yearOfBirthSet = false
            }
        }
    }
    
    @IBAction func isStudentValueChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        if let _ = sender.titleForSegment(at: selectedIndex) {
            if selectedIndex == 0 { //first is always Yes
                userIsStudent = true
            }
            else {
                userIsStudent = false
            }
            isStudentSet = true
            checkIfEntriesAreCorrect()
        }
    }
    
    func segueToInitialPage() {
        performSegue(withIdentifier: "cancelSignUpLogin", sender: self)
    }
    
    //MARK: - Logic
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //shows Hint if there is one for this textField
        userTappedOrSwiped = false
        let hintText = hintForTF[textField.tag]! //this causes errors if value is not initialized
        if  hintText != "" {
            showHint(hintText)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //when user enters new pw then clear the confirm pw field
        if textField.tag == 3 && textField.text != confirmpwTF.text {
            confirmpwTF.text = ""
            confirmpwImgView.isHidden = true
            pwConfirmed = false
        }
        
        checkEntriesAfterUserTypedSomethingInTF(textField)
    }
    
    func checkEntriesAfterUserTypedSomethingInTF(_ textField: UITextField) {
        textField.resignFirstResponder()
        let tag = textField.tag
        
        hideHint()
        
        /*
        if !mailSet && action == StringConstants.signup {
            let errorInMail = checkFieldWithTag(2)
            if !errorInMail {
                //no error in Mail
                mailSet = true
                
            }
            else {
                mailSet = false
            }
        }
        */
        
        //Sign up
        if action == StringConstants.signup {
            let errorOccured = checkFieldWithTag(tag) //check here if field is correct
            if !errorOccured {
                switch tag {
                case 1:
                    if !userTappedOrSwiped {
                        mailTF.becomeFirstResponder()
                    }
                case 2:
                    if !userTappedOrSwiped {
                        pwTF.becomeFirstResponder()
                    }
                case 3:
                    setImgViewForTF(StringConstants.correctEntry, tf: textField)
                    pwSet = true
                    if !userTappedOrSwiped {
                        confirmpwTF.becomeFirstResponder()
                    }
                case 4:
                    //Ready for Sign Up
                    
                    //Handled in pwConfirmTFValueChanged IBAction Function
                    //setImgViewForTF(StringConstants.correctEntry, tf: textField)
                    //pwConfirmed = true
                    break
                case 5:
                    setImgViewForTF(StringConstants.correctEntry, tf: yearOfBirthTF)
                    yearOfBirthSet = true
                    if !userTappedOrSwiped {
                        yearOfBirthTF.resignFirstResponder()
                        dismissKeyboard()
                    }
                    break
                default:
                    break
                }
                checkIfEntriesAreCorrect()
            }
            else {
                //user typed something in wrongly
                setImgViewForTF(StringConstants.wrongEntry, tf: textField)
                setControlInactive(actionButton)
            }
        }
            //Login
        else if action == StringConstants.login {
            let errorOccured = checkFieldWithTag(tag)
            if !errorOccured {
                switch tag {
                case 2:
                    //username
                    //setImgViewForTF(StringConstants.correctEntry, tf: textField)
                    userNameSet = true
                    if !userTappedOrSwiped {
                        pwTF.becomeFirstResponder()
                    }
                case 3:
                    //pw
                    //setImgViewForTF(StringConstants.correctEntry, tf: textField)
                    pwSet = true
                    
                default:
                    break
                }
                if userNameSet && pwSet {
                    setActionButtonActive()
                }
            }
            else {
                //user typed something in wrongly
                //setImgViewForTF(StringConstants.wrongEntry, tf: textField)
                setControlInactive(actionButton)
            }
            
        }
        else {
            print("not a valid option in TextFieldDidBeginEditing")
        }

    }
    
    func checkFieldWithTag(_ tag: Int) -> Bool {
        
        var errorOccured = false
        var hint = ""
        
        switch tag {
            
        case 1:
            //USER
            let user = NSString(string: userTF.text!)
                if user.length > 0 {
                    if user.length <= 20 {
                        if stringHasNoSpace(user as String) {
                            userTFActInd.startAnimating()
                            userImgView.isHidden = true
                            checkIfNameOrEmailAlreadyExist(user as String, isUserName: true)
                        }
                        else {
                            hint = ("please no whitespace")
                            errorOccured = true
                        }
                    }
                    else {
                        hint = ("please user <= 20 chars")
                        errorOccured = true
                    }
                }
                else {
                    hint = ("please provide a username")
                    errorOccured = true
                }
            
        case 2:
            //SIGNUP
            if action == StringConstants.signup {
                
                //MAIL
                let mail = NSString(string: mailTF.text!)
                if mail.length == 0 {
                    mailTFActInd.startAnimating()
                    mailImgView.isHidden = true
                    usernameOrMailIsAvailable(false) //jump over the backend check
                }
                else {
                    if isValidEmail(mail as String) {
                        mailTFActInd.startAnimating()
                        mailImgView.isHidden = true
                        checkIfNameOrEmailAlreadyExist(mail as String, isUserName: false)
                    }
                    else {
                        hint = ("Please provide a valid e-mail")
                        mailSet = false
                        errorOccured = true
                    }
                }
                
            }
            //LOGIN
            else if action == StringConstants.login {
                //USERNAME
                mailImgView.isHidden = true
                let userName = NSString(string: mailTF.text!)
                if userName.length == 0 || userName.length > 20 {
                    hint = ("0<username<=20")
                    errorOccured = true
                }
            }
            
        case 3:
            //PW
            let pw = NSString(string: pwTF.text!)
            pwImgView.isHidden = true
                if pw.length <= 5 || pw.length > 15{
                    hint = ("6<=pw<=15 chars")
                    errorOccured = true
                }
            
        case 4:
            //CONFIRM PW
            //confirmpwImgView.hidden = true
                if pwTF.text != confirmpwTF.text {
                    hint = ("pw's don't match")
                    errorOccured = true
                }
            
        case 5:
            //year of birth
            let yearOfBirthText = NSString(string: yearOfBirthTF.text!)
            yearOfBirthImgView.isHidden = true
            if yearOfBirthText.length != 4 {
                hint = ("not a valid year")
                errorOccured = true
            }
            else {
                if !isUserInValidAgeRange(Int(yearOfBirthText as String)!) {
                    hint = ("not a valid age")
                    errorOccured = true
                }
            }
            
            
        default:
            return errorOccured
        }
        
        hintForTF.updateValue(hint, forKey: tag)
        return errorOccured
        
    }
    
    func showHint(_ hint: String) {
        hintTF.text = hint
        hintTF.isHidden = false
        hintInfoButton.isHidden = false
    }
    
    func hideHint() {
        self.hintTF.isHidden = true
        self.hintInfoButton.isHidden = true
    }
    
    func stringHasNoSpace(_ string: String) -> Bool{
        let whitespace = CharacterSet.whitespaces
        let range = string.rangeOfCharacter(from: whitespace)
        
        if range != nil {
            //whitespace found
            return false
        }
        else {
            //no whitespace found
            return true
        }
    }

    func isValidEmail(_ mailString:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: mailString)
    }
    
    func checkIfEntriesAreCorrect() {
        
        if userNameSet && mailSet && pwSet && pwConfirmed && yearOfBirthSet && isStudentSet {
            setActionButtonActive()
        }
        else {
            setControlInactive(actionButton)
        }
        
    }
    
    func segueToLandingPage() {
        performSegue(withIdentifier: "showApp", sender: self)
    }
    
    //MARK: - Backend: Callback - Handling
    func signUpLoginSuccessfull() {
        showAlert(StringConstants.signUpLoginSuccess, subTitleInc: "")
        //Sign Up and Login Success are treated the same way
    }
    
    func signUpLoginFailed(_ code: Int) {
        var subTitle = ""
        switch code {
            
            /*
            Network Connectivity Issues are not covered
            */
            
        case -1:
            //means that error has no code
            subTitle = "Some other error..."
        case 101:
            subTitle = "Wrong username or password"
        case 202:
            subTitle = "username already exists"
        case 203:
            subTitle = "e-mail already exists"
        default:
            break
        }
        showAlert(StringConstants.signUpLoginFail, subTitleInc: subTitle)
    }
    
    func usernameOrMailIsAvailable(_ isUserName: Bool) {
        if isUserName {
            setImgViewForTF(StringConstants.correctEntry, tf: userTF)
            userNameSet = true
            userTFActInd.stopAnimating()
            hintForTF.updateValue("", forKey: 1)
            print("username is available")
        }
        else {
            setImgViewForTF(StringConstants.correctEntry, tf: mailTF)
            mailSet = true
            mailTFActInd.stopAnimating()
            hintForTF.updateValue("", forKey: 2)
            print("email is available")
        }
        checkIfEntriesAreCorrect()
        
    }
    
    func usernameOrMailIsNotAvailable(_ isUserName: Bool) {
        if isUserName {
            setImgViewForTF(StringConstants.wrongEntry, tf: userTF)
            //showHint("username already exists")
            userNameSet = false
            userTFActInd.stopAnimating()
            hintForTF.updateValue("username already exists", forKey: 1)
            print("username is not available")
        }
        else {
            setImgViewForTF(StringConstants.wrongEntry, tf: mailTF)
            //showHint("email already exists")
            mailSet = false
            mailTFActInd.stopAnimating()
            hintForTF.updateValue("email already beeing used", forKey: 2)
            print("email is not available")
        }
        checkIfEntriesAreCorrect()
    }
    
    func showAlert(_ result: String, subTitleInc: String) {
        print("ShowAlert with result: \(result)")
        activityIndicator.stopAnimating()
        
        var title = ""
        var subTitle = ""
        var style:AlertStyle!
        var buttonTitle = ""
        let buttonColor = UIColor.lightGray
        var blockFunction = {}
        
        switch result {
        case StringConstants.signUpLoginSuccess:
            title = "Success"
            subTitle = "You're now using nightlive with your user"
            style = AlertStyle.success
            buttonTitle = "Nice"
            blockFunction = {
                print("I'm in the block function of signup/login success")
                //Segue to App
                self.segueToLandingPage()
            }
        case StringConstants.signUpLoginFail:
            title = "Error"
            subTitle = subTitleInc
            style = AlertStyle.error
            buttonTitle = "Ok"
            blockFunction = {
                self.setControlsInViewActive()
            }
        case StringConstants.anonymouslySuccess:
            title = "Success"
            subTitle = "You're now using nightlive anonymously"
            style = AlertStyle.success
            buttonTitle = "Nice"
            blockFunction = {
                print("I'm in the block function of anonymousSuccess success")
                //Segue to App
                self.segueToLandingPage()
            }
        case StringConstants.anonymouslyFail:
            title = "Error"
            subTitle = "Couldn't login anonymously"
            style = AlertStyle.error
            buttonTitle = "Ok..."
            blockFunction = {
                print("I'm in the block function of anonymousSuccess fail")
                //Segue to initial Screen
            }
        default:
            break
        }
        
        SweetAlert().showAlert(title, subTitle: subTitle, style: style, buttonTitle:buttonTitle, buttonColor:buttonColor) { (action) -> Void in
            blockFunction() //I like :)
        }
    }
    
    //MARK: - Backend Interaction
    func signUpUser() {
        let user = PFUser()
        user.username = userTF.text
        user.password = pwTF.text
        //user.email = mailTF.text
        user["student"] = userIsStudent
        user["birthday_year"] = Int(yearOfBirthTF.text!)
        
        user.signUpInBackground { (success, error) in
            if error != nil {
                //Error
                /*let errorString = error!.userInfo["error"] as? NSString
                print(errorString!)
                if let code = error?.code {
                    self.signUpLoginFailed(code)
                }
                else {*/
                    self.signUpLoginFailed(-1)
                //}
            }
            else {
                //No Error
                if success {
                    self.signUpLoginSuccessfull()
                }
                else {
                    self.signUpLoginFailed(-1)
                }
                
            }
        }
        
    }
    
    func loginUser() {
        let username = mailTF.text!
        let password = pwTF.text!
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if error != nil {
                //Error
                /*let errorString = error!.userInfo["error"] as? NSString
                print(errorString!)
                if let code = error?.code {
                    self.signUpLoginFailed(code)
                }
                else {*/
                    self.signUpLoginFailed(-1) //if error has no code
                //}
            }
            else {
                //No Error
                if user != nil {
                    self.signUpLoginSuccessfull()
                }
                else {
                    self.signUpLoginFailed(-1)
                }
            }
        }
        
    }
    
    func loginWithAnonymousUser() {
        
        PFAnonymousUtils.logIn { (user, error) in
            if error != nil || user == nil {
                print("Anonymous login failed.")
                self.showAlert(StringConstants.anonymouslyFail, subTitleInc: "")
            } else {
                print("Anonymous user logged in.")
                self.showAlert(StringConstants.anonymouslySuccess, subTitleInc: "")
            }
        }
        
    }
    
    func checkIfNameOrEmailAlreadyExist (_ text: String, isUserName: Bool) {
        let query:PFQuery = PFUser.query()!
        if isUserName {
            query.whereKey("username", equalTo: text)
        }
        else {
            query.whereKey("email", equalTo: text)
        }
        
        query.getFirstObjectInBackground { (object, error:Error?) in
            if error != nil {
                //let code = error?.code
                //if code == 101 {
                    //no object found --> username or mail available
                    self.usernameOrMailIsAvailable(isUserName)
                //}
            }
            else {
                if object != nil {
                    self.usernameOrMailIsNotAvailable(isUserName)
                }
            }
        }

    }
 
 
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
