//
//  PeekViewController.swift
//  ChromaTouch
//
//  Created by SIMON_NON_ADMIN on 27/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class PeekViewController: UIViewController
{
    let label = UILabel()
    let smallSwatch = UIView()
    
    let hsl: HSL
    unowned let delegate: UIViewControllerPreviewingDelegate
    
    required init(hsl: HSL, delegate: UIViewControllerPreviewingDelegate)
    {
        self.hsl = hsl
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
        
        let color = UIColor(hue: hsl.hue,
            saturation: hsl.saturation,
            brightness: hsl.lightness,
            alpha: 1)
    
        label.text = "Your color: \(color.getHex())"
        label.textAlignment = NSTextAlignment.Center

        smallSwatch.backgroundColor = color
    }

    var previewActions: [UIPreviewActionItem]
    {
        return [ColorPresets.Red, ColorPresets.Green, ColorPresets.Blue].map
        {
            UIPreviewAction(title: $0.rawValue,
                style: UIPreviewActionStyle.Default,
                handler:
                {
                    (previewAction, viewController) in (viewController as? PeekViewController)?.updateColor(previewAction)
            })
        }
    }
    
    func updateColor(previewAction: UIPreviewActionItem)
    {
        guard let delegate = delegate as? ChromaTouchViewController,
            preset = ColorPresets(rawValue: previewAction.title) else
            
        {
            return
        }
        
        let hue: CGFloat
        
        switch preset
        {
        case .Blue:
            hue = 0.667
        case .Green:
            hue = 0.333
        case .Red:
            hue = 0
        }
        
        delegate.hsl = HSL(hue: hue, saturation: 1, lightness: 1)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        view.backgroundColor = UIColor.lightGrayColor()

        view.addSubview(smallSwatch)
        smallSwatch.frame = CGRect(x: 10,
            y: 10, width: view.frame.width - 20,
            height: 20)
        
        view.addSubview(label)
        label.frame = CGRect(origin: CGPointZero, size: view.frame.size)
    }
}

enum ColorPresets: String
{
    case Red, Green, Blue
}
