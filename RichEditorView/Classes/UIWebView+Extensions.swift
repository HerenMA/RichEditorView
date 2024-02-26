//
//  UIWebView+Extensions.swift
//  RichEditorView
//
//  Created by Pankaj Tejawat on 15/06/20.
//

import WebKit

var ToolbarHandle: UInt8 = 0

extension WKWebView {
    func addInputAccessoryView(toolbar: UIView?) {
        objc_setAssociatedObject(self, &ToolbarHandle, toolbar, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        var candidateView: UIView?
        for view in scrollView.subviews {
            let description: String = String(describing: type(of: view))
            if description.hasPrefix("WKContent") {
                candidateView = view
                break
            }
        }
        guard let targetView = candidateView else { return }
        let newClass: AnyClass? = classWithCustomAccessoryView(targetView: targetView)

        guard let targetNewClass = newClass else { return }

        object_setClass(targetView, targetNewClass)
    }

    func classWithCustomAccessoryView(targetView: UIView) -> AnyClass? {
        guard let _ = targetView.superclass else { return nil }
        let customInputAccesoryViewClassName = "_CustomInputAccessoryView"

        var newClass: AnyClass? = NSClassFromString(customInputAccesoryViewClassName)
        if newClass == nil {
            newClass = objc_allocateClassPair(object_getClass(targetView), customInputAccesoryViewClassName, 0)
        } else {
            return newClass
        }

        let newMethod = class_getInstanceMethod(WKWebView.self, #selector(WKWebView.getCustomInputAccessoryView))
        class_addMethod(newClass.self, #selector(getter: WKWebView.inputAccessoryView), method_getImplementation(newMethod!), method_getTypeEncoding(newMethod!))

        objc_registerClassPair(newClass!)

        return newClass
    }

    @objc func getCustomInputAccessoryView() -> UIView? {
        var superWebView: UIView? = self
        while (superWebView != nil) && !(superWebView is WKWebView) {
            superWebView = superWebView?.superview
        }

        guard let webView = superWebView else { return nil }

        let customInputAccessory = objc_getAssociatedObject(webView, &ToolbarHandle)
        return customInputAccessory as? UIView
    }

    func evaluate(script: String, completion: @escaping (Any?, Error?) -> Void) {
        var finished = false
        evaluateJavaScript(script, completionHandler: { result, error in
            completion(result, error)
            finished = true
        })

        while !finished {
            RunLoop.current.run(mode: RunLoop.Mode.default, before: .distantFuture)
        }
    }
}

extension WKWebView {
    typealias OldClosureType = @convention(c) (Any, Selector, UnsafeRawPointer, Bool, Bool, Any?) -> Void
    typealias NewClosureType = @convention(c) (Any, Selector, UnsafeRawPointer, Bool, Bool, Bool, Any?) -> Void

    func setKeyboardRequiresUserInteraction(_ value: Bool) {
        guard let WKContentViewClass: AnyClass = NSClassFromString("WKContentView") else {
            print("Cannot find the WKContentView class")
            return
        }

        let olderSelector: Selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:")
        let newSelector: Selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:")
        let newerSelector: Selector = sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:changingActivityState:userObject:")
        let ios13Selector: Selector = sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:activityStateChanges:userObject:")

        if let method = class_getInstanceMethod(WKContentViewClass, olderSelector) {
            let originalImp: IMP = method_getImplementation(method)
            let original: OldClosureType = unsafeBitCast(originalImp, to: OldClosureType.self)
            let block: @convention(block) (Any, UnsafeRawPointer, Bool, Bool, Any?) -> Void = { me, arg0, _, arg2, arg3 in
                original(me, olderSelector, arg0, !value, arg2, arg3)
            }
            let imp: IMP = imp_implementationWithBlock(block)
            method_setImplementation(method, imp)
        }

        if let method = class_getInstanceMethod(WKContentViewClass, newSelector) {
            swizzleAutofocusMethod(method, newSelector, value)
        }

        if let method = class_getInstanceMethod(WKContentViewClass, newerSelector) {
            swizzleAutofocusMethod(method, newerSelector, value)
        }

        if let method = class_getInstanceMethod(WKContentViewClass, ios13Selector) {
            swizzleAutofocusMethod(method, ios13Selector, value)
        }
    }

    func swizzleAutofocusMethod(_ method: Method, _ selector: Selector, _ value: Bool) {
        let originalImp: IMP = method_getImplementation(method)
        let original: NewClosureType = unsafeBitCast(originalImp, to: NewClosureType.self)
        let block: @convention(block) (Any, UnsafeRawPointer, Bool, Bool, Bool, Any?) -> Void = { me, arg0, _, arg2, arg3, arg4 in
            original(me, selector, arg0, !value, arg2, arg3, arg4)
        }
        let imp: IMP = imp_implementationWithBlock(block)
        method_setImplementation(method, imp)
    }
}
