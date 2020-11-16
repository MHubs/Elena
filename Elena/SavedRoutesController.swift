//
//  SavedRoutesController.swift
//  Elena
//
//  Created by Maxwell Hubbard on 10/30/20.
//

import UIKit

//action that occurs on table cell tap
extension SavedRoutesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me")
    }
}

//handles where the cell data comes from and how it is viewed
extension SavedRoutesController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    //sets info for each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SavedRoutesTableViewCell  else {
            fatalError("The dequeued cell is not an instance of SavedRoutesTableViewCell.")
        }
        
        /*let route = savedRoutesList[indexPath.row]
        
        cell.titleLabel.text = route.title
        cell.addressLabel.text = route.addressString
        */
        cell.titleLabel.text = "Home"
        cell.addressLabel.text = "12 N East St"
        return cell
    }
}
    

class SavedRoutesController: UIViewController {
    
    //MARK: Properties
    var savedRoutesList = [SavedRoutes]()
    
    //table view var
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        loadSampleList()
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //toolbar actions
    @IBAction func addEntry(_ sender: Any) {
    }
    
    @IBAction func editList(_ sender: Any) {
    }
    
    //MARK: Private Methods
    private func loadSampleList(){
        guard let loc1 = SavedRoutes(title: "Home", addressString: "12 N East St, Amherst MA 01002") else {
            fatalError("Unable to instantiate loc1")
        }
        guard let loc2 = SavedRoutes(title: "KS", addressString: "778 N Pleasant St, Amherst MA 01002") else {
            fatalError("Unable to instantiate loc2")
        }
        
        savedRoutesList += [loc1, loc2]
        
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
