# 多语言框架

使用 Flutter 自带的 `gen-l10n`，入口为 `generated/app_localizations.dart`。

- `app_zh.arb`：简体中文模板，保存现有界面文案、资源键和占位符说明。
- `app_zh_CN.arb`：简体中文区域资源，继承模板文案，避免重复维护。
- `app_en.arb`：英语（beta），覆盖模板中的全部文案。
- `generated/`：生成的 Dart 文件，纳入版本控制，不直接编辑。
- `../../l10n.yaml`：生成配置；`en` 排在支持列表首位，作为不支持语言的回退。

设置 → 语言与翻译 → 界面语言，初始偏好为「跟随系统」。当前「跟随系统」、「简体中文」和「English (beta)」可选；繁體中文、日本語、Русский 仍显示为禁用项。「跟随系统」按系统语言匹配现有资源，不支持的系统语言及空语言列表回退到英语。尚未开放的语言不注册本地化资源。

`AppState.setUiLanguage` 将偏好保存为 `ui_language`，并通知应用入口更新 `MaterialApp.locale`。完全重置后恢复「跟随系统」。实际语言使用 Flutter 的 `basicLocaleListResolution` 解析，与应用支持列表保持一致。

翻译目标新增「跟随界面语言」，存储值为 `ui`；发起 Google / Microsoft / DeepL / OpenAI 兼容翻译前，通过 `resolvedTranslationTarget` 转为实际语言代码（英语为 `en`，简体中文为 `zh-CN`）。原有明确指定的翻译目标保持不变，重置后仍为 `zh-CN`。

界面、弹窗、通知及客户端错误提示已接入简体中文和英语资源。作品/曲目标题、搜索参数、歌词匹配词、正则、接口标识和语言原生名称保持原值。Rust/平台端自身生成的错误文本仍由其原有接口返回。

作品标签按界面语言显示：优先使用 one 接口的 `i18n` 译名，缺少的语言由 DLsite 官方批量标签接口补充；缺少对应译名时回退英语。没有任何译名的自建标签保留原名。卡片、详情、历史、黑名单与高级筛选共用 `TagNames`，搜索和黑名单仍使用原始标签名。下载记录、播放状态和历史保留译名，旧记录通过本地别名词表匹配，不需要在绘制或切换语言时请求网络。繁体、日语等标签映射已支持，不改变界面语言菜单的开放范围。

`tag_names_data.dart` 是公开元数据的本地快照；更新时在 `app` 目录运行 `python tool/update_tag_names.py`，再运行 `dart format lib/l10n/tag_names_data.dart`。来源为 `https://api.asmr.one/api/tags/` 与 `https://www.dlsite.com/maniax/fs/=/api_access/1`（通过 `locale` Cookie 选择语言），只提取标签名称和别名。

服务器健康检测使用 Flutter `AsyncSnapshot<int>` 保存等待、成功、失败和毫秒延迟；显示文案在构建时本地化，颜色按状态判断，不解析 Rust 返回的提示文字。延迟在 Dart 侧测量这次桥接请求的往返耗时。

后续接入文案时，在各 ARB 文件添加同名资源键，然后在 `app` 目录运行：

```sh
flutter pub get
flutter gen-l10n
```

在 `MaterialApp` 下方的组件中读取资源：

```dart
import 'package:kikoeta_app/l10n/strings.dart';

final l10n = context.l10n;
final name = l10n.appName;
```

没有 `BuildContext` 的服务使用 `appL10n`，与应用共享实际语言。异步操作在开始时保存 `final l10n = context.l10n`，避免等待后访问已销毁的界面。

新增语言时，先完成对应 ARB 的翻译和验证，再添加资源并重新生成，最后更新 `AppLanguage` 的可选偏好、Locale 映射及设置菜单的开放状态。生成器中的支持列表决定系统匹配范围，不要提前注册尚未完成的翻译。

带参数、复数等文案在模板 ARB 中定义占位符，使用生成的类型安全接口；配置已开启 ICU 转义，字面单引号使用 `''`，字面花括号使用 `'{'、'}'`。

回归检查（在 `app` 目录执行；仓库的 `test/` 规则忽略本地测试，因此此检查保存在 `checks/`）：

```sh
flutter test checks/localization_test.dart
flutter analyze lib checks/localization_test.dart
```
