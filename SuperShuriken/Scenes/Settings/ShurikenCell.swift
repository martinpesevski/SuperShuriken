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
    lazy var shurikenImageView: UIImageView = {
        let shuriken = UIImageView()
        shuriken.center = center
        shuriken.contentMode = .scaleAspectFit
        shuriken.translatesAutoresizingMaskIntoConstraints = false

        return shuriken
    }()
    
    lazy var lockIcon: UIImageView = {
        let lock = UIImageView(image: UIImage(named: "lock_icon"))
        lock.contentMode = .scaleAspectFit
        addSubview(lock)
        lock.snp.makeConstraints({ make in
            make.bottom.right.equalTo(shurikenImageView)
            make.width.height.equalTo(30)
        })
        
        return lock
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        
        addSubview(shurikenImageView)
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
        self.lockIcon.isHidden = shuriken.isUnlocked
    }
}
