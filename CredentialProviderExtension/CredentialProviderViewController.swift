#if canImport(AppKit) && canImport(AuthenticationServices)
import AppKit
import AuthenticationServices

final class CredentialProviderViewController: ASCredentialProviderViewController {
    private let demoCredential = ASPasswordCredential(user: "demo@example.com", password: "demo-password")

    private lazy var statusLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Select Continue to return a demo credential.")
        label.lineBreakMode = .byWordWrapping
        label.maximumNumberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var continueButton: NSButton = {
        let button = NSButton(title: "Continue", target: self, action: #selector(completeWithDemoCredential))
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func loadView() {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            continueButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            continueButton.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            continueButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -24)
        ])

        self.view = view
        preferredContentSize = NSSize(width: 420, height: 180)
    }

    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        let summary = serviceIdentifiers.map(\.identifier).joined(separator: ", ")
        statusLabel.stringValue = summary.isEmpty
            ? "Select Continue to return the bundled demo credential."
            : "Select Continue to return a demo credential for: \(summary)"
    }

    override func provideCredentialWithoutUserInteraction(for credentialRequest: any ASCredentialRequest) {
        let requestedUser = credentialRequest.credentialIdentity.user
        let credential = requestedUser.isEmpty
            ? demoCredential
            : ASPasswordCredential(user: requestedUser, password: demoCredential.password)

        extensionContext.completeRequest(withSelectedCredential: credential, completionHandler: nil)
    }

    override func prepareInterfaceToProvideCredential(for credentialRequest: any ASCredentialRequest) {
        let identifier = credentialRequest.credentialIdentity.serviceIdentifier.identifier
        statusLabel.stringValue = identifier.isEmpty
            ? "Select Continue to finish providing the demo credential."
            : "Select Continue to provide a demo credential for: \(identifier)"
    }

    override func prepareInterfaceForExtensionConfiguration() {
        extensionContext.completeExtensionConfigurationRequest()
    }

    @objc
    private func completeWithDemoCredential() {
        extensionContext.completeRequest(withSelectedCredential: demoCredential, completionHandler: nil)
    }
}
#endif
