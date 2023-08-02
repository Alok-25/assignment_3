//
//  ViewController.swift
//  ass1
//
//  Created by Inito on 29/07/23.
//

import UIKit

class FirstViewController: UIViewController {
    
    var username: String?
    var email: String?
    var phonenumber: String?
    var password: String?
    @IBOutlet weak var NameText: UITextField!
    
    @IBOutlet weak var NameLabel: UILabel!
    
    
    @IBOutlet weak var EmailText: UITextField!
    
    
    @IBOutlet weak var EmailLabel: UILabel!
    
    
    @IBOutlet weak var PhoneNumberText: UITextField!
    
    
    @IBOutlet weak var PhoneNumberLabel: UILabel!
    
    @IBOutlet weak var PasswordText: UITextField!
    
    
    @IBOutlet weak var PasswordLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func ProccedButton(_ sender: UIButton) {
        //checks()
        if checks(){
            self.performSegue(withIdentifier: "GoToProfile", sender: self)
            print (username!)
            print(email!)
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToProfile"{
            let DestinationVC = segue.destination as? UITabBarController
            
            if let firstTab = DestinationVC?.viewControllers?.first as? TabViewController{
                firstTab.username = username!
                firstTab.email = email!
                firstTab.phonenumber = phonenumber!
            }
            
            
            
        }
    }
    
    
    func NameValidate(_ username : String) -> Bool{
        
        return username.count<=20 && username.count != 0
    }
    func EmailValidate(_ email : String)-> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.com"

            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: email)
    }
    
    func PhoneNumberValidate(_ number : String)-> Bool{
        if number.count != 10 {
            return false
        }
        
           return Int(number) != nil
    }
    
    func PasswordValidate(_ password : String)->Bool{
        return password.count >= 8
    }
    
        
    
    func checks()->Bool{
        username = NameText.text
        email = EmailText.text
        phonenumber = PhoneNumberText.text
        password = PasswordText.text
        var flag = 1
        
        if !NameValidate(username ?? "") {
            NameLabel.text = "Invalid username"
            flag = 0
        }
        else {
            NameLabel.text=""
        }
        if !EmailValidate(email ?? ""){
            EmailLabel.text = "Invalid email"
            flag=0
        }
        else{
            EmailLabel.text=""
        }
        if !PhoneNumberValidate(phonenumber ?? ""){
            PhoneNumberLabel.text = "Invalid Phone Number"
            flag=0
        }
        else {
            PhoneNumberLabel.text=""
        }
        if !PasswordValidate(password ?? ""){
            PasswordLabel.text = "Invalid password"
            flag=0
        }
        else{
            PasswordLabel.text = ""
        }
        
        return flag != 0
    }
    
}

