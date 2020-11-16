//
//  SavedRoutesController.swift
//  Elena
//
//  Created by Maxwell Hubbard on 10/30/20.
//

import UIKit
import CoreLocation
import MapKit

//action that occurs on table cell tap
extension SavedRoutesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let route = Settings.instance.savedRoutesList[indexPath.row]
                
        let viewController = UIApplication.shared.windows[0].rootViewController as? ViewController
        
        viewController?.destLocation = route.addressLocation.location!
        viewController?.destLoc = route.addressString
        
        viewController?.mapView.removeAnnotations((viewController?.mapView.annotations)!)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = route.addressLocation.location!.coordinate
        viewController?.mapView.addAnnotation(annotation)
        
        viewController?.displayPrelimDestination(dest: route.addressString, placemark: route.addressLocation)
        
        self.dismiss(animated: true, completion: nil)
        
        
        
    }
}

//handles where the cell data comes from and how it is viewed
extension SavedRoutesController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Settings.instance.savedRoutesList.count
    }
    
    //sets info for each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SavedRoutesTableViewCell  else {
            fatalError("The dequeued cell is not an instance of SavedRoutesTableViewCell.")
        }
        
        let route = Settings.instance.savedRoutesList[indexPath.row]
        
        cell.titleLabel.text = route.title
        cell.addressLabel.text = route.addressString

        return cell
    }
}
    

class SavedRoutesController: UIViewController {
    
    //MARK: Properties
    
    
    
    
    //table view var
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //toolbar actions
    @IBAction func addEntry(_ sender: Any) {
        _ = SavedRoutes(location: CLLocation(latitude: 42.38954870, longitude: -72.53345997))
        
        let alertController = UIAlertController(title: "Saved Routes", message: "Successfully saved route!", preferredStyle: .alert)

        let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            print("You've pressed OK");
        }

        alertController.addAction(action1)

        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func editList(_ sender: Any) {
    }
    
    //MARK: Private Methods
    private func loadSampleList(){
//        guard let loc1 = SavedRoutes(title: "Home", addressString: "12 N East St, Amherst MA 01002") else {
//            fatalError("Unable to instantiate loc1")
//        }
//        guard let loc2 = SavedRoutes(title: "KS", addressString: "778 N Pleasant St, Amherst MA 01002") else {
//            fatalError("Unable to instantiate loc2")
//        }
        
//        Settings.instance.savedRoutesList += [loc1, loc2]
        
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
