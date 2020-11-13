//
//  SavedRoutesController.swift
//  Elena
//
//  Created by Maxwell Hubbard on 10/30/20.
//

import UIKit
import CoreLocation




class SavedRoutesController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    struct Entry: Identifiable {
        var id = UUID()
        var name: String
        var location: CLLocation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    //sets info for each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = "Hello World"
        
        return cell
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
