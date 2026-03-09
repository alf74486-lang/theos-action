#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <substrate.h> // المكتبة الأهم لعملية الـ Hooking
#include <string>
#include <vector>
#include <unordered_map>
#include <functional>
#include <regex>
#include <cmath>

‏struct Mode {
    std::string loader;
    std::function<std::string()> target;
    std::string path;
    std::function<void()> fn;
};

struct Location {
    std::string origin = "https://agar.io";
    std::string host = "agar.io";
    std::string pathname = "/";
    std::string search = "";
    std::string href = "https://agar.io/";
};

class DeltaMasterComplete {
private:
    std::string currentVersion = "8.5";
    std::string scriptUpdateURL = "https://deltav4.gitlab.io/delta.user.js";

    bool isDev = false;
    bool isDist = false;

    std::string webBase = "https://deltav4.gitlab.io";
    std::string devBase = "http://127.0.0.1:8080/";
    std::string devDistBase = "http://127.0.0.1:5500/";

    Location location;

    std::string documentTitle = "Agar.io";
    std::string documentBody = "<body></body>";

    bool stopped = false;

    std::unordered_map<std::string, std::string> localStorage;

    std::vector<std::pair<std::string, std::string>> host2path = {
        {"sigmally", "/terms.html"},
        {"", "/delta"}
    };

    std::vector<std::pair<std::string, Mode>> modes;

public: // نضعها هنا لضمان أنها أصبحت عامة وقابلة للاستدعاء
    void injectToGame(WKWebView* webView, std::string jsSource) {
        NSString *code = [NSString stringWithUTF8String:jsSource.c_str()];
        [webView evaluateJavaScript:code completionHandler:^(id result, NSError *error) {
            if (error) {
                NSLog(@"[Delta Error] فشل الحقن: %@", error.localizedDescription);
            } else {
                NSLog(@"[Delta Success] تم حقن السكربت بنجاح!");
            }
        }];
    }

private:
    static bool contains(const std::string& text, const std::string& find) {
        return text.find(find) != std::string::npos;
    }

    static long long version2int(const std::string& x = "0") {
        long long n = 0;
        std::vector<int> parts;
        std::string v = x;

        size_t start = 0;
        while (true) {
            size_t pos = v.find('.', start);
            std::string token = (pos == std::string::npos)
                ? v.substr(start)
                : v.substr(start, pos - start);

            int value = 0;
            try {
                value = token.empty() ? 0 : std::stoi(token);
            } catch (...) {
                value = 0;
            }

            parts.push_back(value);

            if (pos == std::string::npos) {
                break;
            }
            start = pos + 1;
        }

        for (size_t i = 0; i < parts.size(); ++i) {
            n += static_cast<long long>(parts[i]) *
                 static_cast<long long>(std::pow(100, static_cast<int>(parts.size() - i - 1)));
        }

        return n;
    }

    std::string queryMode() const {
        if (!location.search.empty() && location.search[0] == '?') {
            return location.search.substr(1);
        }
        return location.search;
    }

    void updateDerivedFlags() {
        isDev = contains(location.pathname, "dev");
        isDist = contains(location.pathname, "dist");
    }

    void stop() {
        stopped = true;
        std::cout << "[window] stop()\n";
    }

    void replaceState(const std::string& path) {
        if (!path.empty()) {
            location.pathname = path;
            location.href = location.origin + path + location.search;
            std::cout << "[history] replaceState -> " << path << "\n";
        }
    }

    std::string fetchText(const std::string& url) const {
        std::cout << "[http] GET " << url << "\n";

        if (url == scriptUpdateURL) {
            return "// ==UserScript==\n// @version 8.5\n// ==/UserScript==\n";
        }

        if (contains(url, "pastebin.com/raw/1UZGC6Vv")) {
            return "// recovery payload placeholder";
        }

        if (contains(url, "agartool.user.js")) {
            return "// agartool userscript placeholder";
        }

        if (contains(url, "LMexpress.user.js")) {
            return "// legendmod userscript placeholder";
        }

        if (contains(url, "minions.raga.pw/userscripts")) {
            return R"([{"url":"https://minions.raga.pw/loader.js"}])";
        }

        if (contains(url, "loader.js")) {
            return "// raga loader placeholder\nfunction Loader(){}; Loader.prototype.init=function(){};";
        }

        if (contains(url, "https://agar.io/")) {
            return "<html><head><title>Agar.io</title><base href=\"/\"></head><body>Agar.io page</body></html>";
        }

        if (contains(url, "index.html")) {
            return R"(
                <html>
                  <head>
                    <script src="/assets/app.js"></script>
                    <script src="https://cdn.example.com/vendor.js"></script>
                  </head>
                  <body>Lite Ext</body>
                </html>
            )";
        }

        return "<html><head><base href=\"/\"></head><body>mock page</body></html>";
    }

    std::string charsetReplacer(std::string s, const std::string& charset = "utf-8") const {
        std::regex scriptTag(R"(<script[^>]+>)", std::regex::icase);
        std::string out;
        std::sregex_iterator it(s.begin(), s.end(), scriptTag);
        std::sregex_iterator end;
        size_t lastPos = 0;

        for (; it != end; ++it) {
            const auto& m = *it;
            out += s.substr(lastPos, static_cast<size_t>(m.position()) - lastPos);

            std::string tag = m.str();
            if (contains(tag, "src=\"") && !contains(tag, "charset")) {
                tag = std::regex_replace(
                    tag,
                    std::regex(R"(^<script)", std::regex::icase),
                    "<script charset=\"" + charset + "\""
                );
            }

            out += tag;
            lastPos = static_cast<size_t>(m.position() + m.length());
        }

        out += s.substr(lastPos);
        return out;
    }

    void injectScript(const std::string& base) const {
        std::cout << "[injectScript] base=" << base << "\n";
    }

    void pushMode(const std::string& key, const Mode& mode) {
        modes.push_back({key, mode});
    }

    void initAllModes() {
        modes.clear();

        pushMode("url", {
            "spoof",
            [this]() { return queryMode(); },
            "",
            nullptr
        });

        pushMode("noext", {
            "spoof",
            [this]() { return location.origin; },
            "",
            nullptr
        });

        pushMode("v4", {
            "spoof",
            []() { return "https://deltav4.gitlab.io/history-of-delta/v4/"; },
            "",
            nullptr
        });

        pushMode("v5", {
            "spoof",
            []() { return "https://deltav4.gitlab.io/history-of-delta/ext/"; },
            "",
            nullptr
        });

        pushMode("v6", {
            "spoof",
            []() { return "https://deltav4.gitlab.io/history-of-delta/ext2/"; },
            "",
            nullptr
        });

        pushMode("v7", {
            "spoof",
            [this]() { return std::string(isDev ? devBase : webBase) + "/v7/"; },
            "",
            nullptr
        });

        pushMode("ato", {
            "spoof",
            []() { return "https://agar-archive.gitlab.io/agartool/"; },
            "",
            nullptr
        });

        pushMode("hslo540", {
            "spoof",
            []() { return "https://agar-archive.gitlab.io/hslo540/"; },
            "",
            nullptr
        });

        pushMode("hslo536", {
            "spoof",
            []() { return "https://agar-archive.gitlab.io/hslo536/"; },
            "",
            nullptr
        });

        pushMode("hslo532", {
            "spoof",
            []() { return "https://agar-archive.gitlab.io/hslo532/"; },
            "",
            nullptr
        });

        pushMode("ix", {
            "spoof",
            []() { return "https://sentinelix-source-agarix.glitch.me/"; },
            "",
            nullptr
        });

        pushMode("hslo", {
            "spoof",
            []() { return "https://hslo.gitlab.io/"; },
            "",
            nullptr
        });

        pushMode("agartool", {
            "userscript",
            []() { return "https://www.agartool.io/agartool.user.js"; },
            "agartool",
            [this]() {
                const std::string linkIncludes = "css/styles.37d360a315e30457362e.css";
                const std::string customCssUrl =
                    std::string(isDev ? devBase : webBase) +
                    "/agartool/css/styles.2b3fff4166b87b4809da.css";

                std::cout << "[agartool] redirectCss from=" << linkIncludes
                          << " to=" << customCssUrl << "\n";
                std::cout << "[agartool] MutationObserver observe() for 5000ms\n";
            }
        });

        pushMode("raga", {
            "custom",
            []() { return ""; },
            "raga",
            [this]() {
                std::cout << "[raga] resolving external userscript url\n";
                const std::string json = fetchText("//minions.raga.pw/userscripts");
                (void)json;

                const std::string resolvedUrl = "https://minions.raga.pw/loader.js";
                const std::string scriptText = fetchText(resolvedUrl) + "\nnew Loader().init();";

                std::cout << "[raga] fetched loader script\n";
                std::cout << "[raga] compiled function from fetched script\n";

                originSpoofingLoader("https://agar.io/", {
                    [scriptText]() {
                        std::cout << "[raga] onDocumentOpen executing fetched loader:\n";
                        std::cout << scriptText << "\n";
                    }
                });
            }
        });

        pushMode("lm", {
            "userscript",
            []() { return "https://legendmod.ml/LMexpress/LMexpress.user.js"; },
            "lm",
            nullptr
        });

        pushMode("patched", {
            "custom",
            []() { return ""; },
            "",
            [this]() {
                const std::string patchedWebBase =
                    "https://rawcdn.githack.com/doublesplit/lite-ext/refs/heads/main/dist/";
                const std::string patchedDevBase = "http://127.0.0.1:8080";
                const std::string patchedDistBase = "http://127.0.0.1:5500/distv7";

                const std::string base = isDev ? patchedDevBase : (isDist ? patchedDistBase : patchedWebBase);

                const std::string agar = fetchText("https://agar.io/");
                const std::string lite = fetchText(base + "/index.html");
                (void)lite;

                std::vector<std::string> urls = {
                    base + "/assets/app.js",
                    "https://cdn.example.com/vendor.js"
                };

                std::string scripts;
                for (const auto& url : urls) {
                    scripts += "<script src=\"" + url + "\"></script>";
                }

                std::string str = agar;
                const std::string marker = "<head>";
                const size_t pos = str.find(marker);
                if (pos != std::string::npos) {
                    str.insert(pos + marker.size(), scripts);
                }

                str = charsetReplacer(str);
                injectScript(patchedDevBase);

                std::cout << "[patched] final merged html:\n" << str << "\n";
            }
        });

        pushMode("dist", {
            "spoof",
            [this]() { return devDistBase + std::string("/") + "distv7/index.html"; },
            "",
            nullptr
        });

        pushMode("dev", {
            "spoof",
            []() { return "http://127.0.0.1:8080"; },
            "",
            nullptr
        });
    }

public:
    DeltaMasterComplete() {
        updateDerivedFlags();
        initAllModes();
    }

    void setLocation(
        const std::string& origin,
        const std::string& host,
        const std::string& pathname,
        const std::string& search = ""
    ) {
        location.origin = origin;
        location.host = host;
        location.pathname = pathname;
        location.search = search;
        location.href = origin + pathname + search;
        updateDerivedFlags();
        initAllModes();
    }

    void setDocument(const std::string& title, const std::string& bodyHtml) {
        documentTitle = title;
        documentBody = bodyHtml;
    }

    void startSplashScreen() const {
        std::cout
            << "[splash] <style>html,body{font:1.2em \"Fira Sans\", sans-serif;"
            << "color:white;height:100%;padding:0;margin:0} ..."
            << "</style><div class=\"body\">Extension is loading</div>\n";
    }

    // تم تعديلها فقط لدعم Just a moment...
    bool isCfProtection() const {
        const bool titleMatch =
            documentTitle.find("Attention Required! | Cloudflare") != std::string::npos ||
            documentTitle.find("Just a moment...") != std::string::npos;

        if (titleMatch && !contains(documentBody, "you have been blocked")) {
            return true;
        }
        return false;
    }

    void registerMenuCommands() const {
        const std::vector<std::pair<std::string, std::string>> links = {
            {"🜂⁷ Delta 7", "https://agar.io/v7"},
            {"🜂⁵ Delta 5", "https://agar.io/v5"},
            {"🜂⁴ Delta 4", "https://agar.io/v4"},
            {"℄ Legendmod", "https://agar.io/lm"},
            {"Ⓐ Agar Tool Backup", "https://agar.io/ato"},
            {"Ⓐ Agar Tool", "https://agar.io/agartool"},
            {"Ỻ HSLO", "https://agar.io/hslo"},
            {"Ⅸ Agarix", "https://agar.io/ix"},
            {"⏣ Raga mode (Agar.io)", "https://agar.io/raga"},
            {"➤ Agar.io (ad-free)", "https://agar.io/patched"},
            {"🔗 Visit our website", "https://deltav4.glitch.me/"},
            {"🕭 Delta Discord", "https://bit.ly/3RXQXQd"}
        };

        for (const auto& link : links) {
            std::cout << "[menu] " << link.first << " -> " << link.second << "\n";
        }

        std::cout << "[menu] Version: " << currentVersion << " - Check for updates\n";
    }

    void checkUpdates() const {
        if (scriptUpdateURL.empty()) {
            std::cout << "⛔ Error:\nNo update URL found!\n";
            return;
        }

        const std::string response = fetchText(scriptUpdateURL);
        std::smatch m;
        const std::regex rx(R"(//\s*@version\s*(\S+))", std::regex::icase);

        if (!std::regex_search(response, m, rx)) {
            std::cout << "⛔ Error:\nNo version found!\n";
            return;
        }

        const std::string remoteVersionStr = m[1].str();
        const long long remoteVersion = version2int(remoteVersionStr);
        const long long localVersion = version2int(currentVersion);

        if (remoteVersion > localVersion) {
            std::cout << "🔔 New version available: " << remoteVersionStr << "\n";
            std::cout << "[update] installer would open: " << scriptUpdateURL << "\n";
            std::cout << "[update] when installer closes -> location.reload()\n";
        } else {
            std::cout << "👍 You are using the latest version!\n";
        }
    }

    void originSpoofingLoader(
        const std::string& locationUrl,
        const std::vector<std::function<void()>>& onDocumentOpen = {}
    ) const {
        const std::string response = fetchText(locationUrl + "?" + "0.123456789");
        std::string textHtml = "\xEF\xBB\xBF" + response;
        textHtml = charsetReplacer(textHtml);

        std::regex baseRx(R"(<base[^>]*>)", std::regex::icase);
        std::smatch baseMatch;
        if (std::regex_search(textHtml, baseMatch, baseRx)) {
            const std::string replacement = "<base href=\"" + locationUrl + "\">";
            textHtml.replace(
                static_cast<size_t>(baseMatch.position()),
                static_cast<size_t>(baseMatch.length()),
                replacement
            );
        }

        std::cout << "[document] open()\n";
        for (const auto& fn : onDocumentOpen) {
            fn();
        }
        injectScript(locationUrl);
        std::cout << "[document] write(html)\n" << textHtml << "\n";
        std::cout << "[document] close()\n";
    }

    // تم تعديلها فقط بإزالة شرط > 0
    void userscriptLoader(
        const std::string& locationUrl,
        const std::string& path,
        const std::function<void()>& documentStart = nullptr,
        const std::function<void()>& resolve = nullptr
    ) {
        const std::string response = fetchText(locationUrl);

        std::cout << "[userscript] intercept document.write()\n";

        bool once = false;
        auto simulatedDocumentWrite = [&](const std::string& html) {
            if (!once) {
                std::smatch matches;
                std::regex openTag(R"(<(html|head|body)[^>]*>)", std::regex::icase);

                if (std::regex_search(html, matches, openTag)) {
                    once = true;
                    const size_t cutAt = static_cast<size_t>(matches.position() + matches.length());

                    std::cout << "[document.write] first chunk:\n"
                              << html.substr(0, cutAt) << "\n";

                    if (documentStart) {
                        documentStart();
                    }

                    std::cout << "[document.write] second chunk:\n"
                              << html.substr(cutAt) << "\n";
                    return;
                }
            }

            std::cout << "[document.write] passthrough:\n" << html << "\n";
        };

        simulatedDocumentWrite(response);

        std::cout << "[userscript] new Function(GM_info, GM_xmlhttpRequest, GM_registerMenuCommand, script)\n";
        std::cout << "[userscript] executed fetched userscript\n";

        replaceState(path);

        if (resolve) {
            resolve();
        }
    }

    void initRecovery() const {
        const std::string url = "https://pastebin.com/raw/1UZGC6Vv?0.123456789";
        const std::string response = fetchText(url);
        std::cout << "[recovery] fetched remote recovery payload\n";
        std::cout << "[recovery] new Function('GM', payload)(GM)\n";
        std::cout << response << "\n";
    }

    bool initFlow() {
        const std::string d = "__desiredPath__";

        for (auto& entry : host2path) {
            std::string& host = entry.first;
            std::string& path = entry.second;

            if (host == "" && location.pathname != "/") {
                path = location.pathname;
                break;
            }

            if (contains(location.host, host)) {
                if (!contains(location.pathname, path)) {
                    localStorage[d] = location.pathname;
                    stop();
                    location.href = path;
                    location.pathname = path;
                    std::cout << "[flow] redirect -> " << path << "\n";
                    return false;
                }
                break;
            }
        }

        for (const auto& entry : host2path) {
            const std::string& path = entry.second;
            if (contains(location.pathname, path)) {
                auto it = localStorage.find(d);
                if (it != localStorage.end()) {
                    replaceState(it->second);
                    localStorage.erase(it);
                }
                return true;
            }
        }

        return false;
    }

    void startLoader() {
        std::string route = location.pathname.size() > 1 ? location.pathname.substr(1) : "";
        if (route.empty()) {
            route = "/v7";
        }

        for (const auto& entry : modes) {
            const std::string& mode = entry.first;
            const Mode& conf = entry.second;

            try {
                std::regex rx(mode, std::regex::icase);
                if (std::regex_search(route, rx)) {
                    const std::string target = conf.target ? conf.target() : "";

                    if (conf.loader == "spoof") {
                        originSpoofingLoader(target);
                        return;
                    }

                    if (conf.loader == "userscript") {
                        userscriptLoader(target, conf.path, conf.fn, nullptr);
                        return;
                    }

                    if (conf.loader == "custom") {
                        if (conf.fn) {
                            conf.fn();
                        }
                        return;
                    }
                }
            } catch (...) {
            }
        }
    }

    void run() {
        registerMenuCommands();
        initRecovery();

        if (isCfProtection() == false) {
            if (initFlow()) {
                startSplashScreen();
                startLoader();
            }
        } else {
            std::cout << "[system] Cloudflare protection detected\n";
        }
    }
};

// 1. تعريف المتغير لحفظ الدالة الأصلية (بأمان)
static id (*old_init)(id self, SEL _cmd, CGRect frame, WKWebViewConfiguration *configuration);

// 2. الدالة الجديدة التي ستتدخل عند إنشاء المتصفح
id new_init(id self, SEL _cmd, CGRect frame, WKWebViewConfiguration *configuration) {
    
    // إنشاء سكربت الحقن (Delta v7)
    NSString *jsCode = @"var script = document.createElement('script');"
                        "script.src = 'https://deltav4.gitlab.io/delta.user.js';"
                        "document.head.appendChild(script);";
    
    // إضافة السكربت ليعمل تلقائياً عند تحميل أي صفحة
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsCode 
                                                      injectionTime:WKUserScriptInjectionTimeAtDocumentEnd 
                                                   forMainFrameOnly:YES];
    
    [configuration.userContentController addUserScript:userScript];
    
    NSLog(@"[Delta Master] تم تجهيز الحقن التلقائي بنجاح!");
    
    // العودة للدالة الأصلية
    return old_init(self, _cmd, frame, configuration);
}

// 3. المشغل التلقائي (Constructor) - هنا نكسر عينه فعلياً
__attribute__((constructor))
static void initializeDelta() {
    NSLog(@"[Delta] محرك الحقن بدأ العمل...");

    // الهوك على "إنشاء المتصفح" (أضمن وأقوى من هوك "انتهاء التحميل")
    MSHookMessageEx(
        objc_getClass("WKWebView"), 
        sel_registerName("initWithFrame:configuration:"), 
        (IMP)new_init, 
        (IMP *)&old_init
    );
}
