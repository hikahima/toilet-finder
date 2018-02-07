//
//  OptionsController.swift
//  toilet finder
//
//  Created by Yanfei on 2018/1/25.
//  Copyright © 2018年 Yanfei. All rights reserved.
//

import Foundation

class OptionsController: UIViewController {

    @IBOutlet weak var male: UISwitch!
    
    @IBOutlet weak var female: UISwitch!
    
    @IBOutlet weak var parking: UISwitch!
    
    @IBOutlet weak var drinkingwater: UISwitch!
    
    @IBOutlet weak var babychange: UISwitch!
    
    var setMale:Bool = false
    var setFemale:Bool = false
    var setParking:Bool = false
    var setDrinkingwater:Bool = false
    var setBabychang:Bool = false
    
    @IBAction func back(_ sender: Any) {
       self.performSegue(withIdentifier: "unwindToMain", sender: self)
       self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToMain" {
            if let nextViewController = segue.destination as? ViewController {
                nextViewController.setMale=setMale
                nextViewController.setFemale=setFemale
                nextViewController.setBabychang=setBabychang
                nextViewController.setDrinkingwater=setDrinkingwater
                nextViewController.setParking=setParking
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        male.addTarget(self, action: #selector(clickMale(_:)), for: .valueChanged)
        female.addTarget(self, action: #selector(clickFemale(_:)), for: .valueChanged)
        parking.addTarget(self, action: #selector(clickParking(_:)), for: .valueChanged)
        drinkingwater.addTarget(self, action: #selector(clickDrinkingwater(_:)), for: .valueChanged)
        babychange.addTarget(self, action: #selector(clickBabychange(_:)), for: .valueChanged)
    }
   
        
    @objc func clickMale(_ sender: UISwitch) {
        if male.isOn == true {
            setMale = true
        }else {
            setMale = false
        }
    }
    @objc func clickFemale(_ sender: UISwitch) {
        if female.isOn == true {
            setFemale = true
        }else {
            setFemale = false
        }
    }
    @objc func clickParking(_ sender: UISwitch) {
        if parking.isOn == true {
            setParking = true
        }else {
            setParking = false
        }
    }
    @objc func clickDrinkingwater(_ sender: UISwitch) {
        if drinkingwater.isOn == true {
            setDrinkingwater = true
        }else {
            setDrinkingwater = false
        }
    }
    @objc func clickBabychange(_ sender: UISwitch) {
        if babychange.isOn == true {
            setBabychang = true
        }else {
            setBabychang = false
        }
    }
    
}
