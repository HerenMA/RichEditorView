//
//  ObjCViewController.m
//  RichEditorViewSample
//
//  Created by Caesar Wirth on 9/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

#import "ObjCViewController.h"

#import "InfColorPickerController.h"
#import "RichEditorViewSample-Swift.h"

@interface ObjCViewController () <InfColorPickerControllerDelegate, RichEditorDelegate, RichEditorToolbarDelegate>
@property (nonatomic) BOOL viewAppeared;
@property (nonatomic) BOOL shouldFocus;
@property (nonatomic) BOOL isSetTextColor;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIColor *textBackgroundColor;
@end

UIKIT_EXTERN API_AVAILABLE(ios(14.0)) API_UNAVAILABLE(watchos, tvos) NS_SWIFT_UI_ACTOR
@interface ObjCViewController () <UIColorPickerViewControllerDelegate>
@end

/// <#Description#>
@implementation ObjCViewController

- (void)dealloc {
    (void)(_editorView.delegate = nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;

    self.textColor = UIColor.blackColor;
    self.textBackgroundColor = UIColor.clearColor;

    self.htmlTextView.hidden = YES;
    self.editorView.frame = self.view.bounds;
    self.editorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.editorView.translatesAutoresizingMaskIntoConstraints = false;
    self.editorView.delegate = self;
    self.editorView.inputAccessoryView = nil;
    self.editorView.placeholder = @"Type some text...";

    self.keyboardManager = [[KeyboardManager alloc] initWithView:self.view delegate:self];
    self.keyboardManager.toolbar.editor = self.editorView;

    [self.keyboardManager insertOptionButtonWithTitle:@"正文" tag:100 at:7 action:^(RichEditorToolbar *toolbar) {
         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

         UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
         [alertController addAction:cancelAction];

         NSArray *items = @[@"正文", @"一级标题", @"二级标题", @"三级标题", @"四级标题"];
         for (NSInteger i = 0; i < items.count; i++) {
             UIAlertAction *action = [UIAlertAction actionWithTitle:items[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                                          [toolbar setTitleWithTitle:action.title toTag:100];

                                          if ([action.title isEqualToString:@"正文"]) {
                                              [toolbar.editor editorTag:@"div"];
                                          } else if ([action.title isEqualToString:@"一级标题"]) {
                                              [toolbar.editor header:1];
                                          } else if ([action.title isEqualToString:@"二级标题"]) {
                                              [toolbar.editor header:2];
                                          } else if ([action.title isEqualToString:@"三级标题"]) {
                                              [toolbar.editor header:3];
                                          } else if ([action.title isEqualToString:@"四级标题"]) {
                                              [toolbar.editor header:4];
                                          }
                                      }];
             [alertController addAction:action];
         }
         [self presentViewController:alertController animated:YES completion:nil];
     }];

    [self.keyboardManager insertOptionButtonWithTitle:@"插入" tag:101 at:8 action:^(RichEditorToolbar *toolbar) {
         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

         UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
         [alertController addAction:cancelAction];

         NSArray *items = @[@"图片", @"视频", @"链接"];
         for (NSInteger i = 0; i < items.count; i++) {
             UIAlertAction *action = [UIAlertAction actionWithTitle:items[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                                          if ([action.title isEqualToString:@"图片"]) {
                                              [toolbar.editor insertImage:@"https://img2.baidu.com/it/u=1898128106,2722598876&fm=253" alt:@"" width:320];
                                          } else if ([action.title isEqualToString:@"视频"]) {
                                              [toolbar.editor insertVideo:@"https://www.w3school.com.cn/example/html5/mov_bbb.mp4" width:360];
                                              [toolbar.editor insertParagraph];
                                          } else if ([action.title isEqualToString:@"链接"]) {
                                              [toolbar.editor insertLink:@"http://github.com/cjwirth/RichEditorView" title:@"Github Link"];
                                          }
                                      }];
             [alertController addAction:action];
         }

         [self presentViewController:alertController animated:YES completion:nil];
     }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.keyboardManager beginMonitoring];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.keyboardManager stopMonitoring];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewAppeared = YES;
    if (self.shouldFocus) {
        self.shouldFocus = NO;
        [self.editorView focus];
    }
}

/// <#Description#>
/// - Parameter color: <#color description#>
- (void)showColorPicker:(UIColor *)color {
    if (@available(iOS 14.0, *)) {
        UIColorPickerViewController *picker = [[UIColorPickerViewController alloc] init];
        picker.delegate = self;
        picker.selectedColor = color;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        InfColorPickerController *picker = [InfColorPickerController colorPickerViewController];
        picker.delegate = self;
        picker.sourceColor = color;
        [picker presentModallyOverViewController:self];
    }
}

//------------------------------------------------------------------------------
#pragma mark - InfColorPickerControllerDelegate
/// <#Description#>
/// - Parameter controller: <#controller description#>
- (void)colorPickerControllerDidFinish:(InfColorPickerController *)controller {
    [controller dismissViewControllerAnimated:YES completion:^{
         [self colorPickerControllerDidChangeColor:controller];
     }];
}

/// <#Description#>
/// - Parameter controller: <#controller description#>
- (void)colorPickerControllerDidChangeColor:(InfColorPickerController *)controller {
    if (self.isSetTextColor) {
        self.textColor = controller.resultColor;
        [self.keyboardManager.toolbar.editor setTextColor:controller.resultColor];
    } else {
        self.textBackgroundColor = controller.resultColor;
        [self.keyboardManager.toolbar.editor setTextBackgroundColor:controller.resultColor];
    }
}

#pragma mark - UIColorPickerViewControllerDelegate
/// <#Description#>
/// - Parameter viewController: <#viewController description#>
- (void)colorPickerViewControllerDidSelectColor:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    if (self.isSetTextColor) {
        self.textColor = viewController.selectedColor;
        [self.keyboardManager.toolbar.editor setTextColor:viewController.selectedColor];
    } else {
        self.textBackgroundColor = viewController.selectedColor;
        [self.keyboardManager.toolbar.editor setTextBackgroundColor:viewController.selectedColor];
    }
}

#pragma mark - RichEditorViewDelegate
/// <#Description#>
/// - Parameters:
///   - editor: <#editor description#>
///   - content: <#content description#>
- (void)richEditor:(RichEditorView *__nonnull)editor contentDidChange:(NSString *__nonnull)content {
    if (content.length == 0) {
        self.htmlTextView.text = @"HTML Preview";
    } else {
        self.htmlTextView.text = content;
        NSLog(@"content: %@", content);
    }
}

/// <#Description#>
/// - Parameter editor: <#editor description#>
- (void)richEditorDidLoad:(RichEditorView *)editor {
    if (self.viewAppeared) {
        [self.editorView focus];
    } else {
        self.shouldFocus = YES;
    }
}

#pragma mark - RichEditorToolbarDelegate
/// <#Description#>
/// - Parameter toolbar: <#toolbar description#>
- (void)richEditorToolbarChangeTextColor:(RichEditorToolbar *)toolbar {
    self.isSetTextColor = YES;
    [self showColorPicker:self.textColor];
}

/// <#Description#>
/// - Parameter toolbar: <#toolbar description#>
- (void)richEditorToolbarChangeBackgroundColor:(RichEditorToolbar *)toolbar {
    self.isSetTextColor = NO;
    [self showColorPicker:self.textBackgroundColor];
}

@end
