//
//  SwiftUICustomView.swift
//  MagicCamera
//
//  Created by William on 2021/3/26.
//

import UIKit
import SwiftUI

struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
 
        return HStack {
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(configuration.isOn ? .purple : .gray)
                .font(.system(size: 20, weight: .bold, design: .default))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
 
    }
}

class SlideAnimatedTransitioning: NSObject {

}

extension SlideAnimatedTransitioning: UIViewControllerAnimatedTransitioning {

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!.view
        let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!.view
        
        let width = containerView.frame.width
        
        var offsetLeft = fromView?.frame
        offsetLeft?.origin.x = width
        
        var offscreenRight = toView?.frame
        offscreenRight?.origin.x = -width / 3.33;
        
        toView?.frame = offscreenRight!;
        
        fromView?.layer.shadowRadius = 5.0
        fromView?.layer.shadowOpacity = 1.0
        toView?.layer.opacity = 0.9
        
        containerView.insertSubview(toView!, belowSubview: fromView!)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay:0, options:.curveLinear, animations:{
            
            toView?.frame = (fromView?.frame)!
            fromView?.frame = offsetLeft!
            
            toView?.layer.opacity = 1.0
            fromView?.layer.shadowOpacity = 0.1
            
            }, completion: { finished in
                toView?.layer.opacity = 1.0
                toView?.layer.shadowOpacity = 0
                fromView?.layer.opacity = 1.0
                fromView?.layer.shadowOpacity = 0
                
                // when cancelling or completing the animation, ios simulator seems to sometimes flash black backgrounds during the animation. on devices, this doesn't seem to happen though.
                // containerView.backgroundColor = [UIColor whiteColor];
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.3
    }

}

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class SwipeRightToPopViewController<Content>: UIHostingController<Content>, UINavigationControllerDelegate where Content : View {

    fileprivate var lazyPopContent: LazyPop<Content>?
    private var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition?
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var parentNavigationControllerToUse: UINavigationController?
    private var gestureAdded = false
    
    override func viewDidLayoutSubviews() {
        // You need to add gesture events after every subview layout to protect against weird edge cases
        //    One notable edgecase is if you are in a splitview in landscape. In this case, there will be
        //    no nav controller with 2 vcs, so our addGesture will fail. After rotating back to portrait,
        //    the splitview will combine into one view with the details pushed on top. So only then would
        //    would the addGesture find a parent nav controller with 2 view controllers. I don't know if
        //    there are other edge cases, but running addGesture on every viewDidLayoutSubviews seems safe.
        addGesture()
    }

    public func addGesture() {
        if !gestureAdded {
            // attempt to find a parent navigationController
            var currentVc: UIViewController = self
            while true {
                if (currentVc.navigationController != nil) &&
                   currentVc.navigationController?.viewControllers.count > 1
                    {
                    parentNavigationControllerToUse = currentVc.navigationController
                    break
                }
                guard let parent = currentVc.parent else {
                    return
                }
                currentVc = parent
            }
            guard parentNavigationControllerToUse?.viewControllers.count > 1 else {
                return
            }
            
            panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SwipeRightToPopViewController.handlePanGesture(_:)))
            self.view.addGestureRecognizer(panGestureRecognizer)
            gestureAdded = true
        }
    }

    @objc func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        
        // if the parentNavigationControllerToUse has a width value, use that because it's more accurate. Otherwise use this view's width as a backup
        let total = parentNavigationControllerToUse?.view.frame.width ?? view.frame.width
        let percent = max(panGesture.translation(in: view).x, 0) / total

        switch panGesture.state {

        case .began:
            if lazyPopContent?.isEnabled == true {
                parentNavigationControllerToUse?.delegate = self
                _ = parentNavigationControllerToUse?.popViewController(animated: true)
            }

        case .changed:
            if let percentDrivenInteractiveTransition = percentDrivenInteractiveTransition {
                percentDrivenInteractiveTransition.update(percent)
            }

        case .ended:
            let velocity = panGesture.velocity(in: view).x

            // Continue if drag more than 50% of screen width or velocity is higher than 100
            if percent > 0.5 || velocity > 100 {
                percentDrivenInteractiveTransition?.finish()
            } else {
                percentDrivenInteractiveTransition?.cancel()
            }

        case .cancelled, .failed:
            percentDrivenInteractiveTransition?.cancel()

        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return SlideAnimatedTransitioning()
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        parentNavigationControllerToUse?.delegate = nil
        navigationController.delegate = nil

        if panGestureRecognizer.state == .began {
            percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
            percentDrivenInteractiveTransition?.completionCurve = .easeOut
        } else {
            percentDrivenInteractiveTransition = nil
        }

        return percentDrivenInteractiveTransition
    }
}


//
//  Lazy Pop SwiftUI Component
//
//  Created by Joseph Hinkle on 12/1/19.
//  Copyright © 2019 Joseph Hinkle. All rights reserved.
//
fileprivate struct LazyPop<Content: View>: UIViewControllerRepresentable {
    let rootView: Content
    @Binding var isEnabled: Bool
    
    init(_ rootView: Content, isEnabled: (Binding<Bool>)? = nil) {
        self.rootView = rootView
        self._isEnabled = isEnabled ?? Binding<Bool>(get: { return true }, set: { _ in })
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = SwipeRightToPopViewController(rootView: rootView)
        vc.lazyPopContent = self
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let host = uiViewController as? UIHostingController<Content> {
            host.rootView = rootView
        }
    }
}
extension View {
    public func lazyPop(isEnabled: (Binding<Bool>)? = nil) -> some View {
        return LazyPop(self, isEnabled: isEnabled)
    }
}
