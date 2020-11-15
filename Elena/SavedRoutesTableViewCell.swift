//
//  SavedRoutesTableViewCell.swift
//  Elena
//
//  Created by Joe Pasquale on 11/15/20.
//

import UIKit
import MapKit
import CoreLocation

class SavedRoutesTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    //@IBOutlet weak var addressMapPreview: MKMapView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
