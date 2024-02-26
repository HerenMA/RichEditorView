//
//  KeyboardManager.swift
//  RichEditorViewSample
//
//  Created by Caesar Wirth on 4/5/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import RichEditorView
import UIKit

/**
 KeyboardManager is a class that takes care of showing and hiding the RichEditorToolbar when the keyboard is shown.
 As opposed to having this logic in multiple places, it is encapsulated in here. All that needs to change is the parent view.
 */
@objcMembers class KeyboardManager: NSObject {
    /**
         The parent view that the toolbar should be added to.
         Should normally be the top-level view of a UIViewController
     */
    weak var view: UIView?

    /**
         The toolbar that will be shown and hidden.
     */
    var toolbar: RichEditorToolbar

    init(view: UIView, delegate: RichEditorToolbarDelegate) {
        self.view = view
        toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: 44))
        toolbar.delegate = delegate
        toolbar.options = RichEditorDefaultOption.simple
    }

    /**
         Create a custom action to toolbar
     */
    func insertOptionButton(title: String, tag: Int, at: Int, action: @escaping ((_ toolbar: RichEditorToolbar) -> Void)) {
        insertOptionButton(title: title, tag: tag, at: at, fontSize: 18.0, action: action)
    }

    /**
         Create a custom action to toolbar
     */
    func insertOptionButton(title: String, tag: Int, at: Int, fontSize: CGFloat, action: @escaping ((_ toolbar: RichEditorToolbar) -> Void)) {
        insertOptionButton(title: title, tag: tag, at: at, fontSize: fontSize, bgSize: CGSize.zero, bgColor: UIColor.clear, action: action)
    }

    /**
         Create a custom action to toolbar
     */
    func insertOptionButton(title: String, tag: Int, at: Int, fontSize: CGFloat, bgSize: CGSize, bgColor: UIColor?, action: @escaping ((_ toolbar: RichEditorToolbar) -> Void)) {
        var options: [RichEditorOption] = toolbar.options

        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: fontSize)
        button.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 10, bottom: 0.0, right: 10)
        options.insert(RichEditorOptionItem(button: button, title: "", tag: tag, action: { toolbar in
            action(toolbar)
        }), at: at)

        if case let bgSize = bgSize, bgSize != CGSize.zero {
            let imageView = UIImageView(image: bgColor!.image(withSize: bgSize))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(imageView)
            button.sendSubviewToBack(imageView)

            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: bgSize.width),
                imageView.heightAnchor.constraint(equalToConstant: bgSize.height),
            ])
        }

        toolbar.options = options
    }

    /**
         Starts monitoring for keyboard notifications in order to show/hide the toolbar
     */
    func beginMonitoring() {
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardManager.keyboardWillShowOrHide(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardManager.keyboardWillShowOrHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    /**
         Stops monitoring for keyboard notifications
     */
    func stopMonitoring() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    /**
         Called when a keyboard notification is recieved. Takes are of handling the showing or hiding of the toolbar
     */
    @objc func keyboardWillShowOrHide(_ notification: Notification) {
        let info = (notification as NSNotification).userInfo ?? [:]
        let duration = TimeInterval((info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.25)
        let curve = UInt((info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0)
        let options = UIView.AnimationOptions(rawValue: curve)
        let keyboardRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero

        if notification.name == UIResponder.keyboardWillShowNotification {
            view?.addSubview(toolbar)
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                if let view = self.view {
                    self.toolbar.frame.origin.y = view.frame.height - (keyboardRect.height + self.toolbar.frame.height)
                }
            }, completion: nil)

        } else if notification.name == UIResponder.keyboardWillHideNotification {
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                if let view = self.view {
                    self.toolbar.frame.origin.y = view.frame.height
                }
            }, completion: nil)
        }
    }
}
