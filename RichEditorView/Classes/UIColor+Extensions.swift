//
//  UIColor+Extensions.swift
//  Pods
//
//  Created by Caesar Wirth on 10/9/16.
//
//

import UIKit

public extension UIColor {
    /// Hexadecimal representation of the UIColor.
    /// For example, UIColor.blackColor() becomes "#000000".
    var hex: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)

        let r = Int(255.0 * red)
        let g = Int(255.0 * green)
        let b = Int(255.0 * blue)

        let str = String(format: "#%02x%02x%02x", r, g, b)
        return str
    }

    func image(withSize size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        setFill()
        context.fill(CGRect(origin: .zero, size: size))

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
