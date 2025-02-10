import UIKit

class TemplatePickerViewController: UIViewController {
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose a Template"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    var completion: ((String, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        stackView.addArrangedSubview(titleLabel)
        
        let plainTextButton = createTemplateButton(
            title: "Plain Text Template",
            subtitle: "Start with a basic text document",
            action: #selector(plainTextSelected)
        )
        
        let richTextButton = createTemplateButton(
            title: "Rich Text Template",
            subtitle: "Start with a formatted document",
            action: #selector(richTextSelected)
        )
        
        stackView.addArrangedSubview(plainTextButton)
        stackView.addArrangedSubview(richTextButton)
        
        // Add cancel button at the bottom
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        stackView.addArrangedSubview(cancelButton)
    }
    
    private func createTemplateButton(title: String, subtitle: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 12
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        button.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: button.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -16)
        ])
        
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    @objc private func plainTextSelected() {
        completion?("exampletext", "TextTemplate")
        dismiss(animated: true)
    }
    
    @objc private func richTextSelected() {
        completion?("sampledoc", "RichTemplate")
        dismiss(animated: true)
    }
    
    @objc private func cancelTapped() {
        completion?(String(), String())
        dismiss(animated: true)
    }
} 