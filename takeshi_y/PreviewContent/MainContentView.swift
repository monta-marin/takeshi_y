//
//  MainContentView.swift
//  takeshi_y
//
//  Created by 山崎猛 on 2025/02/13.
//

import SwiftUI

struct MainContentView: View {
    @State private var estrogen: Double = 50.0
    @State private var cortisol: Double = 20.0
    @State private var immunity: Double = 70.0
    @State private var selectedDate: Date = Date()
    @State private var showDataEntryModal: Bool = false
    @State private var noDataForSelectedDate: Bool = false

    @State private var isSideMenuOpen: Bool = false
    @State private var selectedView: SideMenuDestination? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                LinearGradient(
                    gradient: Gradient(colors: [.pink.opacity(0.3), .purple.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                // メインコンテンツ
                VStack {
                    HStack {
                        Button(action: {
                            withAnimation {
                                isSideMenuOpen.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .resizable()
                                .aspectRatio(contentMode: .fit) // ← 追加！
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)        // 色も指定
                                .padding(.leading, 5)
                        }
                       
                        .zIndex(2) // ← これを追加
                    }

                    headerSection

                    ButtonSection(
                        estrogen: $estrogen,
                        cortisol: $cortisol,
                        immunity: $immunity,
                        selectedDate: $selectedDate,
                        showDataEntryModal: $showDataEntryModal,
                        noDataForSelectedDate: $noDataForSelectedDate
                    )
                }

                // サイドメニューの背景と本体
                if isSideMenuOpen {
                    // 半透明背景（タップで閉じる）
                    Color.white.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                isSideMenuOpen = false
                            }
                        }
                        .zIndex(0.9)

                    // サイドメニュー
                    SideMenu(isOpen: $isSideMenuOpen, selectedView: $selectedView)
                        .transition(.move(edge: .leading))
                        .zIndex(1) // 最前面に表示
                }
            }
            // ナビゲーション遷移処理
            .navigationDestination(isPresented: Binding(
                get: { selectedView != nil },
                set: { newValue in if !newValue { selectedView = nil } }
            )) {
                selectedView?.view
            }
        }
    }

    // MARK: - ヘッダー
    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("ウェルネスシステム")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.brown)
                .padding(.top, -10)

            Text("ホルモンバランスの推定値を可視化")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.brown)

            Text("健康アプリ")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.brown)
                .padding(.top, -5)

            Image("ホーム画面")
                .resizable()
                .scaledToFit()
                .frame(width: 620, height: 280)
                .padding(.top, 20)
        }
        .padding()
    }
}


// MARK: - ボタンセクション
struct ButtonSection: View {
    @Binding var estrogen: Double
    @Binding var cortisol: Double
    @Binding var immunity: Double
    @Binding var selectedDate: Date
    @Binding var showDataEntryModal: Bool
    @Binding var noDataForSelectedDate: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1つ目の行
                HStack(spacing: 7) {
                    NavigationLink(destination: EstrogenAnalysisView()) {
                        CustomButton(imageName: "エストロゲン", title: "女性ホルモン")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        triggerHapticFeedback()
                    })
                    
                    NavigationLink(destination: CortisolAnalysisView()) {
                        CustomButton(imageName: "コルチゾール", title: "ストレスホルモン")
                            .padding()
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        triggerHapticFeedback()
                    })
                    
                    NavigationLink(destination: ImmunityAnalysisView()) {
                        CustomButton(imageName: "免疫スコア", title: "免疫力")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        triggerHapticFeedback()
                    })
                }
                
                // 2つ目の行
                HStack(spacing: 22) {
                    NavigationLink(destination: MeasurementPageView()) {
                        CustomButton(imageName: "Image 2", title: "ウェアブルデータ")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        triggerHapticFeedback()
                    })
                    
                    NavigationLink(destination: HealthDataInputView()) {
                        CustomButton(imageName: "Image 3", title: "個別入力データ")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        triggerHapticFeedback()
                    })
                    
                    NavigationLink(destination: CalendarView()) {
                        CustomButton(imageName: "Image 1", title: "ログカレンダー")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        triggerHapticFeedback()
                    })
                }
            }
        }
    }
}

// MARK: - カスタムボタン
struct CustomButton: View {
    var imageName: String
    var title: String
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 98, height: 98)
            
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .multilineTextAlignment(.center)
        }
        .frame(width: 105, height: 130)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

// MARK: - サイドメニュー

struct applicationView: View {
    var body: some View {
        Text("アプリの使い方（実装してください）")
            .navigationTitle("アプリの使い方")
    }
}

struct CompanyHomeView: View {
    var body: some View {
        Text("会社ホームページ（実装してください）")
            .navigationTitle("会社ホームページ")
    }
}

struct ContactView: View {
    var body: some View {
        Text("お問い合わせ画面（実装してください）")
            .navigationTitle("お問い合わせ")
    }
}

enum SideMenuDestination: Hashable {
    case companyHome
    case contact

    @ViewBuilder
    var view: some View {
        switch self {
        case .companyHome:
            CompanyHomeView()
        case .contact:
            ContactView()
        }
    }
}

struct SideMenu: View {
    @Binding var isOpen: Bool
    @Binding var selectedView: SideMenuDestination?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer().frame(height: 80) // ← 上からの余白を追加

            Button("アプリの使い方") {
                if let url = URL(string: "https://docs.google.com/document/d/1pIenfHFZC_nJ7pARxenMi2NJcGL3KA-ZY1CZs6rjerI/edit?usp=sharing") {
                    UIApplication.shared.open(url)
                }
                isOpen = false
            }
            
            
            Button("会社ホームページ") {
                if let url = URL(string: "https://studioposture.com/yamasakibodywork/") {
                    UIApplication.shared.open(url)
                }
                isOpen = false
            }


            Button("お問い合わせ") {
                if let url = URL(string: "mailto:kururu.misuke@gmail.com") {
                    UIApplication.shared.open(url)
                }
                isOpen = false
            }


            Spacer()
        }
        .padding()
        .frame(maxWidth: 220, alignment: .leading)
        .background(Color(.systemGray6))
        .edgesIgnoringSafeArea(.vertical)
    }
}


// MARK: - 触覚フィードバックを発生させる関数
func triggerHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
}

// MARK: - プレビュー
struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
            .previewDevice("iPhone 14 Pro")
    }
}




