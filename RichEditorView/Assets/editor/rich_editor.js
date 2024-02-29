/**
 * Copyright (C) 2015 Wasabeef
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
"use strict";

var RE = {};

window.onload = function() {
    RE.callback("ready");
};

RE.editor = document.getElementById('editor');

// Not universally supported, but seems to work in iOS 7 and 8
document.addEventListener("selectionchange", function() {
    RE.backuprange();
});

RE.isEmpty = function(param) {
    return typeof param === 'undefined' || param === null;
};

RE.uniqueId = function() {
    var timestamp = Date.now().toString(16);
    var randomStr = Math.random().toString(16).substring(2);
    return timestamp + randomStr;
};

//looks specifically for a Range selection and not a Caret selection
RE.rangeSelectionExists = function() {
    //!! coerces a null to bool
    var sel = document.getSelection();
    if (sel && sel.type == "Range") {
        return true;
    }
    return false;
};

RE.rangeOrCaretSelectionExists = function() {
    //!! coerces a null to bool
    var sel = document.getSelection();
    if (sel && (sel.type == "Range" || sel.type == "Caret")) {
        return true;
    }
    return false;
};

RE.editor.addEventListener("input", function() {
    RE.updatePlaceholder();
    RE.backuprange();
    RE.callback("input");
});

RE.editor.addEventListener("focus", function() {
    RE.backuprange();
    RE.callback("focus");
});

RE.editor.addEventListener("blur", function() {
    RE.callback("blur");
});

RE.customAction = function(action) {
    RE.callback("action/" + action);
};

RE.updateHeight = function() {
    RE.callback("updateHeight");
};

RE.callbackQueue = [];
RE.runCallbackQueue = function() {
    if (RE.callbackQueue.length === 0) {
        return;
    }

    setTimeout(function() {
        window.location.href = "re-callback://";
    }, 0);
};

RE.getCommandQueue = function() {
    var commands = JSON.stringify(RE.callbackQueue);
    RE.callbackQueue = [];
    return commands;
};

RE.callback = function(method) {
    RE.callbackQueue.push(method);
    RE.runCallbackQueue();
};

RE.setHtml = function(contents) {
    var tempWrapper = document.createElement('div');
    tempWrapper.innerHTML = contents;
    
    var images = tempWrapper.querySelectorAll('img');
    for (var i = 0; i < images.length; i++) {
        images[i].onload = RE.updateHeight;
        images[i].setAttribute('id', RE.uniqueId());
        images[i].setAttribute('source-src', images[i].src);
        RE.customAction('presienedURL|' + images[i].id + '|' + images[i].src);
    }
    
    var videos = tempWrapper.querySelectorAll('video');
    for (var i = 0; i < videos.length; i++) {
        videos[i].onload = RE.updateHeight;
        videos[i].setAttribute('id', RE.uniqueId());
        videos[i].setAttribute('source-src', videos[i].src);
        videos[i].setAttribute('playsinline', 'true');
        videos[i].setAttribute('webkit-playsinline', 'true');
        videos[i].setAttribute('controls', 'controls');
        videos[i].setAttribute('preload', 'auto');
        RE.customAction('presienedURL|' + videos[i].id + '|' + videos[i].src);
    }

    RE.editor.innerHTML = tempWrapper.innerHTML;
    RE.updatePlaceholder();
};

RE.getTempWrapper = function() {
    var tempWrapper = document.createElement('div');
    tempWrapper.innerHTML = RE.editor.innerHTML;
    
    var images = tempWrapper.querySelectorAll('img');
    for (var i = 0; i < images.length; i++) {
        var sourceSrc = images[i].getAttribute('source-src');
        images[i].src = sourceSrc;
        images[i].removeAttribute('id');
        images[i].removeAttribute('source-src');
    }
    
    var videos = tempWrapper.querySelectorAll('video');
    for (var i = 0; i < videos.length; i++) {
        var sourceSrc = videos[i].getAttribute('source-src');
        videos[i].src = sourceSrc;
        videos[i].removeAttribute('id');
        videos[i].removeAttribute('source-src');
        videos[i].removeAttribute('playsinline');
        videos[i].removeAttribute('webkit-playsinline');
        videos[i].removeAttribute('preload');
    }
    
    return tempWrapper;
};

RE.getHtml = function() {
    return RE.getTempWrapper().innerHTML;
};

RE.getText = function() {
    return RE.getTempWrapper().innerText;
};

RE.getMultimedia = function() {
    var tempWrapper = RE.getTempWrapper();
    var multimedia = [];
    
    var images = tempWrapper.querySelectorAll('img');
    for (var i = 0; i < images.length; i++) {
        multimedia.push(images[i].src);
    }
    
    var videos = tempWrapper.querySelectorAll('video');
    for (var i = 0; i < videos.length; i++) {
        multimedia.push(videos[i].src);
    }
    
    return JSON.stringify(multimedia);
};

RE.setBaseTextColor = function(color) {
    RE.editor.style.color  = color;
};

RE.setPlaceholderText = function(text) {
    RE.editor.setAttribute('placeholder', text);
};

RE.updatePlaceholder = function() {
    if (RE.editor.innerHTML.indexOf('img') !== -1 || RE.editor.innerHTML.indexOf('video') !== -1 || (RE.editor.textContent.length > 0 && RE.editor.innerHTML.length > 0)) {
        RE.editor.classList.remove('placeholder');
    } else {
        RE.editor.classList.add('placeholder');
    }
};

RE.removeFormat = function() {
    document.execCommand('removeFormat', false, null);
};

RE.setFontSize = function(size) {
    RE.editor.style.fontSize = size;
};

RE.setPadding = function(top, left, bottom, right) {
    RE.editor.style.paddingTop = top + 'px';
    RE.editor.style.paddingLeft = left + 'px';
    RE.editor.style.paddingBottom = bottom + 'px';
    RE.editor.style.paddingRight = right + 'px';
};

RE.setBackgroundColor = function(color) {
    RE.editor.style.backgroundColor = color;
};

RE.setHeight = function(size) {
    RE.editor.style.height = size;
};

RE.undo = function() {
    document.execCommand('undo', false, null);
};

RE.redo = function() {
    document.execCommand('redo', false, null);
};

RE.setBold = function() {
    document.execCommand('bold', false, null);
};

RE.setItalic = function() {
    document.execCommand('italic', false, null);
};

RE.setSubscript = function() {
    document.execCommand('subscript', false, null);
};

RE.setSuperscript = function() {
    document.execCommand('superscript', false, null);
};

RE.setStrikeThrough = function() {
    document.execCommand('strikeThrough', false, null);
};

RE.setUnderline = function() {
    document.execCommand('underline', false, null);
};

RE.setTextColor = function(color) {
    RE.restorerange();
    document.execCommand('styleWithCSS', null, true);
    document.execCommand('foreColor', false, color);
    document.execCommand('styleWithCSS', null, false);
};

RE.setTextBackgroundColor = function(color) {
    RE.restorerange();
    document.execCommand('styleWithCSS', null, true);
    document.execCommand('hiliteColor', false, color);
    document.execCommand('styleWithCSS', null, false);
};

RE.setHeading = function(heading) {
    document.execCommand('formatBlock', false, '<h' + heading + '>');
};

RE.setEditorTag = function(tag){
    document.execCommand('formatBlock', false, '<' + tag + '>');
};

RE.setIndent = function() {
    document.execCommand('indent', false, null);
};

RE.setOutdent = function() {
    document.execCommand('outdent', false, null);
};

RE.setOrderedList = function() {
    document.execCommand('insertOrderedList', false, null);
};

RE.setUnorderedList = function() {
    document.execCommand('insertUnorderedList', false, null);
};

RE.setJustifyLeft = function() {
    document.execCommand('justifyLeft', false, null);
};

RE.setJustifyCenter = function() {
    document.execCommand('justifyCenter', false, null);
};

RE.setJustifyRight = function() {
    document.execCommand('justifyRight', false, null);
};

RE.getLineHeight = function() {
    return RE.editor.style.lineHeight;
};

RE.setLineHeight = function(height) {
    RE.editor.style.lineHeight = height;
};

RE.insertImage = function(url, alt) {
    RE.insertImage(url, alt, null);
};

RE.insertImage = function(url, alt, width) {
    RE.insertImage(url, alt, width, null);
};

RE.insertImage = function(url, alt, width, height) {
    var image = document.createElement('img');
    image.setAttribute('id', RE.uniqueId());
    image.setAttribute('src', url);
    image.setAttribute('source-src', url);
    image.setAttribute('alt', alt);
    if (RE.isEmpty(width) == false) {
        image.setAttribute('width', width);
    }
    if (RE.isEmpty(height) == false) {
        image.setAttribute('height', height);
    }
    image.onload = function() {
        RE.callback("input");
    }

    RE.insertHTML(image.outerHTML);
    RE.customAction('presienedURL|' + image.id + '|' + image.src);
    RE.callback("input");
};

RE.insertVideo = function(url) {
    RE.insertVideo(url, null);
};

RE.insertVideo = function(url, width) {
    RE.insertVideo(url, width, null);
};

RE.insertVideo = function(url, width, height) {
    var video = document.createElement('video');
    video.setAttribute('id', RE.uniqueId());
    video.setAttribute('src', url);
    video.setAttribute('source-src', url);
    if (RE.isEmpty(width) == false) {
        video.setAttribute('width', width);
    }
    if (RE.isEmpty(height) == false) {
        video.setAttribute('height', height);
    }
    video.setAttribute('playsinline', 'true');
    video.setAttribute('webkit-playsinline', 'true');
    video.setAttribute('controls', 'controls');
    video.setAttribute('preload', 'auto');
    video.onload = function() {
        RE.callback("input");
    }
    
    RE.insertHTML(video.outerHTML);
    RE.customAction('presienedURL|' + video.id + '|' + video.src);
    RE.callback("input");
};

RE.insertParagraph = function() {
    document.execCommand('insertParagraph', false, null);
};

RE.setBlockquote = function() {
    document.execCommand('formatBlock', false, '<blockquote>');
};

RE.insertHTML = function(html) {
    RE.restorerange();
    document.execCommand('insertHTML', false, html);
};

RE.insertLink = function(url, title) {
    RE.restorerange();
    var sel = document.getSelection();
    if (sel.toString().length == 0) {
        var el = document.createElement('a');
        el.setAttribute('href', url);
        el.setAttribute('title', title);
        el.innerHTML = title;
        
        RE.insertHTML(el.outerHTML);
    } else {
        if (sel.rangeCount) {
            var el = document.createElement("a");
            el.setAttribute('href', url);
            el.setAttribute('title', title);

            var range = sel.getRangeAt(0).cloneRange();
            range.surroundContents(el);
            sel.removeAllRanges();
            sel.addRange(range);
        }
    }
    RE.callback("input");
};

RE.setElementAttribute = function(id, name, value) {
    var el = document.getElementById(id);
    if (el) {
        el.setAttribute(name, value);
    }
};

RE.prepareInsert = function() {
    RE.backuprange();
};

RE.backuprange = function() {
    var selection = window.getSelection();
    if (selection.rangeCount > 0) {
        var range = selection.getRangeAt(0);
        RE.currentSelection = {
            "startContainer": range.startContainer,
            "startOffset": range.startOffset,
            "endContainer": range.endContainer,
            "endOffset": range.endOffset
        };
    }
};

RE.addRangeToSelection = function(selection, range) {
    if (selection) {
        selection.removeAllRanges();
        selection.addRange(range);
    }
};

// Programatically select a DOM element
RE.selectElementContents = function(el) {
    var range = document.createRange();
    range.selectNodeContents(el);
    var sel = window.getSelection();
    // this.createSelectionFromRange sel, range
    RE.addRangeToSelection(sel, range);
};

RE.restorerange = function() {
    var selection = window.getSelection();
    selection.removeAllRanges();
    var range = document.createRange();
    range.setStart(RE.currentSelection.startContainer, RE.currentSelection.startOffset);
    range.setEnd(RE.currentSelection.endContainer, RE.currentSelection.endOffset);
    selection.addRange(range);
};

RE.focus = function() {
    var range = document.createRange();
    range.selectNodeContents(RE.editor);
    range.collapse(false);
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    RE.editor.focus();
};

RE.focusAtPoint = function(x, y) {
    var range = document.caretRangeFromPoint(x, y) || document.createRange();
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    RE.editor.focus();
};

RE.blurFocus = function() {
    RE.editor.blur();
};

/**
Recursively search element ancestors to find a element nodeName e.g. A
**/
var _findNodeByNameInContainer = function(element, nodeName, rootElementId) {
    if (element.nodeName == nodeName) {
        return element;
    } else {
        if (element.id === rootElementId) {
            return null;
        }
        _findNodeByNameInContainer(element.parentElement, nodeName, rootElementId);
    }
};

var isAnchorNode = function(node) {
    return ("A" == node.nodeName);
};

RE.getAnchorTagsInNode = function(node) {
    var links = [];

    while (node.nextSibling !== null && node.nextSibling !== undefined) {
        node = node.nextSibling;
        if (isAnchorNode(node)) {
            links.push(node.getAttribute('href'));
        }
    }
    return links;
};

RE.countAnchorTagsInNode = function(node) {
    return RE.getAnchorTagsInNode(node).length;
};

RE.selectedText = function() {
    if (RE.rangeSelectionExists() == true) {
        return document.getSelection().toString();
    }
    return "";
};

/**
 * If the current selection's parent is an anchor tag, get the href.
 * @returns {string}
 */
RE.getSelectedHref = function() {
    var href, sel;
    href = '';
    sel = window.getSelection();
    if (!RE.rangeOrCaretSelectionExists()) {
        return null;
    }

    var tags = RE.getAnchorTagsInNode(sel.anchorNode);
    //if more than one link is there, return null
    if (tags.length > 1) {
        return null;
    } else if (tags.length == 1) {
        href = tags[0];
    } else {
        var node = _findNodeByNameInContainer(sel.anchorNode.parentElement, 'A', 'editor');
        href = node.href;
    }

    return href ? href : null;
};

// Returns the cursor position relative to its current position onscreen.
// Can be negative if it is above what is visible
RE.getRelativeCaretYPosition = function() {
    var y = 0;
    var sel = window.getSelection();
    if (sel.rangeCount) {
        var range = sel.getRangeAt(0);
        var needsWorkAround = (range.startOffset == 0)
        /* Removing fixes bug when node name other than 'div' */
        // && range.startContainer.nodeName.toLowerCase() == 'div');
        if (needsWorkAround) {
            y = range.startContainer.offsetTop - window.pageYOffset;
        } else {
            if (range.getClientRects) {
                var rects=range.getClientRects();
                if (rects.length > 0) {
                    y = rects[0].top;
                }
            }
        }
    }

    return y;
};
