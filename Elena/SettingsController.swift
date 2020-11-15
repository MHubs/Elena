//
//  SettingsController.swift
//  Elena
//
//  Created by Maxwell Hubbard on 10/13/20.
//

import UIKit

class SettingsController: UIViewController {

    @IBOutlet weak var unitsSwitch: UISwitch!
    @IBOutlet weak var elevationSwitch: UISwitch!
    @IBOutlet weak var toleranceSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        unitsSwitch.isOn = Settings.instance.units
        elevationSwitch.isOn = Settings.instance.elevationGain == "Maximize Elevation Gain"
        toleranceSlider.value = Float(Settings.instance.tolerance)
    }
    
    @IBAction func onBackTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onUnitSwitch(_ sender: UISwitch) {
        Settings.instance.units = sender.isOn
    }
    
    @IBAction func onElevationSwitch(_ sender: Any) {
        if (sender as! UISwitch).isOn {
            Settings.instance.elevationGain = "Maximize Elevation Gain"
        } else {
            Settings.instance.elevationGain = "Minimize Elevation Gain"
        }
    }
    
    @IBAction func onToleranceChange(_ sender: UISlider) {
        Settings.instance.tolerance = Int(sender.value)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
