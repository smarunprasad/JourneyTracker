//
//  JourneyTableViewCell.swift
//  JourneyTracker
//
//  Created by Arunprasat Selvaraj on 20/07/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import UIKit

class JourneyTableViewCell: UITableViewCell {

    static let identifier = "JourneyTableViewCell"

    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var viewMapButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    
    var journeyData: TrackingModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func viewMapButtonTapped(_ sender: Any) {
        
        JourneyViewController().moveToMapScreen(trackingModel: journeyData)
    }
    
    func setupCellWithData(journeyData: TrackingModel) {
        
        self.journeyData = journeyData
        sourceLabel.text = journeyData.source
        destinationLabel.text = journeyData.destination
        startTimeLabel.text = journeyData.StartDate.convertDateFormater()
        endTimeLabel.text = journeyData.endDate?.convertDateFormater()
        
        if let value = journeyData.duration?.stringFromTimeInterval(), !value.isEmpty {
            
            durationLabel.text = "---- \(value) ----"
        }
    }
}
