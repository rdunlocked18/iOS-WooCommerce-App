//
//  HideableCollectionViewController.swift
//  Universal
//
//  Created by Mark on 30/09/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation
import AMScrollingNavbar

/**
 A custom `UIViewController` that implements the base configuration.
 */
@objc open class HideableCollectionViewController: UICollectionViewController , UINavigationControllerDelegate {

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Scrolling Navbar
        if let navigationController = navigationController as? ScrollingNavigationController, AppDelegate.HIDING_NAVIGATIONBAR {
            navigationController.followScrollView(collectionView, delay: 50.0)
            navigationController.shouldUpdateContentInset = false
        }
    }
        
  // MARK: - ScrollView config

  /**
   On appear calls `showNavbar()` by default
   */
  override open func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let navigationController = self.navigationController as? ScrollingNavigationController {
      navigationController.showNavbar(animated: true)
    }
  }

  /**
   On disappear calls `stopFollowingScrollView()` to stop observing the current scroll view, and perform the tear down
   */
  override open func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    if let navigationController = self.navigationController as? ScrollingNavigationController {
      navigationController.stopFollowingScrollView()
    }
  }

  /**
   Calls `showNavbar()` when a `scrollToTop` is requested
   */
    open override func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if let navigationController = self.navigationController as? ScrollingNavigationController {
          navigationController.showNavbar(animated: true)
        }
        return true
    }

}
