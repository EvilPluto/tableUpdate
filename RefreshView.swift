//
//  RefreshView.swift
//  tableUpdate
//
//  Created by mac on 16/12/14.
//  Copyright © 2016年 pluto. All rights reserved.
//

import UIKit

protocol RefreshViewDelegate: class {
    func refreshViewDidRefresh(_ refreshView: RefreshView)
}

private let kSceneHeight: CGFloat = 140.0

class RefreshView: UIView, UIScrollViewDelegate, RefreshViewDelegate {
    private unowned var scrollView: UIScrollView
    private var progress: CGFloat = 0.0
    
    var refreshItem = [RefreshItem]()
    weak var delegate: RefreshViewDelegate?
    
    var isRefreshing: Bool = false
    
    init(frame: CGRect, scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init(frame: frame)
        self.delegate = self
        self.updateBackgroundColor()
        self.setupRefreshItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupRefreshItems() {
        let groundImageView = UIImageView(image: UIImage(named: "ground"))
        let buildingsImageView = UIImageView(image: UIImage(named: "buildings"))
        let sunImageView = UIImageView(image: UIImage(named: "sun"))
        let catImageView = UIImageView(image: UIImage(named: "cat"))
        let cape_BackImageView = UIImageView(image: UIImage(named: "cape_back"))
        let cape_FrontImageView = UIImageView(image: UIImage(named: "cape_front"))
        
        self.refreshItem = [
            RefreshItem(
                view: buildingsImageView,
                centerEnd: CGPoint(x: self.bounds.midX, y: self.bounds.height - groundImageView.bounds.height - buildingsImageView.bounds.height / 2),
                parallaxRatio: 1.5,
                sceneHeight: kSceneHeight
            ),
            RefreshItem(
                view: sunImageView,
                centerEnd: CGPoint(x: self.bounds.width * 0.1, y: self.bounds.height - groundImageView.bounds.height - sunImageView.bounds.height),
                parallaxRatio: 3.0,
                sceneHeight: kSceneHeight
            ),
            RefreshItem(
                view: groundImageView,
                centerEnd: CGPoint(x: self.bounds.midX, y: self.bounds.height - groundImageView.bounds.height / 2),
                parallaxRatio: 0.5,
                sceneHeight: kSceneHeight
            ),
            RefreshItem(
                view: cape_BackImageView,
                centerEnd: CGPoint(x: self.bounds.midX, y: self.bounds.height - groundImageView.bounds.height),
                parallaxRatio: -1.5,
                sceneHeight: kSceneHeight
            ),
            RefreshItem(
                view: catImageView,
                centerEnd: CGPoint(x: self.bounds.midX, y: self.bounds.height - groundImageView.bounds.height),
                parallaxRatio: 0.5,
                sceneHeight: kSceneHeight
            ),
            RefreshItem(
                view: cape_FrontImageView,
                centerEnd: CGPoint(x: self.bounds.midX, y: self.bounds.height - groundImageView.bounds.height),
                parallaxRatio: -1.5,
                sceneHeight: kSceneHeight
            )
        ]
        
        for refreshItem in self.refreshItem {
            self.addSubview(refreshItem.view)
        }
    }
    
    func updateRefreshItemPositions() {
        for refreshItem in refreshItem {
            refreshItem.updateViewPositionForPercentage(self.progress)
        }
    }
    
    func updateBackgroundColor() {
        self.backgroundColor = UIColor(white: 0.7 * progress + 0.2, alpha: 1.0)
    }
    
    func beginRefreshing() {
        isRefreshing = true
        
        UIView.animate(
            withDuration: 1.0,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.scrollView.contentInset.top += kSceneHeight
            },
            completion: { (finished: Bool) -> Void in }
        )
    }
    
    func endRefreshing() {
        UIView.animate(
            withDuration: 1.0,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.scrollView.contentInset.top -= kSceneHeight
            },
            completion: { (finished: Bool) -> Void in
                self.isRefreshing = false
            }
        )
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !self.isRefreshing && self.progress == 1 {
            self.beginRefreshing()
            targetContentOffset.pointee.y = -scrollView.contentInset.top
            delegate?.refreshViewDidRefresh(self)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.isRefreshing {
            return
        }
        
        let refreshViewVisibleHeight = max(0, -self.scrollView.contentOffset.y - self.scrollView.contentInset.top)
        self.progress = min(1, refreshViewVisibleHeight / kSceneHeight)
        self.updateBackgroundColor()
        self.updateRefreshItemPositions()
    }
    
    /// MARK: Protocol RefreshViewDelegate - Method
    func refreshViewDidRefresh(_ refreshView: RefreshView) {
        UIView.animate(withDuration: 2.5, animations: {
            self.scrollView.alpha = 0.99 // 只是模拟等待时间
        }, completion: { (finished: Bool) -> Void in
            self.scrollView.alpha = 1.0 // 只是模拟等待时间
            self.endRefreshing()
        })
    }
}
