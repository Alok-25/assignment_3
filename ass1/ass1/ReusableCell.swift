//
//  ReusableCell.swift
//  ass1
//
//  Created by Inito on 06/08/23.
//

import UIKit

class ReusableCell: UITableViewCell {

    @IBOutlet weak var descriptionOfProduct: UILabel!
    @IBOutlet weak var priceOfProduct: UILabel!
    @IBOutlet weak var titleOfProduct: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var imageOfProduct: UIImageView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
