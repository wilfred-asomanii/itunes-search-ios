//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Wilfred Asomani on 16/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var artImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    private var imageTask: URLSessionDataTask?

    var searchResult: SearchResult!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBlur()
        setupDetailsDisplay()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        transitioningDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.5, delay: 0,
                       usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [],
                       animations: {
                        self.popUpView.isHidden = false
                        self.popUpView.alpha = 1
                        self.popUpView.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    func setupBlur() {
        view.backgroundColor = .clear
        var effect = UIBlurEffect(style: .regular)
        if #available(iOS 13, *) {
            effect = UIBlurEffect(style: .systemUltraThinMaterial)
        }
        blurEffectView.effect = effect

        popUpView.isHidden = true
        popUpView.alpha = 0
        popUpView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
    }

    func setupDetailsDisplay() {
        imageTask = artImageView.setImage(fromURL: searchResult.imageLarge)
        nameLabel.text = searchResult.name
        artistNameLabel.text = searchResult.artistName
        kindLabel.text = searchResult.type
        genreLabel.text = searchResult.genre
        priceLabel.text = String.format(price: searchResult.price, currency: searchResult.currency)
    }

    @objc func close(_ sender: Any) {
        imageTask?.cancel()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func openInStore(_ sender: Any) {
        let url = URL(string: searchResult.storeURL)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == popUpView
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
}

class BounceAnimationController: NSObject,
UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let _ = transitionContext.viewController( forKey: UITransitionContextViewControllerKey.to),
            let from = transitionContext.view(
                forKey: UITransitionContextViewKey.from) {
            UIView.animate(withDuration: 0.5, delay: 0,
                           usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [],
                           animations: {
                            from.alpha = 0
                            from.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                            from.isOpaque = true
            }, completion: { finished in
                transitionContext.completeTransition(finished)
            })

        }
    }
}
