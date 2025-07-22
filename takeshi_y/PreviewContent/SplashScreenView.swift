//
//  SplashScreenView.swift
//  takeshi_y
//
//  Created by 山崎猛 on 2025/02/13.
//

import SwiftUI

// MARK: - アプリの状態管理クラス
class AppState: ObservableObject {
    enum Screen {
        case splash
        case agreement    // 注意事項・同意画面
        case login
        case main
    }
    @Published var currentScreen: Screen = .splash
}

// MARK: - アプリのエントリーポイント
@main
struct MyApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}

// MARK: - 画面切り替え用のルートビュー
struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        switch appState.currentScreen {
        case .splash:
            SplashScreenView()
        case .agreement:
            AgreementView()
        case .login:
            LoginView()
        case .main:
            MainContentView()
        }
    }
}

// MARK: - スプラッシュ画面
struct SplashScreenView: View {
    @EnvironmentObject var appState: AppState
    @State private var imageOpacity: Double = 0.0
    @State private var imageScale: CGFloat = 0.5

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.pink.opacity(0.6), .purple.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                Image("Image")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .opacity(imageOpacity)
                    .scaleEffect(imageScale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.0)) {
                            imageOpacity = 1.0
                            imageScale = 1.0
                        }
                    }
                    .padding(.top, -90)

                Text("ホルモンバランスの推定スコアを\n可視化できるアプリ")
                    .font(.title)
                    .foregroundColor(Color(red: 0.3, green: 0.15, blue: 0.05))
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    appState.currentScreen = .agreement
                }
            }
        }
    }
}

// MARK: - 注意事項・同意画面
struct AgreementView: View {
    @EnvironmentObject var appState: AppState
    @State private var isAgreed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("　　　ご利用にあたっての注意事項")
                .font(.title2)
                .bold()
                .padding(.bottom, 10)

            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("・このアプリは治療目的のものではありません。")
                    Text("・データは端末内で管理されます。")
                    Text("・本アプリでは、AppleのHealthKitと連携して健康\n　データを利用することがあります。\n　連携にあたっては、アプリ内で別途ユーザーの明確\n　な許可をいただきます。")

                    Text("・利用規約およびプライバシーポリシーを必ずご確認\n　ください。")
                    Link("利用規約・プライバシーポリシーはこちら", destination: URL(string: "https://docs.google.com/document/d/1iLTwXhJq_t9QMBS9jv2kOXBeadnVR4PzRw3tgKXm0dU/edit?usp=sharing")!)
                        .foregroundColor(.blue)
                }
            }
            .frame(maxHeight: 200)
            .padding(.bottom, 20)

            Toggle(isOn: $isAgreed) {
                Text("上記に同意して利用を開始します")
                    .font(.body)
            }
            .padding(.bottom, 20)

            Button(action: {
                if isAgreed {
                    withAnimation {
                        appState.currentScreen = .login
                    }
                }
            }) {
                Text("次へ")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isAgreed ? Color.pink : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!isAgreed)

            Spacer()
        }
        .padding()
    }
}

// MARK: - ログイン画面
struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var showSignUp = false

    var body: some View {
        VStack(spacing: 20) {
            Text("ログイン")
                .font(.largeTitle)
                .padding()

            TextField("メールアドレス", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal)

            SecureField("パスワード", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("ログイン") {
                let savedEmail = UserDefaults.standard.string(forKey: "email")
                let savedPassword = UserDefaults.standard.string(forKey: "password")

                if email == savedEmail && password == savedPassword {
                    appState.currentScreen = .main
                } else {
                    showAlert = true
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.pink)
            .cornerRadius(10)

            Button("新規登録はこちら") {
                showSignUp = true
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("ログイン失敗"),
                message: Text("メールアドレスまたはパスワードが間違っています。"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// MARK: - 新規登録画面
import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false

    var body: some View {
        VStack(spacing: 20) {
            Text("新規登録")
                .font(.title)
                .padding(.top, 30)

            TextField("メールアドレス", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never) // iOS 15+
                .autocorrectionDisabled(true)
                .padding(.horizontal)

            SecureField("パスワード", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("パスワード再入力", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("登録") {
                if password == confirmPassword && !email.isEmpty && !password.isEmpty {
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(password, forKey: "password")
                    presentationMode.wrappedValue.dismiss()
                } else {
                    showError = true
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .alert(isPresented: $showError) {
            Alert(
                title: Text("エラー"),
                message: Text("パスワードが一致しているか、空白でないか確認してください"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// MARK: - メインコンテンツ画面（仮）
    var body: some View {
        Text("メインコンテンツ画面")
            .font(.largeTitle)
            .padding()
    }


