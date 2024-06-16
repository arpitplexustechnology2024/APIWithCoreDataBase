//
//  TableViewCell.swift
//  MVCAPICalling
//
//  Created by Arpit iOS Dev. on 13/06/24.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var postIdLbl: UILabel!
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var bodyLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
