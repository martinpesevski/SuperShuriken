//
//  ShurikenCell.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 4/17/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit
import SnapKit

class ShurikenCell: UICollectionViewCell {
    var shurikenImageView: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        
        shurikenImageView = UIImageView()
        shurikenImageView.center = center
        shurikenImageView.contentMode = .scaleAspectFit
        addSubview(shurikenImageView)
        shurikenImageView.translatesAutoresizingMaskIntoConstraints = false
        
        shurikenImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("")
    }
    
    func setup(shuriken: Shuriken) {
        shurikenImageView.image = shuriken.image
        self.backgroundView = shuriken.isSelected ? UIImageView.init(image: UIImage(named: "ic_highlight")) : nil
    }
}
