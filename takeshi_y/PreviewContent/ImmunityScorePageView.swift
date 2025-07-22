//  ImmunityScorePageView.swift
//  takeshi_y

import SwiftUI
import Foundation

// 🔹 ImmunityDataFetcher: 免疫力スコアを取得するクラス
class ImmunityDataFetcher: ObservableObject {
    @Published var immunityScore: Double? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func fetchImmunityScore() {
        let formattedDateString = formattedDate()
        guard let url = URL(string: "http://192.168.0.59:8000/analyze_health_data/immunity?date=\(formattedDateString)") else {
            DispatchQueue.main.async { self.errorMessage = "無効なURLです" }
            return
        }

        self.isLoading = true
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // データを非同期で取得
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                // エラーハンドリング
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

                // レスポンスのデコード
                do {
                    let decodedResponse = try JSONDecoder().decode(ImmunityDataResponse.self, from: data)
                    self.immunityScore = decodedResponse.immunityScore
                } catch {
                    self.errorMessage = "データの解析に失敗しました: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

// 🔹 ImmunityDataResponse: 免疫力データのレスポンスモデル
struct ImmunityDataResponse: Codable {
    var immunityScore: Double

    enum CodingKeys: String, CodingKey {
        case immunityScore = "immunity_Score" // 変更: APIレスポンスのキー名と一致させる
    }
}

// 🔹 ImmunityAnalysisView: 免疫力解析結果を表示するビュー
struct ImmunityAnalysisView: View {
    @StateObject private var dataFetcher = ImmunityDataFetcher()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.pink.opacity(0.3), .purple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("免疫力スコア解析結果")
                    .font(.title2)
                    .bold()
                    .padding(.top, 10)
                    .onAppear { dataFetcher.fetchImmunityScore() }
                
                Text("免疫力スコア")
                    .font(.largeTitle)
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

                if let immunityScore = dataFetcher.immunityScore {
                    Text("\(String(format: "%.1f", immunityScore))")
                        .font(.system(size: 70))
                        .bold()
                        .foregroundColor(immunityScore < 50 ? .red : immunityScore > 75 ? .green : .orange)
                        .padding(.top, -10)

                    ImmunityStatusMessage(immunityScore: immunityScore)
                } else {
                    Text("解析データはありません")
                        .font(.body)
                        .foregroundColor(.red)
                        .padding(.top, 1)
                }

                Spacer()
                ImmunityInfoSection()
            }
            .padding()
        }
    }
}

// 🔹 ImmunityStatusMessage: 免疫力スコアに基づくメッセージを表示するビュー
struct ImmunityStatusMessage: View {
    var immunityScore: Double

    var body: some View {
        HStack {
            if immunityScore < 50 {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 35))
                    .foregroundColor(.red)
                    .padding(.trailing, 10)
                Text("免疫力が低いです！")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.red)
            } else if immunityScore > 75 {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 35))
                    .foregroundColor(.green)
                    .padding(.trailing, 10)
                Text("免疫力が高いです！")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.green)
            } else {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 35))
                    .foregroundColor(.orange)
                    .padding(.trailing, 10)
                Text("免疫力は正常範囲です")
                    .font(.system(size: 25, weight: .medium))
                    .foregroundColor(.orange)
            }
        }
        .padding(.top, -30)
    }
}

// 🔹 ImmunityInfoSection: 免疫力に関する情報セクションを表示するビュー
struct ImmunityInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Image("免疫スコア")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.top, -50)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("免疫力スコアの基準値")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("""
            75〜100: 健康な免疫力を保持しています。
            50〜75: 通常範囲ですが、ストレス管理が重要です。
            50以下: 免疫力が低下しています。健康管理を強化してください。
            🔹 免疫力を高める方法
            ✅ 質の良い睡眠をとる 🌙
            　　7時間以上の睡眠を心がける
            ✅ バランスの良い食事をとる 🥗
             乳酸菌・発酵食品（ヨーグルト・納豆）→ 腸内環境を整える
            ✅ 体を冷やさない 🛀
            　**お風呂に浸かる（38〜40...
            """)
                .font(.body)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.top, 10)
        }
        .padding(.top, -10)
    }
}

// 🔹 プレビュー
struct ImmunityAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        ImmunityAnalysisView()
    }
}
