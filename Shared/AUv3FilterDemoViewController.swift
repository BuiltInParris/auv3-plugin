/*
See LICENSE folder for this sample’s licensing information.

Abstract:
View controller for the AUv3FilterDemo audio unit. Manages the interactions between a FilterView and the audio unit's parameters.
*/

import CoreAudioKit

public class AUv3FilterDemoViewController: AUViewController {

    let compact = AUAudioUnitViewConfiguration(width: 400, height: 100, hostHasController: false)
    let expanded = AUAudioUnitViewConfiguration(width: 800, height: 500, hostHasController: false)

    private var viewConfig: AUAudioUnitViewConfiguration!
    
    var observer: NSKeyValueObservation?

    var needsConnection = true

    @IBOutlet var expandedView: View! {
        didSet {
            expandedView.setBorder(color: .black, width: 1)
        }
    }

    @IBOutlet var compactView: View! {
        didSet {
            compactView.setBorder(color: .black, width: 1)
        }
    }

    public var viewConfigurations: [AUAudioUnitViewConfiguration] {
        // width: 0 height:0  is always supported, should be the default, largest view.
        return [expanded, compact]
    }

    /*
     When this view controller is instantiated within the FilterDemoApp, its
     audio unit is created independently, and passed to the view controller here.
     */
    public var audioUnit: AUv3FilterDemo? {
        didSet {
            audioUnit?.viewController = self
            /*
             We may be on a dispatch worker queue processing an XPC request at
             this time, and quite possibly the main queue is busy creating the
             view. To be thread-safe, dispatch onto the main queue.

             It's also possible that we are already on the main queue, so to
             protect against deadlock in that case, dispatch asynchronously.
             */
            performOnMain {
                if self.isViewLoaded {
                    self.connectViewToAU()
                }
            }
        }
    }

    #if os(macOS)
    public override init(nibName: NSNib.Name?, bundle: Bundle?) {
        // Pass a reference to the owning framework bundle
        super.init(nibName: nibName, bundle: Bundle(for: type(of: self)))
    }
    #endif

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(expandedView)
        expandedView.pinToSuperviewEdges()

        // Set the default view configuration.
        viewConfig = expanded

        #if os(iOS)
        frequencyTextField.delegate = self
        resonanceTextField.delegate = self
        #endif

        guard audioUnit != nil else { return }

        // Connect the user interface to the AU parameters, if needed.
        connectViewToAU()
    }

    private func connectViewToAU() {
        // Indicate the view and AU are connected
        needsConnection = false
        
    }

    func update(parameter: AUParameter, with textField: TextField) {
        guard let value = (textField.text as NSString?)?.floatValue else { return }
        parameter.value = value
        textField.text = parameter.string(fromValue: nil)
    }

    // MARK: View Configuration Selection

    public func toggleViewConfiguration() {
        // Let the audio unit call selectViewConfiguration instead of calling
        // it directly to ensure validate the audio unit's behavior.
        audioUnit?.select(viewConfig == expanded ? compact : expanded)
    }

    func selectViewConfiguration(_ viewConfig: AUAudioUnitViewConfiguration) {
        // If requested configuration is already active, do nothing
        guard self.viewConfig != viewConfig else { return }

        self.viewConfig = viewConfig

        let isDefault = viewConfig.width >= expanded.width &&
                        viewConfig.height >= expanded.height
        let fromView = isDefault ? compactView : expandedView
        let toView = isDefault ? expandedView : compactView

        performOnMain {
            #if os(iOS)
            UIView.transition(from: fromView!,
                              to: toView!,
                              duration: 0.2,
                              options: [.transitionCrossDissolve, .layoutSubviews])

            if toView == self.expandedView {
                toView?.pinToSuperviewEdges()
            }

            #elseif os(macOS)
            self.view.addSubview(toView!)
            fromView!.removeFromSuperview()
            toView!.pinToSuperviewEdges()
            #endif
        }
    }

    func performOnMain(_ operation: @escaping () -> Void) {
        if Thread.isMainThread {
            operation()
        } else {
            DispatchQueue.main.async {
                operation()
            }
        }
    }
}

#if os(iOS)
extension AUv3FilterDemoViewController: UITextFieldDelegate {
    // MARK: UITextFieldDelegate
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}
#endif
