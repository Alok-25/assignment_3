//
//  TabViewController.swift
//  ass1
//
//  Created by Inito on 29/07/23.
//

import UIKit

class TabViewController: UIViewController {
    
    var username: String?
    var email: String?
    var phonenumber: String?

    @IBOutlet weak var UserName: UILabel!
    
    @IBOutlet weak var UserEmail: UILabel!
    
    
    
    @IBOutlet weak var UserPhoneNumber: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserName.text = username ?? ""
        UserEmail.text = email ?? ""
        UserPhoneNumber.text = phonenumber ?? ""

        
    }
    

}
