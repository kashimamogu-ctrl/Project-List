//  UserProfile.swift
//  Project List
import Foundation
import SwiftData

@Model
final class UserProfile
{
    var name: String

    var heightCm: Double?
    var weightKg: Double?

    var boneType: String
    var personalColor: String
    var faceType: String
    var skinType: String

    var memo: String

    @Relationship(deleteRule: .cascade, inverse: \ExternalAccount.profile)
    var externalAccounts: [ExternalAccount] = []

    init(
        name: String = "",
        heightCm: Double? = nil,
        weightKg: Double? = nil,
        boneType: String = "",
        personalColor: String = "",
        faceType: String = "",
        skinType: String = "",
        memo: String = ""
    ) {
        self.name = name
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.boneType = boneType
        self.personalColor = personalColor
        self.faceType = faceType
        self.skinType = skinType
        self.memo = memo
    }
}

@Model
final class ExternalAccount
{
    var platform: String
    var accountID: String
    var profileURL: String
    var profile: UserProfile?

    init(
        platform: String,
        accountID: String = "",
        profileURL: String = "",
        profile: UserProfile? = nil
    ) {
        self.platform = platform
        self.accountID = accountID
        self.profileURL = profileURL
        self.profile = profile
    }
}
