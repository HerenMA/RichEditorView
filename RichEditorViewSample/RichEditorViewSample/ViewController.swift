//
//  ViewController.swift
//  RichEditorViewSample
//
//  Created by Caesar Wirth on 4/5/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import RichEditorView
import UIKit

class ViewController: UIViewController {
    @IBOutlet var editorView: RichEditorView! {
        didSet {
            editorView.editingTextColor = "#FF0000"
        }
    }

    @IBOutlet var htmlTextView: UITextView!

    private var viewAppeared: Bool = false
    private var shouldFocus: Bool = false

    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorDefaultOption.all
        return toolbar
    }()

    lazy var createOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create", for: .normal)
        button.backgroundColor = .magenta
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14.0)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        button.layer.cornerRadius = 5.0
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        editorView.delegate = self
        editorView.inputAccessoryView = toolbar
        editorView.placeholder = "Type some text..."

        toolbar.delegate = self
        toolbar.editor = editorView

        // We will create a custom action that clears all the input text when it is pressed
        let item = RichEditorOptionItem(image: nil, title: "Clear", tag: 0) { toolbar in
            toolbar.editor?.html = ""
        }

        var options: [RichEditorOption] = toolbar.options
        options.append(item)
        options.append(RichEditorOptionItem(button: createOptionButton, title: "", tag: 001, action: { _ in
            print("Create button tapped")
        }))
        toolbar.options = options
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        viewAppeared = true
        if shouldFocus {
            shouldFocus = false
            editorView.focus()
        }
    }

    @objc func onToolbarDoneClick(sender: UIBarButtonItem) {
        editorView.webView.resignFirstResponder()
    }
}

extension ViewController: RichEditorDelegate {
    func richEditorDidLoad(_ editor: RichEditorView) {
        print("richEditorDidLoad")
        if viewAppeared {
            editorView.focus()
        } else {
            shouldFocus = true
        }
    }

    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        if content.isEmpty {
            htmlTextView.text = "HTML Preview"
        } else {
            htmlTextView.text = content
        }
    }
}

extension ViewController: RichEditorToolbarDelegate {
    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple,
        ]

        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }

    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }

    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }

    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        toolbar.editor?.insertImage("https://gravatar.com/avatar/696cf5da599733261059de06c4d1fe22", alt: "Gravatar")
    }

    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        toolbar.editor?.hasRangeSelection(handler: { r in
            if r == true {
                toolbar.editor?.insertLink("http://github.com/cjwirth/RichEditorView", title: "Github Link")
            }
        })
    }
}
