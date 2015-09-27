# ChromaTouch
Introduction to 3D Touch in Swift with Peek, Pop and Preview Actions

Companion project to http://flexmonkey.blogspot.co.uk/2015/09/chromatouch-3d-touch-colour-picker-in.html

If you're fairly new to Swift, you may have found my last post on 3D Touch a little daunting. Here's a much smaller project that may be a little easier to follow to get up and running with force, peek, pop and preview actions. 

ChromaTouch is a HSL based colour picker where the user can set the colour with three horizontal sliders or by touching over a colour swatch where horizontal movement sets hue, vertical set saturation and the force of the touch sets the lightness of the colour. As the user moves their finger over the swatch, the sliders update to reflect the new HSL values.

By force touching the sliders, the user is presented with a small preview displaying the RGB hex value of their colour:

By swiping up they can set their colour to one of three presets:.

And by deep pressing, they're presented with a full screen preview of their colour which is dismissed with a tap.

Let's look at each part of the 3D Touch code to see how everything has been implemented.

##Setting Lightness with Force 

My Swatch class is responsible for handling the user's touches in three dimensions and populating a tuple containing the three values for hue, saturation and lightness. Each touch returned in touchesMoved() contains two dimensional spatial data in its touchLocation property and the amount of force the user is exerting in its force property. 

We can normalise these values to between zero and one by dividing the positions by the bounds of the Swatch's view and the force by the maximumPossibleForce. With those normalised values, we can construct an object representing the three properties of our desired colour:

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesMoved(touches, withEvent: event)

        guard let touch = touches.first else
        {
            return
        }
        
        let touchLocation = touch.locationInView(self)
        let force = touch.force
        let maximumPossibleForce = touch.maximumPossibleForce

        let normalisedXPosition = touchLocation.x / frame.width
        let normalisedYPosition = touchLocation.y / frame.height
        let normalisedZPosition = force / maximumPossibleForce
        
        hsl = HSL(hue: normalisedXPosition,
            saturation: normalisedYPosition,
            lightness: normalisedZPosition)
    }

If you look at my code, you'll notice I keep a variable holding the previous touch force and compare it against the current touch force. This allows me to ignore large differences which happen when the user lifts their finger to end the gesture.

##Peeking

Peeking happens when the user presses down on the sliders. In my main view controller, as I create each of the three sliders, I register them for previewing with that main view controller:

    for sliderWidget in [hueSlider, saturationSlider, lightnessSlider]
    {
        progressBarsStackView.addArrangedSubview(sliderWidget)
        sliderWidget.addTarget(self, action: "sliderChangeHandler", forControlEvents: UIControlEvents.ValueChanged)
        
        registerForPreviewingWithDelegate(self, sourceView: sliderWidget)
    }

My view controller needs to implement UIViewControllerPreviewingDelegate in order to tell iOS what to pop up when the user wishes to preview. In the case of ChromaTouch, it's a PeekViewController and it's defined in previewingContext(viewControllerForLocation):

    func previewingContext(previewingContext: UIViewControllerPreviewing,
        viewControllerForLocation location: CGPoint) -> UIViewController?
    {
        let peek = PeekViewController(hsl: hsl,
            delegate: previewingContext.delegate)
        
        return peek
    }

PeekViewController is pretty basic, containing a UILabel that has its text set based on an extension I wrote to extract the RGB components from a UIColor.
Preview Actions

By swiping up on the preview, the user can set their colour to a preset. This is super simple to implement: all my PeekViewController needs to do is return an array of UIPreviewActionItem which I create based on an array of predefined colour enumerations:

    var previewActions: [UIPreviewActionItem]
    {
        return [ColorPresets.Red, ColorPresets.Green, ColorPresets.Blue].map
        {
            UIPreviewAction(title: $0.rawValue,
                style: UIPreviewActionStyle.Default,
                handler:
                {
                    (previewAction, viewController) in
                    (viewController as? PeekViewController)?.updateColor(previewAction)
                })
        }
    }

Because I passed the main view controller in the constructor of PeekViewController as delegate, the updateColor() method in the PeekViewController can pass a newly constructed HSL tuple to it based on the colour selected as a preview action:

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

##Popping

The final step is popping: when the user presses deeply on the preview, the preview will vanish (this is managed by the framework) and the main view controller is shown again. However, here I want to hide the sliders and make the swatch full screen. Once the user taps, I want the screen to return to its default state.

Popping requires the second method from UIViewControllerPreviewingDelegate, previewingContext(commitViewController). Here, I simply turn off user interaction on the swatch and hide the stack view containing the three sliders:

    func previewingContext(previewingContext: UIViewControllerPreviewing,
        commitViewController viewControllerToCommit: UIViewController)
    {
        swatch.userInteractionEnabled = false
        progressBarsStackView.hidden = true
    }

To respond to the tap to return the user interface back to default, ChromaTouchViewController reenables user interaction on the swatch and unhides the progress bars:

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesBegan(touches, withEvent: event)
        
        swatch.userInteractionEnabled = true
  
        UIView.animateWithDuration(0.25){ self.progressBarsStackView.hidden = false }
    }

##Conclusion

I'm beginning to really love peek and pop in the day-to-day iOS apps. As I mentioned in my previous post and as hopefully demonstrated here, it's super easy to implement.

All the code for this project is available in my GitHub repository here. Enjoy!
