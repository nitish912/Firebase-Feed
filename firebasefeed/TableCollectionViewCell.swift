//
//  TableCollectionViewCell.swift
//  firebasefeed
//


import UIKit

class TableCollectionViewCell: UICollectionViewCell{
    
 
    
    let padding: CGFloat = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit(){
        //backgroundColor = .yellow
        contentView.addSubview(feedImage)
        updateConstraints()
    }

    override func updateConstraints() {
        feedImage.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        NSLayoutConstraint.activate([
            feedImage.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            feedImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            feedImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            feedImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
            ])
        
        

        
        super.updateConstraints()
    }

    public let feedImage: UIImageView = {
        let v = UIImageView()
        return v
    }()
    
    
    
    
}
