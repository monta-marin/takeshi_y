//  CortisolAnalysisView.swift
//  takeshi_y

import SwiftUI
import Foundation

// 🔹 コルチゾールデータ取得クラス
class CortisolDataFetcher: ObservableObject {
    @Published var cortisolScore: Double? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func fetchCortisolScore() {
        let formattedDateString = formattedDate()
        guard let url = URL(string: "https://takeshi-y.onrender.com/healthdata/cortisol?date=\(formattedDateString)") else {
            DispatchQueue.main.async { self.errorMessage = "無効なURLです" }
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

                // ここでレスポンスのデータをデバッグ
                print(String(data: data, encoding: .utf8) ?? "無効なデータ")

                do {
                    let decodedResponse = try JSONDecoder().decode(CortisolDataResponse.self, from: data)
                    self.cortisolScore = decodedResponse.cortisolLevel
                    print("コルチゾールスコア: \(self.cortisolScore ?? 0)")
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

// 🔹 コルチゾールデータのレスポンス構造体
struct CortisolDataResponse: Codable {
    var cortisolLevel: Double

    enum CodingKeys: String, CodingKey {
        case cortisolLevel = "cortisol_Level" // JSONのキーがcortisol_Levelであることに合わせる
    }
}

// 🔹 コルチゾール解析ビュー
struct CortisolAnalysisView: View {
    @StateObject private var dataFetcher = CortisolDataFetcher()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.pink.opacity(0.3), .purple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("コルチゾールスコア解析結果")
                    .font(.title2)
                    .bold()
                    .padding(.top, 10)
                    .onAppear { dataFetcher.fetchCortisolScore() }

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

                if let cortisolScore = dataFetcher.cortisolScore {
                    ScoreDisplayView(score: cortisolScore)
                } else {
                    Text("解析データはありません")
                        .font(.body)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }

                Spacer()
                CortisolInfoSection()
            }
            .padding()
        }
    }
}

// 🔹 スコア表示ビュー
struct ScoreDisplayView: View {
    var score: Double

    var body: some View {
        VStack {
            Text("コルチゾールスコア")
                .font(.largeTitle)
                .bold()
                .padding(.top, 10)

            Text("\(String(format: "%.1f", score))")
                .font(.system(size: 70))
                .bold()
                .foregroundColor(score < 5 ? .blue : score > 20 ? .red : .orange)
                .padding(.top, -10)

            CortisolStatusMessage(cortisolScore: score)
        }
    }
}

// 🔹 コルチゾールに基づいたメッセージ表示
struct CortisolStatusMessage: View {
    var cortisolScore: Double

    var body: some View {
        HStack {
            if cortisolScore < 5 {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 35))
                    .foregroundColor(.blue)
                    .padding(.trailing, 10)
                Text("コルチゾールが低いです！")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.blue)
            } else if cortisolScore > 20 {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 35))
                    .foregroundColor(.red)
                    .padding(.trailing, 10)
                Text("コルチゾールが高いです！")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.red)
            } else {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 35))
                    .foregroundColor(.orange)
                    .padding(.trailing, 10)
                Text("コルチゾールは正常範囲です")
                    .font(.system(size: 25, weight: .medium))
                    .foregroundColor(.orange)
            }
        }
        .padding(.top, -30)
    }
}

// 🔹 コルチゾールスコアの情報セクション
struct CortisolInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Image("コルチゾール")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.top, -50)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("コルチゾールスコアの基準値")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)

            Text("""
            5〜20: 正常範囲。健康なホルモンバランスを保っています。
            5以下: コルチゾールが低い状態。エネルギー不足やストレス低下の可能性があります。
            20以上: コルチゾールが高い状態。慢性的なストレスや体調不良の可能性があります。
            🔹コルチゾールを健康的にコントロール
            ✅ コルチゾールを下げるには？
            深呼吸・瞑想・ヨガ・ピラティス（リラックスすることでストレスを軽減）
            睡眠時間をしっかり摂りましょう！
            ✅ コルチゾールを増やすには？
            適度な運動（ウォーキングやジョギングなど）
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

// 🔹 プレビュー用
struct CortisolAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        CortisolAnalysisView()
    }
}


// render： takeshi-y.onrender.com
// ローカル：192.168.0.59:8000













