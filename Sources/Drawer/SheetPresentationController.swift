
import UIKit

public class SheetPresentationController: UIViewController {

    var primaryViewController: UIViewController! {
        didSet {
            addChild(primaryViewController)
            view.addSubview(primaryViewController.view)
            primaryViewController.didMove(toParent: self)
            self.view.setNeedsLayout()
        }
    }

    var secondaryViewController: SecondaryViewController! {
        didSet {
            addChild(secondaryViewController)
            secondaryViewController.delegate = self
            view.addSubview(secondaryViewController.view)
            secondaryViewController.didMove(toParent: self)
            self.view.setNeedsLayout()
        }
    }


    public init(primaryViewController: UIViewController, secondaryViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        secondaryViewController.view.frame = CGRect(x: 0, y: view.bounds.maxY, width: view.bounds.width, height: -view.bounds.height / 2)
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}


extension SheetPresentationController: SecondaryViewControllerDelegate {
    func didUpdateHeight(_ viewController: UIViewController, height: CGFloat) {
        secondaryViewController.view.frame = CGRect(x: 0, y: view.bounds.maxY, width: view.bounds.width, height: -height)
    }
}
