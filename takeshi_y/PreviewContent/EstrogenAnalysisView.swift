//  EstrogenAnalysisView.swift
//  takeshi_y

import Foundation
import SwiftUI
import AVKit

// 🔹 日付取得関数 (`yyyy-MM-dd` 形式)
func formattedDate() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
}

// 🔹 健康データのレスポンス構造体
struct HealthDataResponse: Codable {
    var estrogenLevel: Double
    
    enum CodingKeys: String, CodingKey {
        case estrogenLevel = "estrogen_Level" // 修正箇所: JSONのキーに合わせて修正
    }
}

// 🔹 エストロゲンデータ取得クラス
class EstrogenDataFetcher: ObservableObject {
    @Published var estrogenScore: Double? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func fetchEstrogenScore() {
        let formattedDateString = formattedDate()

        guard let url = URL(string: "https://takeshi-y.onrender.com/analyze_health_data/estrogen?date=\(formattedDateString)") else {
            DispatchQueue.main.async {
                self.errorMessage = "無効なURLです"
            }
            return
        }

        self.isLoading = true
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "通信エラー: \(error.localizedDescription)"
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                    self.errorMessage = "最新の解析データがありません"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "データがありません"
                    return
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(HealthDataResponse.self, from: data)
                    self.estrogenScore = decodedResponse.estrogenLevel
                } catch {
                    self.errorMessage = "データの解析に失敗しました: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// 🔹 エストロゲン解析ビュー
struct EstrogenAnalysisView: View {
    @StateObject private var dataFetcher = EstrogenDataFetcher()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.pink.opacity(0.3), .purple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("エストロゲンスコア解析結果")
                    .font(.title2)
                    .bold()
                    .padding(.top, 10)

                if dataFetcher.isLoading {
                    ProgressView("データを読み込み中...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.top, 20)
                }

                if let errorMessage = dataFetcher.errorMessage {
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }

                // 修正後のエストロゲンスコア表示部分
                if let estrogenScore = dataFetcher.estrogenScore {
                    Text("エストロゲンスコア")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 10)
                        .foregroundColor(.black)
                    Text("\(String(format: "%.1f", estrogenScore))")
                        .font(.system(size: 70))
                        .bold()
                        .foregroundColor(estrogenScore <= 50 ? .orange : estrogenScore > 150 ? .red : .blue)
                        .padding(.top, -10)

                    EstrogenStatusMessage(estrogenScore: estrogenScore)
                } else {
                    Text("解析データはありません")
                        .font(.body)
                        .foregroundColor(.red)
                        .padding(.top, 20)
                }

                Spacer()
                EstrogenInfoSection()
            }
            .padding()
        }
        .onAppear {
            dataFetcher.fetchEstrogenScore()
        }
    }
}

// 🔹 エストロゲンに基づいたメッセージ表示
private func EstrogenStatusMessage(estrogenScore: Double) -> some View {
    HStack {
        if estrogenScore < 30 {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 35))
                .foregroundColor(.blue)
                .padding(.trailing, 10)
            Text("エストロゲン値が低いです！")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.blue)
        } else if estrogenScore > 150 {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 35))
                .foregroundColor(.red)
                .padding(.trailing, 10)
            Text("エストロゲンが非常に高いです！")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.red)
        } else {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 35))
                .foregroundColor(.orange)
                .padding(.trailing, 10)
            Text("エストロゲンは正常範囲です")
                .font(.system(size: 25, weight: .medium))
                .foregroundColor(.orange)
        }
    }
    .padding(.bottom, -30)
}

// 🔹 エストロゲンスコアの情報セクション
private func EstrogenInfoSection() -> some View {
    VStack(alignment: .leading, spacing: 1) {
        Image("エストロゲン")
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 150)
            .padding(.top, -70)
            .frame(maxWidth: .infinity, alignment: .center)

        Text("エストロゲンスコアの基準値")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, alignment: .center)

        Text("""
        50〜150: 正常範囲。健康なホルモンバランスを保っています。
        30〜50: やや低い範囲。軽い症状が現れる可能性があり、生活習慣の改善が推奨されます。
        0〜30: 低すぎる範囲。更年期やホルモン不均衡の可能性があり、医師の診断が推奨されます。
        🔹エストロゲンを健康的に保つ方法
        ✅ エストロゲンを増やすには？
        **適度な運動（ウォーキング・ヨガ・ストレッチ）
        十分な睡眠（ホルモン分泌は睡眠中に活発化）
        ✅ エストロゲンを抑えるには？
        ストレスを減らす（ストレスはホルモンバランスを乱す）
        """)
        .font(.body)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.top, 10)
    }
    .padding(.top, -10)
}

// 🔹 プレビュー用
struct EstrogenAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        EstrogenAnalysisView()
    }
}



// render： takeshi-y.onrender.com
// ローカル：192.168.0.59:8000


