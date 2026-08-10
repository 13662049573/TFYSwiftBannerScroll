//
//  DemoImages.swift
//  TFYSwiftBannerScroll
//

import UIKit

enum DemoImages {
    /// Asset catalog imageset names (not file names like "1.jpg").
    static let all: [String] = [
        "1", "2", "3", "4", "5", "6", "7",
        "01", "02", "03", "04", "05", "06"
    ]
    
    static let banners: [String] = ["1", "2", "3", "4", "5", "6", "7"]
    
    static func image(named name: String) -> UIImage? {
        UIImage(named: name)
    }
}
