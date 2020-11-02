//
//  SavedRoutesController.swift
//  Elena
//
//  Created by Maxwell Hubbard on 10/30/20.
//

import UIKit
import CoreLocation

class SavedRoutesController: UIViewController {
    
    let locationManager = CLLocationManager()
    
    struct Entry: Identifiable {
        var id = UUID()
        var name: String
        var location: CLLocation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addEntry(_ sender: Any) {
    }
    
    @IBAction func editList(_ sender: Any) {
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
