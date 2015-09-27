//
//  ViewController.swift
//  ChromaTouch
//
//  Created by SIMON_NON_ADMIN on 27/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

typealias HSL = (hue: CGFloat, saturation: CGFloat, lightness: CGFloat)

class ChromaTouchViewController: UIViewController
{
    let mainStackView = UIStackView()
    let progressBarsStackView = UIStackView()

    let hueSlider = SliderWidget(title: "Hue")
    let saturationSlider = SliderWidget(title: "Saturation")
    let lightnessSlider = SliderWidget(title: "Brightness")
    
    var swatch: Swatch!
    
    var hsl:HSL = (hue: 0.5, saturation: 1, lightness: 0.75)
    {
        didSet
        {
            updateUI()
        }
    }
    
    override func viewDidLoad()
    {
        if traitCollection.forceTouchCapability != UIForceTouchCapability.Available
        {
            fatalError("ChromaTouch requires a 3D Touch enabled device")
        }
        
        super.viewDidLoad()
      
        swatch = Swatch(hsl: hsl)
        
        swatch.addTarget(self, action: "swatchChangeHander", forControlEvents: UIControlEvents.ValueChanged)
        
        progressBarsStackView.axis = UILayoutConstraintAxis.Vertical
        progressBarsStackView.distribution = UIStackViewDistribution.FillEqually
        
        for sliderWidget in [hueSlider, saturationSlider, lightnessSlider]
        {
            progressBarsStackView.addArrangedSubview(sliderWidget)
            sliderWidget.addTarget(self, action: "sliderChangeHandler", forControlEvents: UIControlEvents.ValueChanged)
            
            registerForPreviewingWithDelegate(self, sourceView: sliderWidget)
        }

        mainStackView.addArrangedSubview(swatch)
        mainStackView.addArrangedSubview(progressBarsStackView)

        view.addSubview(mainStackView)
        
        updateUI()
    }

    func sliderChangeHandler()
    {
        hsl = HSL(hue: hueSlider.value,
            saturation: saturationSlider.value,
            lightness: lightnessSlider.value)
    }
    
    func swatchChangeHander()
    {
        hsl = swatch.hsl
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesBegan(touches, withEvent: event)
        
        swatch.userInteractionEnabled = true
  
        UIView.animateWithDuration(0.25){ self.progressBarsStackView.hidden = false }
    }
    
    func updateUI()
    {
        swatch.hsl = hsl
        
        hueSlider.value = hsl.hue
        saturationSlider.value = hsl.saturation
        lightnessSlider.value = hsl.lightness
    }
    
    override func viewDidLayoutSubviews()
    {
        mainStackView.frame = CGRect(x: 0,
            y: topLayoutGuide.length,
            width: view.frame.width,
            height: view.frame.height - topLayoutGuide.length)
        
        
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
        {
            mainStackView.axis = UILayoutConstraintAxis.Horizontal
        }
        else
        {
            mainStackView.axis = UILayoutConstraintAxis.Vertical
        }
    }
}

extension ChromaTouchViewController: UIViewControllerPreviewingDelegate
{
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController?
    {
        let peek = PeekViewController(hsl: hsl,
            delegate: previewingContext.delegate)
        
        return peek
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController)
    {
        swatch.userInteractionEnabled = false
        progressBarsStackView.hidden = true
    }
}




