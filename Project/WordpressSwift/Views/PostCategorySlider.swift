//
//  CategorySlider.swift
//  Universal
//
//  Created by Mark on 17/03/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation

class PostCategorySlider: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    static let identifierX = "CategorySliderCell"
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var baseUrl: String?
    var categories = [WPCategory]()
    
    func loadCategories() {
        setupList()
        
        if (categories.count > 0) { return }
        
        let client = WordpressSwift.init()
        let requestParams = RequestParams.init()
        requestParams.page = 1
        
        client.get(blogURL: baseUrl!, params: requestParams, forType: WPCategory.self, completionHandler: { (success, categories) in
            //Do not show if no success
            if (!success || (categories?.count ?? 0) == 0) {
                print("Error loading categories")
                return
            }
            
            if let results = categories {
                self.categories += results as! [WPCategory]
                self.collectionView.reloadData()
            }
            
            return
        })
    }
    
    func setupList() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flow.minimumInteritemSpacing = 0;
        flow.minimumLineSpacing = 0;
        
        let height = self.collectionView.frame.size.height
        let widthHeightRatio = PostCategoryCell.widthHeightRatio
        flow.estimatedItemSize = CGSize(width: height / CGFloat(widthHeightRatio), height: height)
        
        collectionView.collectionViewLayout = flow
    }
    
    func selectedCategory() -> WPCategory {
        return self.categories[(self.collectionView?.indexPathsForSelectedItems![0].item)!]
    }
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordpressCategoryCell", for: indexPath)
        if let annotateCell = cell as? PostCategoryCell {
            annotateCell.category = self.categories[indexPath.item]
        }
        
        return cell
    }
    
}
