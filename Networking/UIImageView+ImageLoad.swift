//
//  UIImageView+ImageLoad.swift
//  Networking
//
//  Created by Anton Kaizer on 22.01.16.
//  Copyright © 2016 Anton Kaizer. All rights reserved.
//

import UIKit

class AKImageLoadRequest : AKBaseURLProvider, AKDataResponse, AKSizedMemoryCacheSupport {
    init(urlString: String) {
        URL = urlString
    }
    var image: UIImage? = nil
    func processResponse(data: NSData?) {
        if data != nil {
            image = UIImage(data: data!)
        }
    }
    var URL: String
    var cacheKey: String { return URL.MD5 }
    var shouldStopOnCancel: Bool { return false }
    var isCached: Bool = false
    var cacheSize: Int {
        return image != nil ? (Int)(image!.size.width * image!.size.height * image!.scale) : 0
    }
}

internal var AKImageViewTaskKey: UInt8 = 0

public enum AKImageViewAnimated {
    case Animated
    case NotAnimated
    case ForceAnimated
}

public extension UIImageView {
    internal var task:AKRequestTask<AKImageLoadRequest>? {
        get {
            return objc_getAssociatedObject(self, &AKImageViewTaskKey) as? AKRequestTask<AKImageLoadRequest>
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AKImageViewTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public func setImageWithURL(url: String, animated: AKImageViewAnimated = .Animated)  {
        self.task?.cancel()
        self.task = AKRequestProvider.send(AKImageLoadRequest(urlString: url))
        self.task?.completion = {
                [weak self]
                (request) -> () in
            if ((!request.isCached && animated == .Animated) ||
                animated == .ForceAnimated) && self != nil {
                let transition = CATransition()
                transition.type = kCATransitionFade
                transition.duration = 0.3
                self?.layer.addAnimation(transition, forKey: "fadeIn")
            }
            self?.image = request.image
            self?.setNeedsLayout()
        }
    }
}