//
//  SBUMessageTemplate.Renderer+RenderItems.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/10/14.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUMessageTemplate.Renderer {
    
    func render(template: SBUMessageTemplate.Syntax.TemplateView) -> Bool {
        guard let body = template.body else { return false }
        
        // AutoLayout
        self.addSubview(self.contentView)
        self.rendererConstraints += self.contentView.sbu_constraint_v2(
            equalTo: self,
            leading: 0,
            trailing: 0,
            top: 0,
            bottom: 0
        )
        
        // Render subview
        self.contentView.addSubview(self.bodyView)
        self.rendererConstraints += self.bodyView.sbu_constraint_v2(
            equalTo: self.contentView,
            leading: 0,
            trailing: 0,
            top: 0,
            bottom: 0
        )
        
        self.renderBody(body)
        self.rendererConstraints.forEach { $0.isActive = true }
        return true
    }
    
    // MARK: - Body
    func renderBody(_ body: SBUMessageTemplate.Syntax.Body) {
        guard let items = body.items else { return }
        
        var prevView: UIView = self.bodyView
        var prevItem: SBUMessageTemplate.Syntax.View?
        var currentView: UIView = self.bodyView
        for (index, item) in items.enumerated() {
            let isLastItem = (index == items.count - 1)

            switch item {
            case .box(let boxItem):
                let boxView = self.renderBox(
                    item: boxItem,
                    parentView: self.bodyView,
                    prevView: prevView,
                    prevItem: prevItem,
                    isLastItem: isLastItem
                )
                currentView = boxView
                self.bodyView.addSubview(boxView)
                prevItem = boxItem
                
            case .text(let textItem):
                let textLabel = self.renderText(
                    item: textItem,
                    parentView: self.bodyView,
                    prevView: prevView,
                    prevItem: prevItem,
                    isLastItem: isLastItem
                )
                currentView = textLabel
                self.bodyView.addSubview(textLabel)
                prevItem = textItem
                
            case .image(let imageItem):
                let imageView = self.renderImage(
                    item: imageItem,
                    parentView: self.bodyView,
                    prevView: prevView,
                    prevItem: prevItem,
                    isLastItem: isLastItem
                )
                currentView = imageView
                self.bodyView.addSubview(imageView)
                prevItem = imageItem
                
            case .textButton(let textButtonItem):
                let textButton = self.renderTextButton(
                    item: textButtonItem,
                    parentView: self.bodyView,
                    prevView: prevView,
                    prevItem: prevItem,
                    isLastItem: isLastItem
                )
                currentView = textButton
                self.bodyView.addSubview(textButton)
                prevItem = textButtonItem
                
            case .imageButton(let imageButtonItem):
                let imageButton = self.renderImageButton(
                    item: imageButtonItem,
                    parentView: self.bodyView,
                    prevView: prevView,
                    prevItem: prevItem,
                    isLastItem: isLastItem
                )
                currentView = imageButton
                self.bodyView.addSubview(imageButton)
                prevItem = imageButtonItem
                    
            case .carouselView(let carouselItem):
                let carouselView = self.renderCarouselView(
                    item: carouselItem,
                    parentView: self.bodyView,
                    prevView: prevView,
                    isLastItem: isLastItem
                )
                currentView = carouselView
                self.bodyView.addSubview(carouselView)
                prevItem = carouselItem
            }

            prevView = currentView
        }
    }
    
    // MARK: - Box
    func renderBox(
        item: SBUMessageTemplate.Syntax.Box,
        parentView: UIView,
        prevView: UIView,
        prevItem: SBUMessageTemplate.Syntax.View? = nil,
        itemsAlign: SBUMessageTemplate.Syntax.ItemsAlign? = .defaultAlign(),
        layout: SBUMessageTemplate.Syntax.LayoutType = .column,
        isLastItem: Bool = false
    ) -> UIView {
        let baseView = SBUMessageTemplate.Renderer.BoxBaseView(item: item, layout: layout)
        let boxView = SBUMessageTemplate.Renderer.BoxView()
        boxView.layout = layout
        baseView.clipsToBounds = true
        
        baseView.addSubview(boxView)
        parentView.addSubview(baseView)
        
        // Items
        self.renderBoxItems(item, parentView: baseView)
        
        // View Style
        self.renderViewStyle(with: item, to: baseView)
        
        // Layout
        self.renderViewLayout(
            with: item,
            to: baseView,
            parentView: parentView,
            prevView: prevView,
            prevItem: prevItem,
            itemsAlign: itemsAlign,
            layout: layout,
            isLastItem: isLastItem
        )
        
        // Action
        self.setAction(on: baseView, item: item)
        
        return baseView
    }
    
    // MARK: BoxItems
    func renderBoxItems(
        _ item: SBUMessageTemplate.Syntax.Box,
        parentView: UIView
    ) {
        guard let items = item.items else { return }
        
        let parentBoxView = parentView.subviews[0]
        // INFO: SideViews are placed at the top/bottom or left/right and used for align. According to Align, the area of the SideView is adjusted in the form of holding the position of the actual item.
        let sideView1 = UIView()
        sideView1.tag = Self.sideViewTypeLeft
        let sideView2 = UIView()
        sideView2.tag = Self.sideViewTypeRight
        parentBoxView.addSubview(sideView1)
        
        var prevView: UIView = sideView1
        var prevItem: SBUMessageTemplate.Syntax.View?
        var currentView: UIView = sideView1
        let itemsAlign = item.align
        let layout = item.layout
        
        var haveWidthFillParent = false
        var heightFillParentCount = 0
        var haveHeightFillParent = false
        
        for (index, item) in items.enumerated() {
            let isLastItem = false// edge case (wrap contents separate issue)
            
            switch item {
            case .box(let boxItem):
                let boxView = self.renderBox(
                    item: boxItem,
                    parentView: parentBoxView,
                    prevView: prevView,
                    prevItem: prevItem,
                    itemsAlign: itemsAlign,
                    layout: layout,
                    isLastItem: isLastItem
                )
                currentView = boxView
                prevItem = boxItem
                
            case .text(let textItem):
                let textLabel = self.renderText(
                    item: textItem,
                    parentView: parentBoxView,
                    prevView: prevView,
                    prevItem: prevItem,
                    itemsAlign: itemsAlign,
                    layout: layout,
                    isLastItem: isLastItem
                )
                currentView = textLabel
                prevItem = textItem
                
            case .image(let imageItem):
                let imageView = self.renderImage(
                    item: imageItem,
                    parentView: parentBoxView,
                    prevView: prevView,
                    prevItem: prevItem,
                    itemsAlign: itemsAlign,
                    layout: layout,
                    isLastItem: isLastItem
                )
                currentView = imageView
                prevItem = imageItem
                
            case .textButton(let textButtonItem):
                let textButton = self.renderTextButton(
                    item: textButtonItem,
                    parentView: parentBoxView,
                    prevView: prevView,
                    prevItem: prevItem,
                    itemsAlign: itemsAlign,
                    layout: layout
                )
                currentView = textButton
                prevItem = textButtonItem
                
            case .imageButton(let imageButtonItem):
                let imageButton = self.renderImageButton(
                    item: imageButtonItem,
                    parentView: parentBoxView,
                    prevView: prevView,
                    prevItem: prevItem,
                    itemsAlign: itemsAlign,
                    layout: layout,
                    isLastItem: isLastItem
                )
                currentView = imageButton
                prevItem = imageButtonItem
                    
            case .carouselView:
                // INFO: Carousel views are render only in root body.
                break
            }
            
            if prevItem?.width.type == .flex,
               prevItem?.width.value == flexTypeFillValue {
                haveWidthFillParent = true
            }
            if prevItem?.height.type == .flex,
               prevItem?.height.value == flexTypeFillValue {
                heightFillParentCount += 1
                haveHeightFillParent = true
            }

            parentBoxView.addSubview(currentView)
            prevView = currentView
            currentView.setContentHuggingPriority(UILayoutPriority(Float(250 - index)), for: .horizontal)
        }
        
        parentBoxView.addSubview(sideView2)
        
        if item.layout == .row {
            self.rendererConstraints += sideView1.sbu_constraint_v2(equalTo: parentBoxView, top: 0, bottom: 0)
            self.rendererConstraints += sideView2.sbu_constraint_v2(equalTo: parentBoxView, top: 0, bottom: 0)
            
            self.rendererConstraints += sideView1.sbu_constraint_v2(equalTo: parentBoxView, left: 0)
            self.rendererConstraints += sideView2.sbu_constraint_v2(equalTo: parentBoxView, right: 0)
            
            if haveWidthFillParent || item.align.horizontal == .center {
                sideView1.widthAnchor.constraint(
                    equalTo: sideView2.widthAnchor,
                    multiplier: 1.0
                ).isActive = true
            }
            
            // INFO: When all items are fill type, the horizontal widths are the same
            let fillParentViews = parentBoxView
                .subviews
                .compactMap { $0 as? SBUMessageTemplate.Renderer.BaseView }
                .filter {
                    ($0.width.type == .flex)
                    && ($0.width.value == flexTypeFillValue)
                }
            let filleParentBaseWidthAnchor = fillParentViews.first?.widthAnchor

            if let filleParentBaseWidthAnchor = filleParentBaseWidthAnchor {
                for view in fillParentViews {
                    view.widthAnchor.constraint(
                        equalTo: filleParentBaseWidthAnchor,
                        multiplier: 1.0
                    ).isActive = true
                }
            }
            
            switch item.align.horizontal {
            case .left:
                self.rendererConstraints += sideView1.sbu_constraint_v2(width: 0)
                self.rendererConstraints += sideView2.sbu_constraint_greaterThan_v2(width: 0)
            case .center:
                if haveWidthFillParent {
                    self.rendererConstraints += sideView1.sbu_constraint_v2(width: 0)
                } else {
                    self.rendererConstraints += sideView1.sbu_constraint_greaterThan_v2(width: 0)
                }
                self.rendererConstraints += sideView2.sbu_constraint_greaterThan_v2(width: 0)
            case .right:
                self.rendererConstraints += sideView1.sbu_constraint_greaterThan_v2(width: 0)
                self.rendererConstraints += sideView2.sbu_constraint_v2(width: 0)
            default:
                break
            }
            
            let prevItemRightMargin = prevItem?.viewStyle?.margin?.right ?? 0.0
            self.rendererConstraints += sideView2.sbu_constraint_equalTo_v2(
                leftAnchor: prevView.rightAnchor,
                left: (item.viewStyle?.margin?.left ?? 0.0) + prevItemRightMargin
            )
        } else { // column
            self.rendererConstraints += sideView1.sbu_constraint_v2(equalTo: parentBoxView, left: 0, right: 0)
            self.rendererConstraints += sideView2.sbu_constraint_v2(equalTo: parentBoxView, left: 0, right: 0)
            
            self.rendererConstraints += sideView1.sbu_constraint_v2(equalTo: parentBoxView, top: 0)
            self.rendererConstraints += sideView2.sbu_constraint_v2(equalTo: parentBoxView, bottom: 0)
            
            if haveHeightFillParent || item.align.vertical == .center {
                sideView1.heightAnchor.constraint(
                    equalTo: sideView2.heightAnchor,
                    multiplier: 1.0
                ).isActive = true
            }
            
            // INFO: When all items are fill type, the vertical heights are the same
            let fillParentViews = parentBoxView
                .subviews
                .compactMap { $0 as? SBUMessageTemplate.Renderer.BaseView }
                .filter {
                    ($0.height.type == .flex)
                    && ($0.height.value == flexTypeFillValue)
                }
            let filleParentBaseHeightAnchor = fillParentViews.first?.heightAnchor

            if let filleParentBaseHeightAnchor = filleParentBaseHeightAnchor {
                for view in fillParentViews {
                    view.heightAnchor.constraint(
                        equalTo: filleParentBaseHeightAnchor,
                        multiplier: 1.0
                    ).isActive = true
                }
            }
            
            switch item.align.vertical {
            case .top:
                self.rendererConstraints += sideView1.sbu_constraint_v2(height: 0)
                self.rendererConstraints += sideView2.sbu_constraint_greaterThan_v2(height: 0)
            case .center:
                if haveHeightFillParent {
                    self.rendererConstraints += sideView1.sbu_constraint_v2(height: 0)
                } else {
                    self.rendererConstraints += sideView1.sbu_constraint_greaterThan_v2(height: 0)
                }
                self.rendererConstraints += sideView2.sbu_constraint_greaterThan_v2(height: 0)
            case .bottom:
                self.rendererConstraints += sideView1.sbu_constraint_greaterThan_v2(height: 0)
                self.rendererConstraints += sideView2.sbu_constraint_v2(height: 0)
            default:
                break
            }
            
            let prevItemBottomMargin = prevItem?.viewStyle?.margin?.bottom ?? 0.0
            self.rendererConstraints += sideView2.sbu_constraint_equalTo_v2(
                topAnchor: prevView.bottomAnchor,
                top: prevItemBottomMargin
            )
        }
    }
    
    // MARK: - Text
    func renderText(
        item: SBUMessageTemplate.Syntax.Text,
        parentView: UIView,
        prevView: UIView,
        prevItem: SBUMessageTemplate.Syntax.View? = nil,
        itemsAlign: SBUMessageTemplate.Syntax.ItemsAlign? = .defaultAlign(),
        layout: SBUMessageTemplate.Syntax.LayoutType = .column,
        isLastItem: Bool = false
    ) -> UIView {
        return renderCommonText(
            item: item,
            parentView: parentView,
            prevView: prevView,
            prevItem: prevItem,
            itemsAlign: itemsAlign,
            layout: layout,
            isLastItem: isLastItem
        )
    }
    
    // MARK: - TextButton
    func renderTextButton(
        item: SBUMessageTemplate.Syntax.TextButton,
        parentView: UIView,
        prevView: UIView,
        prevItem: SBUMessageTemplate.Syntax.View? = nil,
        itemsAlign: SBUMessageTemplate.Syntax.ItemsAlign? = .defaultAlign(),
        layout: SBUMessageTemplate.Syntax.LayoutType = .column,
        isLastItem: Bool = false
    ) -> UIView {
        return renderCommonText(
            item: item,
            parentView: parentView,
            prevView: prevView,
            prevItem: prevItem,
            itemsAlign: itemsAlign,
            layout: layout,
            isLastItem: isLastItem
        )
    }
    
    // MARK: - CommonText: Text, TextButton
    func renderCommonText(
        item: SBUMessageTemplate.Syntax.View,
        parentView: UIView,
        prevView: UIView,
        prevItem: SBUMessageTemplate.Syntax.View? = nil,
        itemsAlign: SBUMessageTemplate.Syntax.ItemsAlign? = .defaultAlign(),
        layout: SBUMessageTemplate.Syntax.LayoutType = .column,
        isLastItem: Bool = false
    ) -> UIView {

        let isTextButton = (item is SBUMessageTemplate.Syntax.TextButton)
        
        let baseView = isTextButton
        ? SBUMessageTemplate.Renderer.TextButtonBaseView(item: item, layout: layout)
        : SBUMessageTemplate.Renderer.TextBaseView(item: item, layout: layout)
        baseView.clipsToBounds = true

        var text: String?
        var numberOfLines = 0
        var textStyle: SBUMessageTemplate.Syntax.TextStyle?
        var textAlign: SBUMessageTemplate.Syntax.TextAlign?
        
        switch item {
        case let textItem as SBUMessageTemplate.Syntax.Text:
            text = textItem.text
            numberOfLines = textItem.maxTextLines
            textStyle = textItem.textStyle
            textAlign = textItem.align
        case let textButtonItem as SBUMessageTemplate.Syntax.TextButton:
            text = textButtonItem.text
            numberOfLines = textButtonItem.maxTextLines
            textStyle = textButtonItem.textStyle
        default:
            break
        }
        
        let label = isTextButton ? SBUMessageTemplate.Renderer.TextButton() : SBUMessageTemplate.Renderer.Label()
        label.padding = item.viewStyle?.padding
        label.updateLayoutHandler = { constraints, deactivatedConstraints in
            self.rendererConstraints.forEach { $0.isActive = false }
            self.rendererConstraints += constraints
            self.rendererConstraints = self.rendererConstraints.filter { !deactivatedConstraints.contains($0) }
            self.rendererConstraints.forEach { $0.isActive = true }
        }
        
        let textWithoutLineChange: NSAttributedString? = {
            guard let text = text else { return nil }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakStrategy = .pushOut
            let attributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle]
            return NSAttributedString(
                string: text,
                attributes: attributes
            )
        }()
        
        label.attributedText = textWithoutLineChange
        
        label.numberOfLines = numberOfLines
        label.lineBreakMode = .byTruncatingTail
        label.clipsToBounds = isTextButton
        
        // INFO: Edge case - text wrap issue
        if baseView.layout == .row {
            let totalTextWidth = parentView
                .subviews
                .compactMap { $0.subviews.first as? SBUMessageTemplate.Renderer.Label }
                .filter { $0.isWrapTypeWidth }
                .reduce(0) { $0 + $1.fullTextViewWidth }
            
            if self.maxWidth > 0, totalTextWidth >= self.maxWidth {
                label.numberOfLines = 1
            }
        }
        
        baseView.addSubview(label)
        parentView.addSubview(baseView)
        
        // Text Style
        if let textStyle = textStyle {
            var fontSize = self.themeForDefault.textFont.pointSize
            if let size = textStyle.size {
                fontSize = CGFloat(size)
            }
            
            switch textStyle.weight {
            case .normal:
                label.font = self.templateFont(size: fontSize)
            case .bold:
                label.font = self.templateFont(size: fontSize, weight: .bold)
            case .none:
                break
            }
            
            if let textColor = textStyle.color {
                label.textColor = UIColor(hexString: textColor)
            } else {
                if item is SBUMessageTemplate.Syntax.TextButton {
                    label.textColor = self.themeForDefault.textButtonTitleColor
                } else {
                    label.textColor = self.themeForDefault.textColor
                }
            }
            
        } else {
            label.font = self.templateFont(size: self.themeForDefault.textFont.pointSize)
            if item is SBUMessageTemplate.Syntax.TextButton {
                label.textColor = self.themeForDefault.textButtonTitleColor
            } else {
                label.textColor = self.themeForDefault.textColor
            }
            label.contentMode = .center // TODO: check
            label.textAlignment = .left
        }
        
        if let textAlign = textAlign {
            switch textAlign.vertical {
            case .top:
                label.contentMode = .top
            case .center:
                label.contentMode = .center
            case .bottom:
                label.contentMode = .bottom
            case .none:
                break
            }
            
            switch textAlign.horizontal {
            case .left:
                label.textAlignment = .left
            case .center:
                label.textAlignment = .center
            case .right:
                label.textAlignment = .right
            case .none:
                break
            }
        } else {
            // Text(no textAlign) | TextButton
            label.contentMode = .center
            label.textAlignment = .center
        }
        
        // View Style
        self.renderViewStyle(with: item, to: baseView)
        
        // Layout
        self.renderViewLayout(
            with: item,
            to: baseView,
            parentView: parentView,
            prevView: prevView,
            prevItem: prevItem,
            itemsAlign: itemsAlign,
            layout: layout,
            isLastItem: isLastItem
        )
        
        if baseView.layout == .row {
            if item.width.type == .flex, item.width.value == flexTypeWrapValue {
                label.setContentCompressionResistancePriority(UILayoutPriority(751), for: NSLayoutConstraint.Axis.horizontal)
            }
        } else {
            if item.height.type == .flex, item.height.value == flexTypeWrapValue {
                label.setContentCompressionResistancePriority(UILayoutPriority(751), for: NSLayoutConstraint.Axis.vertical)
            }
        }
        
        if label.numberOfLines == 0 {
            label.setContentCompressionResistancePriority(UILayoutPriority(751), for: NSLayoutConstraint.Axis.vertical)
        }
        
        // Action
        self.setAction(on: baseView, item: item)
        
        return baseView
    }
    
    // MARK: - CarouselView
    
    func renderCarouselView(
        item: SBUMessageTemplate.Syntax.CarouselItem,
        parentView: UIView,
        prevView: UIView,
        prevItem: SBUMessageTemplate.Syntax.View? = nil,
        itemsAlign: SBUMessageTemplate.Syntax.ItemsAlign = .defaultAlign(),
        layout: SBUMessageTemplate.Syntax.LayoutType = .column,
        isLastItem: Bool = false
    ) -> UIView {
        let baseView = SBUMessageTemplate.Renderer.CarouselBaseView(item: item, layout: layout)
        
        let factory: SBUMessageTemplate.Syntax.Identifier.Factory? = self.rendererValueFor(key: .templateFactory) // cacheKey
        let restoreView: SBUBaseCarouselView? = self.rendererValueFor(key: .carouselRestoreView)
        let carouselView = restoreView?.cacheKey?.isEqualCacheKey(factory) == true ? restoreView! : SBUBaseCarouselView(frame: .init(x: 0, y: 0, width: 1, height: 1))
        
        if restoreView != carouselView {
            let renderers = item.items?.compactMap {
                SBUMessageTemplate.Renderer.CarouselRenderer(
                    data: $0,
                    actionHandler: self.actionHandler
                )
            } ?? []
            
            let profileArea = self.rendererValueFor(key: .carouselProfileAreaSize, defaultValue: CGFloat.zero)
            
            carouselView.configure(
                with: SBUBaseCarouselViewParams(
                    padding: .zero,
                    spacing: CGFloat(item.spacing),
                    profileArea: profileArea,
                    renderers: renderers
                )
            )
            
            carouselView.cacheKey = factory
            
            self.rendererUpdateValue(carouselView, forKey: .carouselRestoreView)
        } else {
            carouselView.setNeedsLayout()
            carouselView.layoutSubviews()
        }
        
        baseView.addSubview(carouselView)
        parentView.addSubview(baseView)
        
        // View Style
        self.renderViewStyle(with: item, to: baseView)
        
        // Layout
        self.renderViewLayout(
            with: item,
            to: baseView,
            parentView: parentView,
            prevView: prevView,
            prevItem: prevItem,
            itemsAlign: itemsAlign,
            layout: layout,
            isLastItem: isLastItem
        )
        
        // Action
        self.setAction(on: baseView, item: item)
        
        return baseView
    }
    
    // MARK: - Image
    func renderImage(
        item: SBUMessageTemplate.Syntax.Image,
        parentView: UIView,
        prevView: UIView,
        prevItem: SBUMessageTemplate.Syntax.View? = nil,
        itemsAlign: SBUMessageTemplate.Syntax.ItemsAlign = .defaultAlign(),
        layout: SBUMessageTemplate.Syntax.LayoutType = .column,
        isLastItem: Bool = false
    ) -> UIView {
        let baseView = SBUMessageTemplate.Renderer.ImageBaseView(item: item, layout: layout)
        baseView.clipsToBounds = true
        let imageView = SBUMessageTemplate.Renderer.ImageView()
        
        // INFO: Edge case - image height is wrap
        imageView.contentMode = item.imageViewContentMode(with: itemsAlign)
        imageView.needResizeImage = item.needResizeImage
        
        baseView.addSubview(imageView)
        parentView.addSubview(baseView)
        
        self.rendererConstraints += imageView.sbu_constraint_equalTo_v2(
            centerXAnchor: baseView.centerXAnchor,
            centerX: 0,
            centerYAnchor: baseView.centerYAnchor,
            centerY: 0
        )
        
        // View Style
        self.renderViewStyle(with: item, to: baseView)
        
        // Layout
        self.renderViewLayout(
            with: item,
            to: baseView,
            parentView: parentView,
            prevView: prevView,
            prevItem: prevItem,
            itemsAlign: itemsAlign,
            layout: layout,
            isLastItem: isLastItem
        )
       
        let constraints = item.imagePlaceholderConstraints(
            view: imageView,
            saveCache: true
        )
        
        constraints.forEach { $0.isActive = true }
        
        // Action
        self.setAction(on: baseView, item: item)

        // Load image
        if item.isForDownloadingTemplate {
            imageView.updateDownloadTemplate(tintColor: item.imageStyle.tintColorValue)
            return baseView
        }
        
        imageView.loadImage(
            urlString: item.imageUrl,
            subPath: SBUCacheManager.PathType.template,
            autoset: false
        ) { [weak self, weak item, weak imageView] result in
            guard let self, let item, let imageView, let image = result.image else { return }
            
            self.setImage(
                image,
                imageView: imageView,
                item: item,
                placeholderConstraints: constraints
            )
        }
        
        return baseView
    }
    
    // MARK: - ImageButton
    func renderImageButton(
        item: SBUMessageTemplate.Syntax.ImageButton,
        parentView: UIView,
        prevView: UIView,
        prevItem: SBUMessageTemplate.Syntax.View? = nil,
        itemsAlign: SBUMessageTemplate.Syntax.ItemsAlign? = .defaultAlign(),
        layout: SBUMessageTemplate.Syntax.LayoutType = .column,
        isLastItem: Bool = false
    ) -> UIView {
        let baseView = SBUMessageTemplate.Renderer.ImageButtonBaseView(item: item, layout: layout)
        baseView.clipsToBounds = true
        let imageButton = SBUMessageTemplate.Renderer.ImageButton()
        
        // Image Style
        imageButton.contentMode = item.imageStyle.contentMode
        imageButton.imageView?.contentMode = item.imageStyle.contentMode
        
        baseView.addSubview(imageButton)
        parentView.addSubview(baseView)
        
        self.rendererConstraints += imageButton.sbu_constraint_equalTo_v2(
            centerXAnchor: baseView.centerXAnchor,
            centerX: 0,
            centerYAnchor: baseView.centerYAnchor,
            centerY: 0
        )
        
        // View Style
        self.renderViewStyle(with: item, to: baseView)
        
        // Layout
        self.renderViewLayout(
            with: item,
            to: baseView,
            parentView: parentView,
            prevView: prevView,
            prevItem: prevItem,
            itemsAlign: itemsAlign,
            layout: layout,
            isLastItem: isLastItem
        )
        
        // Action
        self.setAction(on: baseView, item: item)
        
        let constraints = item.imagePlaceholderConstraints(
            view: imageButton,
            saveCache: false
        )
        
        constraints.forEach { $0.isActive = true }

        imageButton.loadImage(
            urlString: item.imageUrl,
            for: .normal,
            subPath: SBUCacheManager.PathType.template,
            completion: { [weak self, weak imageButton, weak item] _ in
                guard let self, let imageButton, let item else { return }
                
                self.setImageButton(
                    imageButton,
                    item: item,
                    placeholderConstraints: constraints
                )
            }
        )
        
        return baseView
    }
}
