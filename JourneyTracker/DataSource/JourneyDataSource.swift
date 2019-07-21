//
//  JourneyDataSource.swift
//  JourneyTracker
//
//  Created by Arunprasat Selvaraj on 20/07/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import Foundation
import UIKit

class JourneyDataSource: NSObject, UITableViewDataSource {
    
    var journeyListData = [TrackingModel]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return (journeyListData.isEmpty) ? 0 : journeyListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let aCell = tableView.dequeueReusableCell(withIdentifier: JourneyTableViewCell.identifier) as? JourneyTableViewCell
        
        // Passing the value to cell
        aCell?.setupCellWithData(journeyData: journeyListData[indexPath.row])
        
        
        return aCell!
        
    }
}
