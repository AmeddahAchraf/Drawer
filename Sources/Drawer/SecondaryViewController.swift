
import UIKit

protocol SecondaryViewControllerDelegate: AnyObject {
    func didUpdateHeight(_ viewController: UIViewController, height: CGFloat)
}

class SecondaryViewController: UIViewController {

    weak var delegate: SecondaryViewControllerDelegate?

    private let maxDimmedAlpha: CGFloat = 0.6
    private var defaultHeight: CGFloat = 400
    private var minimumHeight: CGFloat = 140
    private let dismissibleHeight: CGFloat = 250
    private let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    private var currentContainerHeight: CGFloat = 400

    // Dynamic container constraint
    private var containerViewHeightConstraint: NSLayoutConstraint?
    private var containerViewBottomConstraint: NSLayoutConstraint?

    private var contentView = UIView()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConstraints()
        setupPanGesture()
    }

    func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        view.addGestureRecognizer(panGesture)
    }

    public init(contentView: UIView, defaultHeight: CGFloat = 400) {
        super.init(nibName: nil, bundle: nil)
        self.contentView = contentView
        self.defaultHeight = defaultHeight
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentContainer()
    }

    func setupView() {
        view.backgroundColor = .blue
        containerView.backgroundColor = .red
    }

    func setupConstraints() {
        view.addSubview(containerView)
        containerView.addSubview(contentView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
        ])

        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)

        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }



}


// MARK: Pan gesture handler
extension SecondaryViewController {
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let isDraggingDown = translation.y > 0
        let newHeight = currentContainerHeight - translation.y

        switch gesture.state {
        case .changed:
            if newHeight < maximumContainerHeight {
                containerViewHeightConstraint?.constant = newHeight
                view.layoutIfNeeded()
            }
        case .ended:
            // Condition 1: If new height is below min, dismiss controller
            if newHeight < dismissibleHeight {
                animateContainerHeight(minimumHeight)
                delegate?.didUpdateHeight(self, height: minimumHeight)
            }
            else if newHeight < defaultHeight {
                // Condition 2: If new height is below default, animate back to default
                animateContainerHeight(defaultHeight)
                delegate?.didUpdateHeight(self, height: defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                // Condition 3: If new height is below max and going down, set to default height
                animateContainerHeight(defaultHeight)
                delegate?.didUpdateHeight(self, height: defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                // Condition 4: If new height is below max and going up, set to max height at top
                animateContainerHeight(maximumContainerHeight)
                delegate?.didUpdateHeight(self, height: maximumContainerHeight)
            }
        default:
            break
        }

    }
}

// MARK: Animation handlers
extension SecondaryViewController {
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            // Update container height
            self.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }

    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
}
