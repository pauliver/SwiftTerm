import UIKit
import SwiftTerm

final class TransformTestViewController: UIViewController {
    private let terminalView = TerminalView(frame: .zero)
    private let containerView = UIView()
    private var lineCounter = 0

    static let refFontSize: CGFloat = 12
    static let targetCols = 80

    private static let charWidth: CGFloat = {
        let font = UIFont.monospacedSystemFont(ofSize: refFontSize, weight: .regular)
        let attr = NSAttributedString(string: "M", attributes: [.font: font])
        return ceil(attr.size().width * 100) / 100
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        title = "Transform Test"

        containerView.backgroundColor = .black
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
        ])

        terminalView.font = UIFont.monospacedSystemFont(ofSize: Self.refFontSize, weight: .regular)
        terminalView.nativeBackgroundColor = .black
        containerView.addSubview(terminalView)

        let addButton = UIButton(type: .system)
        addButton.setTitle("Add 20 Lines", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        addButton.addTarget(self, action: #selector(addLines), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)

        let clearButton = UIButton(type: .system)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        clearButton.addTarget(self, action: #selector(clearTerminal), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clearButton)

        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60),
            addButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16),
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60),
            clearButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16),
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let containerSize = containerView.bounds.size
        guard containerSize.width > 0, containerSize.height > 0 else { return }

        let nativeW = Self.charWidth * CGFloat(Self.targetCols + 2)
        let scale = containerSize.width / nativeW

        if scale >= 1.0 {
            terminalView.transform = .identity
            terminalView.frame = containerView.bounds
        } else {
            let nativeH = containerSize.height / scale
            terminalView.transform = .identity
            terminalView.bounds = CGRect(x: 0, y: 0, width: nativeW, height: nativeH)
            terminalView.center = CGPoint(x: containerSize.width / 2, y: containerSize.height / 2)
            terminalView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        terminalView.setNeedsDisplay()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        feedInitialContent()
    }

    private func feedInitialContent() {
        let clear = "\u{1b}[2J\u{1b}[H"
        let banner = "\u{1b}[1;36m=== SwiftTerm CGAffineTransform Test ===\u{1b}[0m\r\n"
        let info = "\u{1b}[33mContainer is narrower than \(Self.targetCols) cols — transform scaling active\u{1b}[0m\r\n"
        let divider = "\u{1b}[90m" + String(repeating: "─", count: 78) + "\u{1b}[0m\r\n"
        feed(clear + banner + info + divider)

        for i in 1...10 {
            lineCounter += 1
            let color = 31 + (i % 6)
            let line = "\u{1b}[\(color)mLine \(String(format: "%04d", lineCounter)): " +
                String(repeating: "ABCDabcd", count: 9).prefix(70) +
                "\u{1b}[0m\r\n"
            feed(line)
        }
    }

    @objc private func addLines() {
        for _ in 1...20 {
            lineCounter += 1
            let color = 31 + (lineCounter % 6)
            let line = "\u{1b}[\(color)mLine \(String(format: "%04d", lineCounter)): " +
                "The quick brown fox jumps over the lazy dog. ANSI position test." +
                "\u{1b}[0m\r\n"
            feed(line)
        }
    }

    @objc private func clearTerminal() {
        lineCounter = 0
        feed("\u{1b}[2J\u{1b}[H")
        feedInitialContent()
    }

    private func feed(_ text: String) {
        let data = Array(text.utf8)
        terminalView.feed(byteArray: ArraySlice(data))
    }
}
