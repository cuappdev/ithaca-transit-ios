//
//  RequestHotspotViewController.swift
//  TCAT
//
//  Created by Gabriel Castillo on 3/11/26.
//  Copyright © 2026 cuappdev. All rights reserved.
//

import PhotosUI
import SnapKit
import UIKit

class RequestHotspotViewController: UIViewController {

    // MARK: - View vars
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let nameLabel = UILabel()
    private let netIDLabel = UILabel()
    private let eventTypeLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let locationLabel = UILabel()

    private let nameTextField = UITextField()
    private let netIDTextField = UITextField()
    private let eventTypeButton = UIButton()
    private let eventTypeChevron = UIImageView()
    private let descriptionTextView = UITextView()
    private let locationTextField = UITextField()

    private let addPhotoButton = UIButton(type: .system)
    private let submitButton = UIButton()

    // MARK: - Data vars
    private let descriptionPlaceholder = "Add A Description..."
    private var selectedEventType: String?
    private let eventTypeOptions = ["Academic", "Social", "Sports", "Cultural", "Other"]
    private var selectedImage: UIImage?
    private var selectedPlace: Place?
    private var searchBarView = SearchBarView()
    private var backButton: UIBarButtonItem?

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.white
        setupNavigationBar()
        setupScrollView()
        setupFormFields()
        setupActionButtons()
        setupConstraints()
        setupKeyboardObservers()
        setupLocationSearch()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "Request a HotSpot"
        titleLabel.font = .getFont(.medium, size: 18)
        titleLabel.textColor = Colors.primaryText
        titleLabel.textAlignment = .left
        titleLabel.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 80, height: 44)
        navigationItem.titleView = titleLabel

        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(dismissTapped)
        )
        navigationItem.rightBarButtonItem = closeButton
    }

    private func setupScrollView() {
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.font = .getFont(.regular, size: 16)
        textField.textColor = Colors.primaryText
        textField.backgroundColor = Colors.backgroundWash
        textField.layer.cornerRadius = 8
        textField.clipsToBounds = true
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        textField.leftView = padding
        textField.leftViewMode = .always
        contentView.addSubview(textField)
    }

    private func configureLabel(_ label: UILabel, text: String) {
        label.text = text
        label.font = .getFont(.medium, size: 16)
        label.textColor = Colors.primaryText
        contentView.addSubview(label)
    }

    private func setupFormFields() {
        configureLabel(nameLabel, text: "Name")
        configureLabel(netIDLabel, text: "NetID")
        configureLabel(eventTypeLabel, text: "Type Of Event")
        configureLabel(descriptionLabel, text: "Description")
        configureLabel(locationLabel, text: "Location")

        configureTextField(nameTextField, placeholder: "Enter your name...")
        configureTextField(netIDTextField, placeholder: "Enter your NetID...")
        configureTextField(locationTextField, placeholder: "Enter a location...")
        locationTextField.delegate = self

        setupEventTypeButton()
        setupDescriptionTextView()
    }

    private func setupEventTypeButton() {
        var config = UIButton.Configuration.plain()
        config.title = "Choose an option..."
        config.baseForegroundColor = Colors.metadataIcon
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0)
        config.background.backgroundColor = Colors.backgroundWash
        config.background.cornerRadius = 8
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var updated = attrs
            updated.font = UIFont.getFont(.regular, size: 16)
            return updated
        }
        eventTypeButton.configuration = config
        eventTypeButton.contentHorizontalAlignment = .leading

        let actions = eventTypeOptions.map { option in
            UIAction(title: option) { [weak self] _ in
                guard let self else { return }
                self.selectedEventType = option
                self.eventTypeButton.configuration?.title = option
                self.eventTypeButton.configuration?.baseForegroundColor = Colors.primaryText
            }
        }
        eventTypeButton.menu = UIMenu(title: "", children: actions)
        eventTypeButton.showsMenuAsPrimaryAction = true
        contentView.addSubview(eventTypeButton)

        eventTypeChevron.image = UIImage(systemName: "chevron.down")
        eventTypeChevron.tintColor = Colors.metadataIcon
        eventTypeChevron.contentMode = .scaleAspectFit
        eventTypeChevron.isUserInteractionEnabled = false
        contentView.addSubview(eventTypeChevron)
    }

    private func setupDescriptionTextView() {
        descriptionTextView.text = descriptionPlaceholder
        descriptionTextView.textColor = Colors.metadataIcon
        descriptionTextView.font = .getFont(.regular, size: 16)
        descriptionTextView.backgroundColor = Colors.backgroundWash
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.clipsToBounds = true
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.delegate = self
        contentView.addSubview(descriptionTextView)
    }

    private func setupLocationSearch() {
        searchBarView = SearchBarView(searchBarCancelDelegate: self, destinationDelegate: self)
        hideLocationSearch()
    }

    private func setupActionButtons() {
        var config = UIButton.Configuration.plain()
        var titleAttr = AttributeContainer()
        titleAttr.font = UIFont.getFont(.semibold, size: 16)
        config.attributedTitle = AttributedString("Add Photo", attributes: titleAttr)
        config.image = plusIcon()
        config.imagePadding = 8
        config.imagePlacement = .leading
        config.baseForegroundColor = Colors.secondaryText
        config.background.backgroundColor = Colors.backgroundWash
        config.background.cornerRadius = 22
        addPhotoButton.configuration = config
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        contentView.addSubview(addPhotoButton)

        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(Colors.white, for: .normal)
        submitButton.titleLabel?.font = .getFont(.medium, size: 16)
        submitButton.backgroundColor = Colors.naviOrange
        submitButton.layer.cornerRadius = 24
        submitButton.clipsToBounds = true
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        contentView.addSubview(submitButton)
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - Constraints

    private func setupConstraints() {
        let hPad = 16
        let labelToField = 8
        let fieldToLabel = 20
        let fieldHeight = 44
        let descriptionMinHeight = 120

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(hPad)
            make.top.equalToSuperview().inset(fieldToLabel)
        }

        nameTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(hPad)
            make.top.equalTo(nameLabel.snp.bottom).offset(labelToField)
            make.height.equalTo(fieldHeight)
        }

        netIDLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(hPad)
            make.top.equalTo(nameTextField.snp.bottom).offset(fieldToLabel)
        }

        netIDTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(hPad)
            make.top.equalTo(netIDLabel.snp.bottom).offset(labelToField)
            make.height.equalTo(fieldHeight)
        }

        eventTypeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(hPad)
            make.top.equalTo(netIDTextField.snp.bottom).offset(fieldToLabel)
        }

        eventTypeButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(hPad)
            make.top.equalTo(eventTypeLabel.snp.bottom).offset(labelToField)
            make.height.equalTo(fieldHeight)
        }

        eventTypeChevron.snp.makeConstraints { make in
            make.trailing.equalTo(eventTypeButton.snp.trailing).inset(12)
            make.centerY.equalTo(eventTypeButton)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(hPad)
            make.top.equalTo(eventTypeButton.snp.bottom).offset(fieldToLabel)
        }

        descriptionTextView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(hPad)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(labelToField)
            make.height.greaterThanOrEqualTo(descriptionMinHeight)
        }

        locationLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(hPad)
            make.top.equalTo(descriptionTextView.snp.bottom).offset(fieldToLabel)
        }

        locationTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(hPad)
            make.top.equalTo(locationLabel.snp.bottom).offset(labelToField)
            make.height.equalTo(fieldHeight)
        }

        addPhotoButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(hPad)
            make.top.equalTo(locationTextField.snp.bottom).offset(fieldToLabel)
            make.height.equalTo(fieldHeight)
        }

        submitButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(hPad)
            make.top.equalTo(addPhotoButton.snp.bottom).offset(fieldToLabel)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(32)
        }
    }

    // MARK: - Location search bar (mirrors RouteOptionsViewController pattern)

    private func showLocationSearch() {
        navigationItem.searchController = searchBarView.searchController
        navigationController?.view.setNeedsLayout()
        backButton = navigationItem.leftBarButtonItem
        navigationItem.setLeftBarButton(nil, animated: false)
        navigationItem.hidesBackButton = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.searchBarView.searchController?.isActive = true
        }
    }

    private func hideLocationSearch() {
        navigationItem.searchController = nil
        navigationController?.view.setNeedsLayout()
        if let backButton {
            navigationItem.setLeftBarButton(backButton, animated: false)
        }
        navigationItem.hidesBackButton = false
        searchBarView.searchController?.isActive = false
    }

    // MARK: - Helpers

    private func plusIcon() -> UIImage {
        UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold))
            ?? UIImage()
    }

    // MARK: - Actions

    @objc private func dismissTapped() {
        dismiss(animated: true)
    }

    @objc private func addPhotoTapped() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func submitTapped() {
        // TODO: Implement form submission
    }

    // MARK: - Keyboard

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = frame.height - view.safeAreaInsets.bottom
        scrollView.verticalScrollIndicatorInsets.bottom = scrollView.contentInset.bottom
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

}

// MARK: - UITextViewDelegate

extension RequestHotspotViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Colors.metadataIcon {
            textView.text = nil
            textView.textColor = Colors.primaryText
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = descriptionPlaceholder
            textView.textColor = Colors.metadataIcon
        }
    }

}

// MARK: - UITextFieldDelegate

extension RequestHotspotViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard textField == locationTextField else { return true }
        showLocationSearch()
        return false
    }

}

// MARK: - DestinationDelegate

extension RequestHotspotViewController: DestinationDelegate {

    func didSelectPlace(place: Place) {
        selectedPlace = place
        locationTextField.text = place.name
        hideLocationSearch()
        searchBarView.searchController?.dismiss(animated: true)
    }

}

// MARK: - SearchBarCancelDelegate

extension RequestHotspotViewController: SearchBarCancelDelegate {

    func didCancel() {
        hideLocationSearch()
    }

}

// MARK: - PHPickerViewControllerDelegate

extension RequestHotspotViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self = self, let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self.selectedImage = image
                let thumbnail = image.preparingThumbnail(of: CGSize(width: 28, height: 28))
                var config = self.addPhotoButton.configuration ?? UIButton.Configuration.plain()
                var titleAttr = AttributeContainer()
                titleAttr.font = UIFont.getFont(.semibold, size: 16)
                config.attributedTitle = AttributedString("Change Photo", attributes: titleAttr)
                config.image = thumbnail?.withRoundedCorners(radius: 4) ?? self.plusIcon()
                self.addPhotoButton.configuration = config
            }
        }
    }

}

