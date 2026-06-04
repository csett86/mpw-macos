#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
import AuthenticationServices
import Foundation

final class CredentialProviderViewController: ASCredentialProviderViewController {
    private enum ProviderError: Swift.Error, LocalizedError {
        case missingUserName
        case missingUserSecret
        case missingSite
        case missingLoginName

        var errorDescription: String? {
            switch self {
            case .missingUserName:
                return "Enter a user name before continuing."
            case .missingUserSecret:
                return "Enter a user secret before continuing."
            case .missingSite:
                return "No requesting site was provided by the extension context."
            case .missingLoginName:
                return "Enter a login name before continuing."
            }
        }
    }

    private var pendingServiceIdentifier: String?

    #if canImport(AppKit)
    private lazy var statusLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Enter your Spectre user name and secret, then select Continue.")
        label.lineBreakMode = .byWordWrapping
        label.maximumNumberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var siteLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Site")
        label.font = .systemFont(ofSize: NSFont.systemFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var siteField: NSTextField = {
        let field = NSTextField(string: "")
        field.placeholderString = "example.com"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private lazy var userNameLabel: NSTextField = {
        let label = NSTextField(labelWithString: "User name")
        label.font = .systemFont(ofSize: NSFont.systemFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var userNameField: NSTextField = {
        let field = NSTextField(string: "")
        field.placeholderString = "Your Full Name"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private lazy var userSecretLabel: NSTextField = {
        let label = NSTextField(labelWithString: "User Master Password")
        label.font = .systemFont(ofSize: NSFont.systemFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var userSecretField: NSSecureTextField = {
        let field = NSSecureTextField(string: "")
        field.placeholderString = "Required"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private lazy var loginNameLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Login name")
        label.font = .systemFont(ofSize: NSFont.systemFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var loginNameField: NSTextField = {
        let field = NSTextField(string: "")
        field.placeholderString = "name@example.com"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private lazy var continueButton: NSButton = {
        let button = NSButton(title: "Continue", target: self, action: #selector(completeWithCredential))
        button.bezelStyle = .rounded
        button.keyEquivalent = "\r"
        button.keyEquivalentModifierMask = []
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var cancelButton: NSButton = {
        let button = NSButton(title: "Cancel", target: self, action: #selector(cancelCredentialRequest))
        button.bezelStyle = .rounded
        button.keyEquivalent = "\u{1b}"
        button.keyEquivalentModifierMask = []
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    #elseif canImport(UIKit)
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your Spectre user name and secret, then select Continue."
        label.numberOfLines = 0
        return label
    }()

    private lazy var siteField: UITextField = {
        let field = UITextField()
        field.placeholder = "example.com"
        field.borderStyle = .roundedRect
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        return field
    }()

    private lazy var userNameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Your Full Name"
        field.borderStyle = .roundedRect
        field.autocorrectionType = .no
        return field
    }()

    private lazy var userSecretField: UITextField = {
        let field = UITextField()
        field.placeholder = "Required"
        field.borderStyle = .roundedRect
        field.isSecureTextEntry = true
        return field
    }()

    private lazy var loginNameField: UITextField = {
        let field = UITextField()
        field.placeholder = "name@example.com"
        field.borderStyle = .roundedRect
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.keyboardType = .emailAddress
        return field
    }()

    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.addTarget(self, action: #selector(completeWithCredential), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelCredentialRequest), for: .touchUpInside)
        return button
    }()
    #endif

    override func loadView() {
        #if canImport(AppKit)
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        view.addSubview(siteLabel)
        view.addSubview(siteField)
        view.addSubview(userNameLabel)
        view.addSubview(userNameField)
        view.addSubview(userSecretLabel)
        view.addSubview(userSecretField)
        view.addSubview(loginNameLabel)
        view.addSubview(loginNameField)
        view.addSubview(cancelButton)
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            siteLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            siteLabel.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            siteField.firstBaselineAnchor.constraint(equalTo: siteLabel.firstBaselineAnchor),
            siteField.leadingAnchor.constraint(equalTo: siteLabel.trailingAnchor, constant: 8),
            siteField.trailingAnchor.constraint(equalTo: statusLabel.trailingAnchor),
            userNameLabel.topAnchor.constraint(equalTo: siteLabel.bottomAnchor, constant: 14),
            userNameLabel.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            userNameField.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 6),
            userNameField.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            userNameField.trailingAnchor.constraint(equalTo: statusLabel.trailingAnchor),
            userSecretLabel.topAnchor.constraint(equalTo: userNameField.bottomAnchor, constant: 12),
            userSecretLabel.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            userSecretField.topAnchor.constraint(equalTo: userSecretLabel.bottomAnchor, constant: 6),
            userSecretField.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            userSecretField.trailingAnchor.constraint(equalTo: statusLabel.trailingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: userSecretField.bottomAnchor, constant: 12),
            loginNameLabel.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            loginNameField.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 6),
            loginNameField.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            loginNameField.trailingAnchor.constraint(equalTo: statusLabel.trailingAnchor),
            cancelButton.topAnchor.constraint(equalTo: loginNameField.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            continueButton.topAnchor.constraint(equalTo: loginNameField.bottomAnchor, constant: 16),
            continueButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            continueButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -24)
        ])

        self.view = view
        preferredContentSize = NSSize(width: 440, height: 360)
        #elseif canImport(UIKit)
        let view = UIView()
        view.backgroundColor = .systemBackground

        let stack = UIStackView(arrangedSubviews: [
            statusLabel,
            labeledFieldStack(title: "Site", field: siteField),
            labeledFieldStack(title: "User name", field: userNameField),
            labeledFieldStack(title: "User Master Password", field: userSecretField),
            labeledFieldStack(title: "Login name", field: loginNameField),
            buttonRow()
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        self.view = view
        #endif
    }

    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        pendingServiceIdentifier = serviceIdentifiers
            .lazy
            .compactMap { self.normalizedSiteName(from: $0.identifier) }
            .first
        updateSiteUI()

        setStatusText("Enter your Spectre details to generate a credential for: \(pendingServiceIdentifier ?? "N/A")")
    }

    override func provideCredentialWithoutUserInteraction(for credentialRequest: any ASCredentialRequest) {
        // Prompting for the master password parameters requires rendering the extension UI.
        let error = NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userInteractionRequired.rawValue)
        extensionContext.cancelRequest(withError: error)
    }

    override func prepareInterfaceToProvideCredential(for credentialRequest: any ASCredentialRequest) {
        pendingServiceIdentifier = normalizedSiteName(from: credentialRequest.credentialIdentity.serviceIdentifier.identifier)
        updateSiteUI()
    }

    override func prepareInterfaceForExtensionConfiguration() {
        extensionContext.completeExtensionConfigurationRequest()
    }

    #if canImport(AppKit)
    override func cancelOperation(_ sender: Any?) {
        cancelCredentialRequest()
    }
    #endif

    @objc
    private func completeWithCredential() {
        do {
            let credential = try makeCredential()
            extensionContext.completeRequest(withSelectedCredential: credential, completionHandler: nil)
        } catch {
            extensionContext.cancelRequest(withError: error)
        }
    }

    @objc
    private func cancelCredentialRequest() {
        let error = NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue)
        extensionContext.cancelRequest(withError: error)
    }

    private func makeCredential() throws -> ASPasswordCredential {
        let userName = userNameValue
        guard !userName.isEmpty else {
            throw ProviderError.missingUserName
        }

        let userSecret = userSecretValue
        guard !userSecret.isEmpty else {
            throw ProviderError.missingUserSecret
        }

        let siteName = siteValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !siteName.isEmpty else {
            throw ProviderError.missingSite
        }

        let loginName = loginNameValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !loginName.isEmpty else {
            throw ProviderError.missingLoginName
        }

        let password = try SpectreAlgorithm.password(
            for: SpectreConfiguration(
                userName: userName,
                userSecret: userSecret,
                siteName: siteName,
                resultType: .long
            )
        )

        return ASPasswordCredential(user: loginName, password: password)
    }

    private func normalizedSiteName(from identifier: String) -> String? {
        let trimmed = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }

        if let host = URL(string: identifier)?.host, !host.isEmpty {
            return host
        }

        return trimmed
    }

    private func updateSiteUI() {
        #if canImport(AppKit)
        siteField.stringValue = pendingServiceIdentifier ?? ""
        #elseif canImport(UIKit)
        siteField.text = pendingServiceIdentifier ?? ""
        #endif
    }

    private func setStatusText(_ text: String) {
        #if canImport(AppKit)
        statusLabel.stringValue = text
        #elseif canImport(UIKit)
        statusLabel.text = text
        #endif
    }

    #if canImport(AppKit)
    private var userNameValue: String { userNameField.stringValue }
    private var userSecretValue: String { userSecretField.stringValue }
    private var siteValue: String { siteField.stringValue }
    private var loginNameValue: String { loginNameField.stringValue }
    #elseif canImport(UIKit)
    private var userNameValue: String { userNameField.text ?? "" }
    private var userSecretValue: String { userSecretField.text ?? "" }
    private var siteValue: String { siteField.text ?? "" }
    private var loginNameValue: String { loginNameField.text ?? "" }

    private func labeledFieldStack(title: String, field: UITextField) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .subheadline)

        let stack = UIStackView(arrangedSubviews: [label, field])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    private func buttonRow() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [cancelButton, continueButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .leading
        return stack
    }
    #endif
}
