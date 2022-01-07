//
//  feedTableViewCell.swift
//  firebasefeed
//


import UIKit

struct imageArray {
    var imageArr : [String]
}

class feedTableViewCell: UITableViewCell {
    
    var nameLabel = UILabel()
    var likeButton : UIButton = {
        let button = UIButton()
        
        button.tintColor = .red
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Like", for: .normal)
        button.setImage(UIImage.init(systemName: "heart"), for: .normal)
        
        return button
    }()
    
    
    
    var commentButton = UIButton()
    
    var pageControl : UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 8
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        return pageControl
    }()
    
    var imageArray = [String]()
    
    var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5.0
        return stackView
    }()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    func commonInit(){
        backgroundColor = .systemBackground
        contentView.addSubview(nameLabel)
        contentView.addSubview(collectionView)
        contentView.addSubview(buttonStackView)
        contentView.addSubview(pageControl)
        updateConstraints()
    }
    
    override func updateConstraints() {
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -20),
            nameLabel.bottomAnchor.constraint(equalTo:  collectionView.topAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 40)
            
        ])
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo:  buttonStackView.topAnchor),
            
            collectionView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            pageControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            pageControl.bottomAnchor.constraint(equalTo:  buttonStackView.topAnchor),
            
            pageControl.heightAnchor.constraint(equalToConstant: 30)
            
            
            
        ])
        
        
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: pageControl.bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
           buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            buttonStackView.heightAnchor.constraint(equalToConstant: 40),
            buttonStackView.widthAnchor.constraint(equalToConstant: contentView.frame.width/1.5)
        ])
        
        
        
        likeButton.centerTextAndImage(spacing: 10)
        commentButton.tintColor = .label
        commentButton.setImage(UIImage.init(systemName: "bubble.left"), for: .normal)
        
        buttonStackView.addArrangedSubview(likeButton)
        buttonStackView.addArrangedSubview(commentButton)
        
        super.updateConstraints()
    }
    

    public lazy var collectionView: UICollectionView = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .horizontal
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.register(TableCollectionViewCell.self, forCellWithReuseIdentifier: "TableCollectionViewCell")
        v.delegate = self
        v.backgroundColor = .systemBackground
        v.showsHorizontalScrollIndicator = false
        v.dataSource = self
        v.isScrollEnabled = true
        
        return v
    }()
    
    
    func setUp(model: feedData){
        imageArray.removeAll()
        nameLabel.text = model.userId
        
        for image in model.imageUrl {
            imageArray.append(image)
        }
        
        NSLog(model.imageUrl[0])
        
        if model.likecount == 0 ||  model.likecount == 1 {
            
            likeButton.setTitle("\(model.likecount) Like", for: .normal)
        }
        else{
            likeButton.setTitle("\(model.likecount) Likes", for: .normal)
        }
        if model.isliked == true {
            likeButton.setImage(UIImage.init(systemName: "heart.fill"), for: .normal)
        }
        else{
            likeButton.setImage(UIImage.init(systemName: "heart"), for: .normal)
        }
      
        
        collectionView.reloadData()
        
    }
    
}


extension feedTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TableCollectionViewCell", for: indexPath) as! TableCollectionViewCell
        
    
        pageControl.numberOfPages = imageArray.count
      
        cell.feedImage.load(urlString: imageArray[indexPath.row])
        
        if imageArray.count == 1 {
            pageControl.isHidden = true
        }
        else{
            pageControl.isHidden = false
        }
        
        
        
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
       // checkButton()
    }
}
extension feedTableViewCell: UICollectionViewDelegate{
    
}
extension feedTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
