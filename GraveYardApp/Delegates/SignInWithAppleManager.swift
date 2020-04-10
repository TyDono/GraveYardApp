//
//  SignInWithAppleManager.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 4/10/20.
//  Copyright © 2020 Tyler Donohue. All rights reserved.
//

import Foundation
import AuthenticationServices

struct SignInWithAppleManager {

    static let userIdentifierKey = "userIdentifier"

    @available(iOS 13.0, *)
    static func checkUserAuth(completion: @escaping (AuthState) -> ()) {
        guard let userIdentifier = UserDefaults.standard.object(forKey: userIdentifierKey) as? String else {
            print("User identifier does not exist")
            completion(.undefined)
            return
        }
        if userIdentifier == "" {
            print("User identifier is empty string")
            completion(.undefined)
            return
        }
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userIdentifier) { (credentialState, error) in
            DispatchQueue.main.async {
                switch credentialState {
                case .authorized:
                    // The Apple ID credential is valid. Show Home UI Here
                    print("Credential state: .authorized")
                    completion(.signedIn)
                    break
                case .revoked:
                    // The Apple ID credential is revoked. Show SignIn UI Here.
                    print("Credential state: .revoked")
                    completion(.undefined)
                    break
                case .notFound:
                    // No credential was found. Show SignIn UI Here.
                    print("Credential state: .notFound")
                    completion(.signedOut)
                    break
                default:
                    break
                }
            }
        }
    }

}
