import Foundation

enum Provider: String, CaseIterable, Identifiable {
    case openAI = "openai"
    case deepSeek = "deepseek"
    case glmCoding = "switcher_glm_coding"
    case kimiCoding = "switcher_kimi_coding"
    case glmAPI = "switcher_glm_api"
    case kimiAPI = "switcher_kimi_api"

    var id: Self { self }

    var title: String {
        switch self {
        case .openAI: "OpenAI"
        case .deepSeek: "DeepSeek"
        case .glmCoding: "ZCode / GLM Coding Plan"
        case .kimiCoding: "Kimi Coding Plan"
        case .glmAPI: "GLM API"
        case .kimiAPI: "Kimi API"
        }
    }

    var model: String? {
        switch self {
        case .openAI: nil
        case .deepSeek: "deepseek-flash"
        case .glmCoding: "glm-5.4"
        case .kimiCoding: "kimi-for-coding"
        case .glmAPI: "glm-5.3"
        case .kimiAPI: "kimi-k3"
        }
    }

    var details: String {
        switch self {
        case .openAI: "GPT · 默认启动"
        case .deepSeek: "Flash 1017"
        case .glmCoding: "GLM-5.4 · 订阅额度"
        case .kimiCoding: "kimi-for-coding · 订阅额度"
        case .glmAPI: "GLM-5.3 · 按量计费"
        case .kimiAPI: "Kimi K3 · 按量计费"
        }
    }

    var symbol: String {
        switch self {
        case .glmCoding, .glmAPI: "g.circle"
        case .kimiCoding, .kimiAPI: "k.circle"
        case .openAI, .deepSeek: "cpu"
        }
    }

    func setupURL(in region: ProviderRegion) -> URL? {
        let address: String
        switch self {
        case .openAI, .deepSeek: return nil
        case .glmCoding:
            address = region == .china ? "https://docs.bigmodel.cn/cn/coding-plan/tool/codex"
                : "https://docs.z.ai/devpack/tool/codex"
        case .kimiCoding: address = "https://www.kimi.com/code/docs/third-party-tools/codex.html"
        case .glmAPI:
            address = region == .china ? "https://docs.bigmodel.cn/cn/guide/models/text/glm-5.3"
                : "https://docs.z.ai/guides/llm/glm-5.3"
        case .kimiAPI: address = "https://www.kimi.ai/resources/codex-api"
        }
        return URL(string: address)
    }

    func baseURL(in region: ProviderRegion) -> String? {
        switch self {
        case .openAI, .deepSeek: nil
        case .glmCoding, .glmAPI:
            region == .china ? "https://open.bigmodel.cn/api/v1" : "https://api.z.ai/api/v1"
        case .kimiCoding:
            region == .china ? "https://api.kimi.com/coding/v1" : "https://api.kimi.ai/coding/v1"
        case .kimiAPI:
            region == .china ? "https://api.moonshot.cn/v1" : "https://api.moonshot.ai/v1"
        }
    }
}

enum ProviderRegion: String, CaseIterable, Identifiable {
    case china, international

    var id: Self { self }
    var title: String { self == .china ? "中国大陆" : "国际" }
}

struct ProviderSelection: Equatable {
    static let openAI = Self(provider: .openAI)

    let provider: Provider
    var region: ProviderRegion = .china

    var baseURL: String? { provider.baseURL(in: region) }
    var setupURL: URL? { provider.setupURL(in: region) }

    var keychainService: String? {
        guard baseURL != nil else { return nil }
        return "com.caseclose.codex-provider-switcher.\(provider.rawValue).\(region.rawValue)"
    }

    var title: String {
        baseURL == nil ? provider.title : "\(provider.title)（\(region.title)）"
    }
}
