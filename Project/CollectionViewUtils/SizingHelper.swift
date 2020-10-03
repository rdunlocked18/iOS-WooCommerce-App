//
//  SizingHelper.swift
//  Universal
//
//  Created by Mark on 04/01/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation

class SizingHelper{
    
    var sizingCache = [IndexPath:CGSize]()
    
    var sizingCellCompact: PostCellCompact?
    var sizingCellText: PostCellText?
    var sizingCellSocial: SocialCell?
    
    public func clearCache(){
        sizingCache = [IndexPath:CGSize]()
    }
    
    public func getSize(indexPath: IndexPath, identifier: String, forWidth: CGFloat,  with functionConfigureCell: (UICollectionViewCell, IndexPath) -> ()) -> CGSize{
        if (sizingCache[indexPath] == nil) {
            
            let size = CGSize(width: forWidth, height: 10)
            
            var cell: UICollectionViewCell?
            if (identifier == PostCellCompact.identifier) {
                if (sizingCellCompact == nil) {
                    let cellArr = Bundle.main.loadNibNamed(PostCellCompact.identifier, owner: PostCellCompact.self, options: nil)! as NSArray
                    sizingCellCompact = (cellArr.object(at: 0) as? PostCellCompact)!
                }
                cell = sizingCellCompact
            } else if (identifier == PostCellText.identifier)  {
                if (sizingCellText == nil) {
                    let cellArr = Bundle.main.loadNibNamed(PostCellText.identifier, owner: PostCellText.self, options: nil)! as NSArray
                    sizingCellText = (cellArr.object(at: 0) as? PostCellText)!
                }
                cell = sizingCellText
            } else if (identifier == SocialCell.identifier)  {
                if (sizingCellSocial == nil) {
                    let cellArr = Bundle.main.loadNibNamed(SocialCell.identifier, owner: SocialCell.self, options: nil)! as NSArray
                    sizingCellSocial = (cellArr.object(at: 0) as? SocialCell)!
                }
                cell = sizingCellSocial
            }
            functionConfigureCell(cell!, indexPath)
            
            sizingCache[indexPath] = cell!.contentView.systemLayoutSizeFitting(size, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        }
        return sizingCache[indexPath]!
    }
}
