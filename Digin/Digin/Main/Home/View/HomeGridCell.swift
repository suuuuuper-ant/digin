//
//  HomeGridCell.swift
//  Digin
//
//  Created by jinho jeong on 2021/04/19.
//

import UIKit
import SwiftUI

class HomeGridCell: UICollectionViewCell {
    lazy var favoriteCompanyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "관심기업"
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    lazy var companyImageView: UIImageView = {
        let companyImage = UIImageView()
        companyImage.backgroundColor = .red
        return companyImage
    }()

    lazy var relativeTagStack: UIStackView = {
        let tag = UIStackView()
        tag.spacing = 10
        tag.alignment = .leading
        tag.addArrangedSubview(UILabel())
        tag.addArrangedSubview(UILabel())
        tag.addArrangedSubview(UILabel())
        return tag
    }()

    lazy var likeButton: UIButton = {
        let like = UIButton()
        like.backgroundColor  = .red
        return like
    }()

    lazy var contentArea: HomeGridPriceArea = {
     let area = HomeGridPriceArea()
        area.layer.cornerRadius = 15
        area.layer.masksToBounds = true
        return area
    }()
    lazy var roundShadowView = RoundShadowView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubiews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(model: Company) {

        model.tags.enumerated().forEach { (index, str) in
            (relativeTagStack.subviews[index] as? UILabel)?.text  = str
        }

        for idx in (model.tags.count..<relativeTagStack.subviews.count) {
            (relativeTagStack.subviews[idx] as? UILabel)?.text = ""
        }

        favoriteCompanyLabel.text = model.interestingCompany

        contentArea.model =  Float(model.currentPrice)! / (Float(model.targetPrice) ?? 0.0 )
    }

    private func setupConstraints() {

        let roundShadowViewConstraints = [
            roundShadowView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            roundShadowView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            roundShadowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            roundShadowView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ]

        let companyImageViewConstraints = [
            companyImageView.leadingAnchor.constraint(equalTo: roundShadowView.leadingAnchor, constant: 16),
            companyImageView.topAnchor.constraint(equalTo: roundShadowView.topAnchor, constant: 30),
            companyImageView.widthAnchor.constraint(equalToConstant: 32),
            companyImageView.heightAnchor.constraint(equalToConstant: 32)
        ]

        let favoriteCompanyLabelConstraints = [
            favoriteCompanyLabel.leadingAnchor.constraint(equalTo: companyImageView.trailingAnchor, constant: 10),
            favoriteCompanyLabel.topAnchor.constraint(equalTo: companyImageView.topAnchor),
            favoriteCompanyLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -10)
        ]

        let likeButtonConstraints = [
            likeButton.trailingAnchor.constraint(equalTo: roundShadowView.trailingAnchor, constant: -14),
            likeButton.topAnchor.constraint(equalTo: companyImageView.topAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 20),
            likeButton.heightAnchor.constraint(equalToConstant: 20)
        ]
        likeButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let relativeTagStackConstraints = [
            relativeTagStack.leadingAnchor.constraint(equalTo: roundShadowView.leadingAnchor, constant: 20),
            relativeTagStack.topAnchor.constraint(equalTo: companyImageView.bottomAnchor, constant: 17),
            relativeTagStack.trailingAnchor.constraint(lessThanOrEqualTo: roundShadowView.trailingAnchor, constant: -40)

        ]

        let contentAreaConstraints = [
            contentArea.leadingAnchor.constraint(equalTo: roundShadowView.leadingAnchor, constant: 16),
            contentArea.trailingAnchor.constraint(equalTo: roundShadowView.trailingAnchor, constant: -16),
            contentArea.topAnchor.constraint(equalTo: relativeTagStack.bottomAnchor, constant: 20),
           // contentArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -140)
            contentArea.heightAnchor.constraint(equalToConstant: 115)
        ]

        contentArea.backgroundColor = .gray

        [roundShadowViewConstraints,
         companyImageViewConstraints,
        favoriteCompanyLabelConstraints,
         relativeTagStackConstraints,
         likeButtonConstraints,
         contentAreaConstraints
        ].forEach(NSLayoutConstraint.activate(_:))
    }

    private func addSubiews() {
        addSubview(roundShadowView)
        roundShadowView.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.white
           let subviews = [companyImageView, favoriteCompanyLabel, relativeTagStack, likeButton, contentArea]

           subviews.forEach {
            roundShadowView.addSubview($0)
               $0.translatesAutoresizingMaskIntoConstraints = false
           }
       }
}

class HomeGridPriceArea: UIView {

    lazy var originLabel: UILabel = UILabel()
    lazy var dateLabel: UILabel = UILabel()
    lazy var byOrSellLabel: UILabel = {
        let label = UILabel()
        label.text = "SELL"
        label.font = UIFont.systemFont(ofSize: 30)
        return label

    }()

    lazy var iconImageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .yellow
        return image
    }()
    lazy var progressBarView: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.progress = 0.5
        progressBar.backgroundColor = .darkGray
        progressBar.layer.cornerRadius = 10
        progressBar.clipsToBounds = true
        progressBar.layer.sublayers![1].cornerRadius = 10
        progressBar.progressTintColor = .systemPink
        return progressBar
    }()

    var currentPrice: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "현재가\n59,999"
        return label
    }()

    var model: Float = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubiews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        progressBarView.progress = Float(model)
        const?.constant = progressBarView.frame.width * CGFloat(progressBarView.progress)

    }
    private func addSubiews() {
           let subviews = [originLabel,
                           dateLabel,
                           byOrSellLabel,
                           iconImageView,
                           progressBarView,
                           currentPrice
           ]

           subviews.forEach {
               self.addSubview($0)
               $0.translatesAutoresizingMaskIntoConstraints = false
           }
    }
    var const: NSLayoutConstraint?
    private func setupConstraints() {

        originLabel.text = "한경컨센서스"
        let originConstraints = [
            originLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            originLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10)
        ]

        let buyOrSellConstraints = [
            byOrSellLabel.topAnchor.constraint(equalTo: originLabel.bottomAnchor, constant: 13),
            byOrSellLabel.leadingAnchor.constraint(equalTo: originLabel.leadingAnchor)
        ]

        dateLabel.text = "21.04.23"
        let dateConstraints = [
            dateLabel.bottomAnchor.constraint(equalTo: originLabel.bottomAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -21),
            dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: originLabel.trailingAnchor, constant: 48)
        ]

        let iconConstraints = [
            iconImageView.centerYAnchor.constraint(equalTo: byOrSellLabel.centerYAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20)
        ]

        let progressBarConstraints = [
            progressBarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            progressBarView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            progressBarView.heightAnchor.constraint(equalToConstant: 20),
            progressBarView.bottomAnchor
                .constraint(equalTo: bottomAnchor, constant: -16)
        ]

        const = currentPrice.centerXAnchor.constraint(equalTo: leadingAnchor, constant: frame.width * CGFloat(progressBarView.progress))
        const?.isActive = true
        currentPrice.bottomAnchor.constraint(equalTo: progressBarView.topAnchor, constant: -10).isActive = true

        [originConstraints,
         buyOrSellConstraints,
         dateConstraints,
         iconConstraints,
         progressBarConstraints
        ].forEach(NSLayoutConstraint.activate(_:))
    }
}
