#if canImport(AppKit) && canImport(AuthenticationServices)
import AppKit
import AuthenticationServices
import Foundation

final class CredentialProviderViewController: ASCredentialProviderViewController {
    private enum DemoSpectreConfiguration {
        static let userName = "Robert Lee Mitchell"
        static let userSecret = "banana colored duckling"
        static let fallbackSite = "twitter.com"
        static let fallbackUser = "demo@example.com"
    }

    private var pendingUser = DemoSpectreConfiguration.fallbackUser
    private var pendingServiceIdentifier = DemoSpectreConfiguration.fallbackSite

    private lazy var statusLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Select Continue to return a Spectre-derived demo credential.")
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
            ? "Select Continue to return the bundled Spectre-derived credential."
            : "Select Continue to return a Spectre-derived credential for: \(summary)"
    }

    override func provideCredentialWithoutUserInteraction(for credentialRequest: any ASCredentialRequest) {
        pendingUser = credentialRequest.credentialIdentity.user.isEmpty
            ? DemoSpectreConfiguration.fallbackUser
            : credentialRequest.credentialIdentity.user
        pendingServiceIdentifier = normalizedSiteName(from: credentialRequest.credentialIdentity.serviceIdentifier.identifier)

        do {
            let credential = try makeDemoCredential()
            extensionContext.completeRequest(withSelectedCredential: credential, completionHandler: nil)
        } catch {
            extensionContext.cancelRequest(withError: error)
        }
    }

    override func prepareInterfaceToProvideCredential(for credentialRequest: any ASCredentialRequest) {
        let identifier = credentialRequest.credentialIdentity.serviceIdentifier.identifier
        pendingUser = credentialRequest.credentialIdentity.user.isEmpty
            ? DemoSpectreConfiguration.fallbackUser
            : credentialRequest.credentialIdentity.user
        pendingServiceIdentifier = normalizedSiteName(from: identifier)
        statusLabel.stringValue = identifier.isEmpty
            ? "Select Continue to finish providing the Spectre-derived credential."
            : "Select Continue to provide a Spectre-derived credential for: \(identifier)"
    }

    override func prepareInterfaceForExtensionConfiguration() {
        extensionContext.completeExtensionConfigurationRequest()
    }

    @objc
    private func completeWithDemoCredential() {
        do {
            let credential = try makeDemoCredential()
            extensionContext.completeRequest(withSelectedCredential: credential, completionHandler: nil)
        } catch {
            extensionContext.cancelRequest(withError: error)
        }
    }

    private func makeDemoCredential() throws -> ASPasswordCredential {
        let password = try SpectreAlgorithm.password(
            for: SpectreConfiguration(
                userName: DemoSpectreConfiguration.userName,
                userSecret: DemoSpectreConfiguration.userSecret,
                siteName: pendingServiceIdentifier,
                resultType: .long
            )
        )

        return ASPasswordCredential(user: pendingUser, password: password)
    }

    private func normalizedSiteName(from identifier: String) -> String {
        if let host = URL(string: identifier)?.host, !host.isEmpty {
            return host
        }

        return identifier.isEmpty ? DemoSpectreConfiguration.fallbackSite : identifier
    }
}
#endif
