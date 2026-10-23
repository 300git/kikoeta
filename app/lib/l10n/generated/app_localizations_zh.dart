// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Kikoeta';

  @override
  String get invertSelection => '反选';

  @override
  String get traditionalChinese => '繁体中文';

  @override
  String get home => '首页';

  @override
  String get favorites => '收藏';

  @override
  String get more => '更多';

  @override
  String get voiceActor => '声优';

  @override
  String get circle => '社团';

  @override
  String get tag => '标签';

  @override
  String get retry => '重试';

  @override
  String get advancedFilterPageBuildText => '高级筛选';

  @override
  String get advancedFilterPageBuildContentText => '暂无数据';

  @override
  String get advancedFilterPageBuildContentText2 => '没有匹配的参数';

  @override
  String advancedFilterPageBuildSearchFieldHintText(String placeholder) {
    return '搜索$placeholder…';
  }

  @override
  String get add => '添加';

  @override
  String get cancel => '取消';

  @override
  String get blacklistPageTypeLabelsTypeLabels => 'RJ号';

  @override
  String get blacklist => '黑名单';

  @override
  String get blacklistPageResultText => '添加黑名单';

  @override
  String get blacklistPageResultHintText => '要屏蔽的 RJ 号 / 名称';

  @override
  String get blacklistPageBuildText => '暂无黑名单条目\n黑名单中的作品不会出现在首页与搜索';

  @override
  String get local => '本地';

  @override
  String get network => '网络';

  @override
  String get password => '密码';

  @override
  String get dictationTranslationPageWorkCardTitle => '作品';

  @override
  String get username => '用户名';

  @override
  String get dictationTranslationPageWorkCardText => '取消任务';

  @override
  String get dictationTranslationPageInitStateText => '等待开始';

  @override
  String get dictationTranslationPageTestConnectionToast => '连接成功';

  @override
  String get dictationTranslationPageLogCardTitle => '运行日志';

  @override
  String get dictationTranslationPageStartUpdate => '任务失败';

  @override
  String get dictationTranslationPageBuildText => '听写翻译';

  @override
  String get dictationTranslationPageConnectionCardTitle => '服务连接';

  @override
  String get dictationTranslationPageConnectionCardInputDecoration => '服务地址';

  @override
  String get dictationTranslationPageConnectionCardTooltip => '显示密码';

  @override
  String get dictationTranslationPageConnectionCardTooltip2 => '隐藏密码';

  @override
  String get testConnection => '测试连接';

  @override
  String get dictationTranslationPageProgressCardTitle => '听写进度';

  @override
  String get dictationTranslationPageStartUpdate2 => '任务已排队';

  @override
  String get dictationTranslationPageStartUpdate3 => '任务已取消';

  @override
  String get dictationTranslationPageWorkCardTitle2 => '待处理音频';

  @override
  String get dictationTranslationPageWorkCardText2 => '正在取消…';

  @override
  String get dictationTranslationPageStartUpdate4 => '听写翻译完成';

  @override
  String get dictationTranslationPageSyncCachedResultsUpdate => '缓存同步完成';

  @override
  String get dictationTranslationPageConnectionCardText => '使用默认账密';

  @override
  String get dictationTranslationPageWorkCardText3 => '开始听写翻译';

  @override
  String get dictationTranslationPageStartUpdate5 => '正在写入歌词库';

  @override
  String dictationTranslationPageStartAppendLog(String error) {
    return '错误：$error';
  }

  @override
  String get dictationTranslationPageConnectionCardInputDecoration2 =>
      '本地服务地址（固定）';

  @override
  String get dictationTranslationPageConnectionCardText2 => '安卓设备仅支持网络连接';

  @override
  String dictationTranslationPageTestConnectionToast2(String error) {
    return '连接失败：$error';
  }

  @override
  String dictationTranslationPageCancelToast(String error) {
    return '取消失败：$error';
  }

  @override
  String get dictationTranslationPageConnectionCardText3 => '前往 GitHub 下载';

  @override
  String dictationTranslationPageSyncCachedResultsAppendLog(String error) {
    return '缓存同步失败：$error';
  }

  @override
  String dictationTranslationPageStartToast(String error) {
    return '听写翻译失败：$error';
  }

  @override
  String dictationTranslationPageSyncCachedResultsToast(String skipped) {
    return '，去重 $skipped 个';
  }

  @override
  String get dictationTranslationPageStartUpdate6 => '正在连接 kikoeta-transl';

  @override
  String get dictationTranslationPageStartException => 'kikoeta-transl 任务失败';

  @override
  String get dictationTranslationPageBuildTooltip => '同步 kikoeta-transl 缓存';

  @override
  String get dictationTranslationPageConnectionCardText4 =>
      '尚未安装 kikoeta-transl？';

  @override
  String get dictationTranslationPageTestConnectionFormatException =>
      'kikoeta-transl 服务未就绪';

  @override
  String get dictationTranslationPageLogCardSelectableText =>
      '等待 kikoeta-transl 日志…';

  @override
  String get dictationTranslationPageStartToast2 => '请从作品详情页的更多选项进入并启动听写翻译';

  @override
  String get dictationTranslationPageStartToast3 => '请返回作品详情页勾选需要听写翻译的媒体文件';

  @override
  String get dictationTranslationPageStartFormatException =>
      'kikoeta-transl 未返回任务编号';

  @override
  String get dictationTranslationPageOpenKikoetaTranslDownloadToast =>
      '无法打开 kikoeta-transl 项目页面';

  @override
  String get dictationTranslationPageServiceFormatException =>
      'kikoeta-transl 用户名不能包含冒号';

  @override
  String get dictationTranslationPageCancelAppendLog =>
      '已向 kikoeta-transl 发送取消请求';

  @override
  String get dictationTranslationPageServiceFormatException2 =>
      '请输入 kikoeta-transl 用户名和密码';

  @override
  String get dictationTranslationPageSyncCachedResultsToast2 =>
      'kikoeta-transl 没有可同步的缓存结果';

  @override
  String get dictationTranslationPageStartFormatException2 =>
      'kikoeta-transl 没有返回可用的 LRC 文件';

  @override
  String dictationTranslationPageProgressCardText(String savedFiles) {
    return ' · 已入库 $savedFiles';
  }

  @override
  String dictationTranslationPageStartToast4(String missing) {
    return '有 $missing 个音频缺少可下载地址，请登录作品服务器后重试';
  }

  @override
  String dictationTranslationPageStartAppendLog2(String jobId, String length) {
    return '任务 $jobId 已创建，共 $length 个音频';
  }

  @override
  String get dictationTranslationPageConnectionCardText5 =>
      '下载并启动 kikoeta-transl 后，即可使用本地或网络听写翻译。';

  @override
  String dictationTranslationPageSyncCachedResultsAppendLog2(
    String jobId,
    String name,
    String error,
  ) {
    return '同步 $jobId/$name 失败：$error';
  }

  @override
  String dictationTranslationPageSyncCachedResultsAppendLog3(
    String saved,
    String skipped,
    String failed,
  ) {
    return '缓存同步完成：写入 $saved，去重跳过 $skipped，失败 $failed';
  }

  @override
  String dictationTranslationPageSyncCachedResultsAppendLog4(String length) {
    return '开始同步 $length 条 kikoeta-transl 缓存任务';
  }

  @override
  String get dictationTranslationPageWorkCardText4 =>
      '要创建任务，请打开作品详情页，在右上角“更多”中选择“听写翻译”。未勾选文件时会自动匹配，优先选择无效果音版本并保留独立特典；也可先手动勾选指定文件。';

  @override
  String get dictationAutoSelectionHint =>
      '已自动匹配：优先无效果音，保留独立特典。请检查媒体列表；需要调整时，可返回作品页手动勾选。';

  @override
  String dictationTranslationPageStartAppendLog3(String rj, String savedFiles) {
    return '已按 $rj 写入 $savedFiles 个歌词文件';
  }

  @override
  String dictationTranslationPageWorkCardText5(String rj, String length) {
    return '$rj · 已从作品详情页勾选 $length 个媒体文件';
  }

  @override
  String dictationTranslationPageStartToast5(String savedFiles, String rj) {
    return '完成：$savedFiles 个歌词已写入 $rj 歌词库';
  }

  @override
  String dictationTranslationPageSyncCachedResultsToast3(
    String saved,
    String value,
  ) {
    return '同步完成：写入 $saved 个歌词$value';
  }

  @override
  String dictationTranslationPageProgressCardText2(
    String finishedFiles,
    String length,
    String value,
  ) {
    return '已处理 $finishedFiles / $length$value';
  }

  @override
  String get selectMultiple => '多选';

  @override
  String get selectAll => '全选';

  @override
  String get downloads => '下载';

  @override
  String get downloading => '下载中';

  @override
  String get downloadsPageStatusStatus => '等待中';

  @override
  String get downloadsPageStatusStatus2 => '已完成';

  @override
  String get downloadsPageStatusStatus3 => '已暂停';

  @override
  String get exitSelection => '退出多选';

  @override
  String get downloadsPageBuildTooltip => '关闭搜索';

  @override
  String get downloadsPageStatusStatus4 => '下载失败';

  @override
  String get downloadsPageStatusStatus5 => '等待下载';

  @override
  String get deselectAll => '取消全选';

  @override
  String get downloadsPageBuildText => '下载文件';

  @override
  String get downloadsPageBuildText2 => '暂无下载音声';

  @override
  String get downloadsPageBuildText3 => '完整文件结构';

  @override
  String get downloadsPageBuildTooltip2 => '删除选中作品';

  @override
  String get downloadsPageBuildText4 => '暂无下载文件';

  @override
  String get downloadsPageBuildTooltip3 => '搜索已下载作品';

  @override
  String get downloadsPageBuildTooltip4 => '开始/暂停全部';

  @override
  String get downloadsPageBuildTooltip5 => '删除选中下载记录';

  @override
  String get downloadsPageFileNameFileName => '暂无正在下载的文件';

  @override
  String downloadsPageProgressTextText(String percent) {
    return '下载中 $percent%';
  }

  @override
  String downloadsPageBuildText5(String value) {
    return '加载更多（$value）';
  }

  @override
  String downloadsPageBuildText6(String rj, String downloaded, String length) {
    return '$rj  $downloaded/$length 个文件已下载';
  }

  @override
  String downloadsPageStatusStatus6(String round) {
    return '下载中 $round%';
  }

  @override
  String get postponed => '搁置';

  @override
  String get remove => '移除';

  @override
  String get all => '全部';

  @override
  String get wantToListen => '想听';

  @override
  String get listening => '在听';

  @override
  String get listened => '听过';

  @override
  String get replay => '重听';

  @override
  String get favoritesPageReviewFilterButtonTooltip => '进度筛选';

  @override
  String get favoritesPageLabelLabel => '取消收藏';

  @override
  String get loading => '加载中…';

  @override
  String get favoritesPageReviewSortDropdownTooltip => '排序方式';

  @override
  String get favoritesPageReviewSortLabelsReviewSortLabels => '评论数量';

  @override
  String get favoritesPageBodyText => '点击重试';

  @override
  String get favoritesPageReviewSortLabelsReviewSortLabels2 => '销售数量';

  @override
  String get favoritesPageBuildTooltip => '切换歌单';

  @override
  String get favoritesPageReviewSortLabelsReviewSortLabels3 => '发布时间';

  @override
  String get favoritesPageReviewSortLabelsReviewSortLabels4 => '我的评价';

  @override
  String get favoritesPageReviewSortLabelsReviewSortLabels5 => '标记时间';

  @override
  String get ageRating => '年龄分级';

  @override
  String get favoritesPageInputText => '添加作品';

  @override
  String get favoritesPageBodyText2 => '已显示全部';

  @override
  String get favoritesPageLabelLabel2 => '移出播放列表';

  @override
  String get favoritesPagePlaylistHeaderActionsTooltip => '复制分享链接';

  @override
  String favoritesPageAddWorksByRjToast(String e) {
    return '添加失败：$e';
  }

  @override
  String get shareLinkCopied => '已复制分享链接';

  @override
  String get favoritesPageRemoveSelectedWorksToast => '无法获取作品编号';

  @override
  String get favoritesPageBodyText3 => '还没有收藏的作品';

  @override
  String favoritesPageRemoveCurrentLikedPlaylistToast(String e) {
    return '取消收藏失败：$e';
  }

  @override
  String get favoritesPagePlaylistHeaderActionsTooltip2 => '取消收藏该播放列表';

  @override
  String get favoritesPageBodyText4 => '该播放列表还没有作品';

  @override
  String get favoritesPagePlaylistHeaderActionsTooltip3 => '按 RJ 号添加作品';

  @override
  String get favoritesPageAddWorksByRjToast2 => '没有识别到 RJ 号';

  @override
  String favoritesPageSelectionBarText(String count) {
    return '已选 $count 项';
  }

  @override
  String favoritesPageRemoveSelectedWorksToast2(String label, String e) {
    return '$label失败：$e';
  }

  @override
  String get favoritesPageBodyText5 => 'SFW 模式下不显示收藏内容';

  @override
  String get favoritesPageBodyText6 => '加载失败，请确认已在设置中登录';

  @override
  String get favoritesPageOkText => '确定从我的播放列表中移除该歌单吗？';

  @override
  String favoritesPageAddWorksByRjToast3(String length) {
    return '已添加 $length 个作品';
  }

  @override
  String favoritesPageOkText2(String count, String label) {
    return '确定将 $count 个作品$label吗？';
  }

  @override
  String favoritesPageRemoveSelectedWorksToast3(String label, String length) {
    return '已$label $length 个作品';
  }

  @override
  String get favoritesPageInputHintText =>
      '输入 RJ 号，可一次填多个\n例如：RJ01367541 RJ01417842\n支持换行、空格或逗号分隔';

  @override
  String get clear => '清空';

  @override
  String get historyPageEntryWorkTitle => '未知作品';

  @override
  String get playHistory => '播放历史';

  @override
  String get historyPageBuildText => '暂无播放历史';

  @override
  String get historyPageBuildText2 => 'SFW 模式下不显示播放历史';

  @override
  String historyPageFmtTimeText(String padLeft, String padLeft2) {
    return '今天 $padLeft:$padLeft2';
  }

  @override
  String historyPageFmtTimeText2(
    String month,
    String day,
    String padLeft,
    String padLeft2,
  ) {
    return '$month月$day日 $padLeft:$padLeft2';
  }

  @override
  String get homePageServerLabelText => '自建';

  @override
  String get homePageLabelsLabels => '热门';

  @override
  String get homePageLabelsLabels2 => '推荐';

  @override
  String get homePageSortLabelsSortLabels => '总评价';

  @override
  String get homePageSortLabelsSortLabels2 => '收录时间';

  @override
  String get homePageSortLabelsSortLabels3 => '销售价格';

  @override
  String get homePageEmptyHintText => '暂无作品';

  @override
  String get homePageSearchResultsViewText => '搜索中…';

  @override
  String get homePageEmptyHintText2 => '正在加载…';

  @override
  String get homePageGridText => '已显示全部作品';

  @override
  String get homePageEmptyHintText3 => '点击任意处重试';

  @override
  String get homePageSearchResultsViewText2 => '没有找到相关作品';

  @override
  String get homePageSearchResultsViewText3 => '已显示全部搜索结果';

  @override
  String get homePageEmptyHintText4 => '当前筛选条件下暂无作品';

  @override
  String get homePageEmptyHintText5 => '无网络连接，请检查网络或服务器设置';

  @override
  String get homePageHeaderTooltip => 'SFW 模式已开启：仅显示全年龄内容';

  @override
  String get homePageHeaderTooltip2 => '开启 SFW 模式（仅显示全年龄内容）';

  @override
  String get save => '保存';

  @override
  String get loginPageBuildLoginText => '登 录';

  @override
  String get loginPageShowNoAccountText => '关于账号';

  @override
  String get loginPageShowNoAccountText2 => '我知道了';

  @override
  String get loginPageBuildSiteConfigTooltip => '返回登录';

  @override
  String get loginPageBuildSiteConfigText => '已有站点';

  @override
  String get loginPageBuildSiteConfigHint => '站点密码';

  @override
  String get loginPageShowProxyDialogLabelText => '代理服务器';

  @override
  String get loginPageBuildLoginText2 => '我没有账号';

  @override
  String get loginPageBuildSiteConfigText2 => '使用该站点';

  @override
  String get loginPageBuildSiteConfigText3 => '添加新站点';

  @override
  String get loginPageBuildSiteConfigText4 => '保存并进入';

  @override
  String get loginPageShowProxyDialogText => '配置网络代理';

  @override
  String get loginPageBuildLoginText3 => '配置自建站点';

  @override
  String get loginPageBuildSiteConfigHint2 => '站点登录账号';

  @override
  String get loginPageShowProxyDialogToast => '网络代理已启用';

  @override
  String get loginPageShowProxyDialogToast2 => '网络代理已关闭';

  @override
  String get loginPageBuildLoginHint => 'one 站账号';

  @override
  String get loginPageLoginToast => '请输入账号和密码';

  @override
  String get loginPageLoginToast2 => '请检查网络或账号密码';

  @override
  String get loginPageShowProxyDialogText2 => '使用 HTTP 代理';

  @override
  String get loginPageBuildLoginText4 => '登录 one 站账号';

  @override
  String get loginPageShowProxyDialogHelperText => '仅支持 HTTP 代理';

  @override
  String get loginPageBuildSiteConfigHint3 => '别名，如：家庭 NAS';

  @override
  String get loginPageSaveNewSiteToast => '请填写别名、地址、账号和密码';

  @override
  String get loginPageShowProxyDialogHintText => '例如 http://代理地址:端口';

  @override
  String get loginPageBuildSiteConfigText5 =>
      '支持 IP+端口，如 http://192.168.1.100:3000';

  @override
  String loginPageLoginToast3(String value) {
    return '登录失败：$value';
  }

  @override
  String get loginPageShowNoAccountText3 =>
      '本项目不提供任何注册服务。\n\n账号与密码需要您自行获取，本项目不提供任何获取渠道。\n\n您使用该账号在本应用中获取、播放的任何内容，其所有权与责任均归属内容提供方与账号持有人，本项目对此不承担任何责任。\n\n账号信息仅保存在本地设备，不会上传到任何第三方服务器。';

  @override
  String get close => '关闭';

  @override
  String get delete => '删除';

  @override
  String get remote => '远程';

  @override
  String get continueAction => '继续';

  @override
  String get online => '在线';

  @override
  String get importAction => '导入';

  @override
  String get lyricsLibraryPageBuildNavItem => '远程库';

  @override
  String get lyricsLibrary => '歌词库';

  @override
  String get lyricsLibraryPageBuildNavItem2 => '本地文件';

  @override
  String get lyricsLibraryPageProceedText => '继续导入';

  @override
  String get lyricsLibraryPageImportText => '取消导入';

  @override
  String get lyricsLibraryPageProgressPhase => '准备导入';

  @override
  String get lyricsLibraryPageOkText => '深度刷新';

  @override
  String get lyricsLibraryPageOkText2 => '删除歌词';

  @override
  String get lyricsLibraryPageSectionContentText => '选择文件夹';

  @override
  String get lyricsLibraryPageConfirmedText => '删除远程库';

  @override
  String get lyricsLibraryPageSectionContentText2 => '导入远程库';

  @override
  String get lyricsLibraryPageBuildText => '导入歌词库';

  @override
  String get lyricsLibraryPageBuildLabel => '刷新歌词库';

  @override
  String get lyricsLibraryPageBuildTooltip => '搜索歌词库';

  @override
  String get lyricsLibraryPageBuildText2 => '正在导入歌词';

  @override
  String get lyricsLibraryPageImportText2 => '跳过冲突文件';

  @override
  String get lyricsLibraryPageImportText3 => '覆盖冲突文件';

  @override
  String get lyricsLibraryPageOkText3 => '移除远程作品';

  @override
  String get lyricsLibraryPageProceedText2 => '大型内容导入';

  @override
  String get lyricsLibraryPageImportText4 => '发现导入冲突';

  @override
  String get lyricsLibraryPageRemoteSourceListTooltip => '只刷新此远程库';

  @override
  String get lyricsLibraryPageOkText4 => '删除歌词库作品';

  @override
  String get lyricsLibraryPageBuildLabel2 => '刷新全部远程库';

  @override
  String get lyricsLibraryPageBuildText3 => '正在准备文件…';

  @override
  String get lyricsLibraryPageSelectionDialogTitle => '选择歌词文件夹';

  @override
  String get lyricsLibraryPageSectionContentText3 => '正在连接并同步';

  @override
  String get lyricsLibraryPageSearchFieldHintText => '搜索作品 ID';

  @override
  String lyricsLibraryPageImportText5(String e) {
    return '导入失败：$e';
  }

  @override
  String get lyricsLibraryPageRemoteSourceListText => '尚未导入远程库';

  @override
  String get lyricsLibraryPageBuildHint => '长按执行深度刷新';

  @override
  String get lyricsLibraryPageBuildText4 => '正在统计歌词文件';

  @override
  String get lyricsLibraryPageScanProgressPhase => '正在检查文件冲突';

  @override
  String get lyricsLibraryPageResultDialogTitle => '选择 ZIP 文件';

  @override
  String get lyricsLibraryPageSectionContentText4 => '选择 ZIP 压缩包';

  @override
  String get lyricsLibraryPageBuildText5 => '暂时无法统计歌词文件';

  @override
  String lyricsLibraryPageRefreshText(String error) {
    return '刷新失败：$error';
  }

  @override
  String get lyricsLibraryPageShowFilesText => '没有可用的歌词或字幕文件';

  @override
  String get lyricsLibraryPageBuildText6 => '暂无数据，点击右上角导入';

  @override
  String get lyricsLibraryPageShowFilesText2 => '加载歌词文件失败，请重试';

  @override
  String lyricsLibraryPageReorderSetState(String error) {
    return '调整优先级失败：$error';
  }

  @override
  String get lyricsLibraryPageSectionContentLabelText => 'HTTP / HTTPS 地址';

  @override
  String get lyricsLibraryPageBuildHint2 => '同步所有已导入远程库的作品索引';

  @override
  String get lyricsLibraryPageImportText6 => '所选文件夹里没有歌词或字幕文件';

  @override
  String get lyricsLibraryPageSectionContentText5 => '选择要导入的歌词文件或压缩包。';

  @override
  String get lyricsLibraryPageSectionContentText6 => '输入开启了歌词库广播的设备地址。';

  @override
  String lyricsLibraryPageRefreshOneSetState(String url, String error) {
    return '刷新 $url 失败：$error';
  }

  @override
  String lyricsLibraryPageRemoveRemoteLibrarySetState(
    String url,
    String error,
  ) {
    return '删除 $url 失败：$error';
  }

  @override
  String lyricsLibraryPageBuildText7(String directoryCount) {
    return '$directoryCount 个目录';
  }

  @override
  String lyricsLibraryPageBuildText8(String length) {
    return '$length 个';
  }

  @override
  String get lyricsLibraryPageBuildText9 => '暂无远程作品，点击右上角导入并连接远程库';

  @override
  String lyricsLibraryPageOkText5(String workId) {
    return '确定移除 $workId 的远程作品索引吗？';
  }

  @override
  String lyricsLibraryPageOkText6(String workId) {
    return '确定删除 $workId 的全部歌词文件吗？';
  }

  @override
  String get lyricsLibraryPageOkText7 => '将删除没有歌词或字幕文件的作品目录，是否继续？';

  @override
  String get lyricsLibraryPageSectionContentText7 => '已导入的远程库（从上到下优先级递减，拖动排序）';

  @override
  String lyricsLibraryPageRemoteSourceListText2(String value) {
    return '优先级 $value · 长按删除';
  }

  @override
  String lyricsLibraryPageConfirmedText2(String url) {
    return '确定移除远程库 $url 及其已同步的作品索引吗？';
  }

  @override
  String get lyricsLibraryPageSectionContentText8 =>
      '导入时只同步作品索引；播放时再下载该作品的全部歌词。';

  @override
  String get lyricsLibraryPageProceedText3 =>
      '检测到大型压缩包或文件夹，导入过程可能需要较长时间，请耐心等待。';

  @override
  String lyricsLibraryPageOkText8(String length) {
    return '确定删除选中的 $length 个作品目录吗？';
  }

  @override
  String lyricsLibraryPageImportText7(String length) {
    return '检测到 $length 个已存在文件，如何处理？';
  }

  @override
  String lyricsLibraryPageOkText9(String length) {
    return '确定移除选中的 $length 个远程作品索引吗？';
  }

  @override
  String lyricsLibraryPageBuildText10(String fileCount, String value) {
    return '$fileCount 个歌词/字幕文件 · $value';
  }

  @override
  String get morePageBuildRow => '歌单';

  @override
  String get settings => '设置';

  @override
  String get morePageBuildRow2 => '随心听';

  @override
  String morePageBuildText(String server) {
    return '服务器：$server';
  }

  @override
  String get morePageOpenRandomWorkText => '当前条件下没有可播放的作品';

  @override
  String get morePageOpenRandomWorkText2 => '随心听加载失败，请稍后重试';

  @override
  String get playerPageShowLyricSettingsText => '归零';

  @override
  String get back => '返回';

  @override
  String get seekBackward => '快退';

  @override
  String get seekForward => '快进';

  @override
  String get playerPageUtilsUtil => '定时';

  @override
  String get equalizer => '均衡器';

  @override
  String get playerPageUtilsUtil2 => '定时中';

  @override
  String get playerPageShowLyricSettingsText2 => '繁简互转';

  @override
  String get autoMatch => '自动匹配';

  @override
  String get workDetails => '作品详情';

  @override
  String get playlist => '播放列表';

  @override
  String get sleepTimer => '定时关闭';

  @override
  String get playerPageWideLyricsPanelText => '暂无歌词';

  @override
  String get playerPageTopBarText => '正在播放';

  @override
  String get desktopLyrics => '桌面歌词';

  @override
  String get playerPagePlayModeLabelText => '循环播放';

  @override
  String get playerPagePlayModeLabelText2 => '单曲循环';

  @override
  String get playerPagePlayModeLabelText3 => '列表播放';

  @override
  String get playerPageShowLyricSettingsText3 => '歌词设置';

  @override
  String get playerPageShowLyricSettingsText4 => '字幕偏移';

  @override
  String get simplifiedToTraditional => '简 → 繁';

  @override
  String get traditionalToSimplified => '繁 → 简';

  @override
  String get playerPageShowQueueText => '播放列表为空';

  @override
  String get playerPageResDialogTitle => '选择歌词文件';

  @override
  String get playerPagePickOnlineLyricText => '选择在线歌词';

  @override
  String get playerPageBuildText => '暂无播放内容';

  @override
  String get playerPageShowLyricSettingsTitle => '选择离线歌词';

  @override
  String get playerPagePickOnlineLyricToast => '未找到在线歌词';

  @override
  String get playerPageShowLyricSettingsTitle2 => '选择歌词库歌词';

  @override
  String get playerPageLoadOnlineLyricToast => '该歌词无法解析';

  @override
  String get playerPageLyricsPanelText => '正在加载歌词…';

  @override
  String get playerPageNextToast => '已播放完播放列表';

  @override
  String get playerPageOpenCurrentToast => '文件流需登录后可用';

  @override
  String get playerPageShowLyricSettingsSub => '歌词库中没有该作品';

  @override
  String get playerPageOpenMediaToast => '打开媒体超时，请重试';

  @override
  String get playerPageLibraryAutoTileText => '从歌词库自动匹配歌词';

  @override
  String get playerPageOpenMediaToast2 => '打开失败，正在重试…';

  @override
  String get playerPageFriendlyPlayErrorText => '媒体流代理异常，请重试';

  @override
  String get playerPageVolumeControlTooltip => '响度提升（上限 120）';

  @override
  String get playerPageShowLyricSettingsSub2 => '从本地选择歌词或字幕文件';

  @override
  String get playerPageInitStateToast => '网络波动，正在自动重连…';

  @override
  String get playerPagePickLibraryLyricToast => '歌词库中没有该作品的歌词';

  @override
  String get playerPageOpenMediaToast3 => '打开媒体超时，正在重试…';

  @override
  String get playerPageShowLyricSettingsSub3 => '仅显示当前作品的歌词文件';

  @override
  String get playerPageCheckSleepToast => '已停止播放，系统接口已释放';

  @override
  String get playerPagePickOnlineLyricSub => '按曲目名与中文优先自动选择';

  @override
  String get playerPageFriendlyPlayErrorText2 => '服务器返回错误，请稍后重试';

  @override
  String get playerPageVolumeControlTooltip2 => '启用响度提升（上限 120）';

  @override
  String get playerPageFriendlyPlayErrorText3 => '登录已失效，请重新登录后重试';

  @override
  String get playerPagePickOfflineLyricToast => '文件中没有可读取的带时间轴歌词';

  @override
  String get playerPageFriendlyPlayErrorText4 => '无法连接媒体流，请检查网络后重试';

  @override
  String get playerPageVolumeControlTooltip3 => '响度提升 Plus（上限 200）';

  @override
  String get playerPageToggleDesktopLyricsToast => '未授予悬浮窗权限，桌面歌词无法显示';

  @override
  String playerPageSeekCircleMessage(String label, String seconds) {
    return '$label $seconds 秒';
  }

  @override
  String get playerPageLibraryAutoTileText2 => '优先匹配本地歌词，找不到时使用在线歌词';

  @override
  String playerPageShowQueueText2(String length) {
    return '播放列表（$length）';
  }

  @override
  String playerPageInitStateToast2(String friendlyPlayError) {
    return '播放失败：$friendlyPlayError';
  }

  @override
  String playerPageOpenMediaToast4(String friendlyPlayError) {
    return '无法打开媒体流：$friendlyPlayError';
  }

  @override
  String get playlistsPageNameText => '创建';

  @override
  String get playlistsPageBuildText => '重命名';

  @override
  String get playlistsPageBuildText2 => '新建歌单';

  @override
  String get playlistsPageNameHintText => '歌单名称';

  @override
  String get playlistsPageBuildText3 => '歌单为空';

  @override
  String get playlistsPageHeaderTooltip => '移除作品';

  @override
  String get playlistsPageNameText2 => '重命名歌单';

  @override
  String get playlistsPageHeaderMessage => '拖动调整作品顺序';

  @override
  String get playlistsPageRowMessage => '拖动调整播放顺序';

  @override
  String get playlistsPagePlayTrackText => '歌单中没有可播放的音频';

  @override
  String get playlistsPageBuildText4 => 'SFW 模式下不显示歌单';

  @override
  String get playlistsPageBuildText5 => '暂无歌单，点击右下角新建';

  @override
  String get playlistsPageBuildText6 => 'SFW 模式下不显示歌单内容';

  @override
  String playlistsPageBuildText7(String length) {
    return '$length 个条目';
  }

  @override
  String get playlistsPagePlayTrackText2 => '该音频缺少可用文件流，请从作品详情重新添加';

  @override
  String get playlistsPageBuildText8 => '拖动标题调整作品顺序，拖动媒体调整播放顺序';

  @override
  String get playlistsPageBuildText9 => '长按标题调整作品顺序，长按媒体调整播放顺序';

  @override
  String playlistsPageHeaderText(String length) {
    return '$length 个音频';
  }

  @override
  String get traditionalChineseShort => '繁中';

  @override
  String get englishLanguage => '英语';

  @override
  String get simplifiedChineseShort => '简中';

  @override
  String get settingsPageHealthBadgeStartsWith => '正常';

  @override
  String get settingsPageSectionsMiniBtn => '检测';

  @override
  String get settingsPageSectionsMiniBtn2 => '配置';

  @override
  String get settingsPageLockRowText => '解锁';

  @override
  String get play => '播放';

  @override
  String get lyrics => '歌词';

  @override
  String get settingsPageSectionsSection => '曲目';

  @override
  String get settingsPageOnVersionTapText => '好吧';

  @override
  String get settingsPageSectionsSection2 => '其他';

  @override
  String get settingsPageSectionsSection3 => '外观';

  @override
  String get settingsPageSectionsText => '主题';

  @override
  String get settingsPageSectionsText2 => '浅色';

  @override
  String get settingsPageSectionsText3 => '深色';

  @override
  String get settingsPageSectionsText4 => '重置';

  @override
  String get settingsPageSectionsSection4 => '关于';

  @override
  String get settingsPageSectionTitleText => '隐私';

  @override
  String get settingsPageSectionsTitle => '版本';

  @override
  String get settingsPageSectionsTitle2 => '仓库';

  @override
  String get settingsPageLockRowSub => '未锁定';

  @override
  String get settingsPageSectionsMiniBtn3 => '去关闭';

  @override
  String get settingsPageShortcutConflictText => '下一曲';

  @override
  String get settingsPageShortcutConflictText2 => '上一曲';

  @override
  String get settingsPageSectionsLockRow => '桌面端';

  @override
  String get settingsPageSectionsMiniBtn4 => '已关闭';

  @override
  String get settingsPageShortcutLabelText => '未设置';

  @override
  String get translationEngine => '翻译引擎';

  @override
  String get settingsPageSectionsLabel => '字体颜色';

  @override
  String get settingsPageSectionsLabel2 => '描边颜色';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get settingsPageAutoCheckSetState => '检测中…';

  @override
  String get settingsPageSectionsTitle3 => '快退秒数';

  @override
  String get interfaceLanguage => '界面语言';

  @override
  String get settingsPageSectionsTitle4 => '快进秒数';

  @override
  String get settingsPageAiModelInputLabelText => '模型名称';

  @override
  String get settingsPageShortcutLabelText2 => '方向键→';

  @override
  String get chineseConversion => '繁简转换';

  @override
  String get settingsPageSectionsText5 => '描边宽度';

  @override
  String get settingsPageSectionsSection5 => '账号设置';

  @override
  String get settingsPageSectionsText6 => '字体大小';

  @override
  String get settingsPageShortcutLabelText3 => '方向键←';

  @override
  String get settingsPageBuildText => '完全重置';

  @override
  String get settingsPageSectionsSwitchRow => '智能路径';

  @override
  String get settingsPageAutoCheckSetState2 => '连接失败';

  @override
  String get followSystem => '跟随系统';

  @override
  String get settingsPageOpenRepoToast => '打开失败';

  @override
  String get settingsPageEditAudioTypePreferenceText => '恢复默认';

  @override
  String get settingsPageSectionsText7 => '界面缩放';

  @override
  String get settingsPageBuildText2 => '确定重置';

  @override
  String get settingsPageSectionsTitle5 => '检查更新';

  @override
  String get targetLanguage => '目标语言';

  @override
  String get languageAndTranslation => '语言与翻译';

  @override
  String get settingsPageSectionsSwitchRow2 => '歌词库广播';

  @override
  String get settingsPageSectionsSwitchRow3 => '剪贴板检测';

  @override
  String get settingsPageShortcutConflictText3 => '播放/暂停';

  @override
  String get settingsPageSectionsTitle6 => '快退快捷键';

  @override
  String get settingsPageSectionsSwitchRow4 => '效果音偏好';

  @override
  String get settingsPageSectionsTitle7 => '快进快捷键';

  @override
  String get settingsPageOnVersionTapText2 => '开发者模式';

  @override
  String get settingsPageSectionsSub => '未配置账号';

  @override
  String get settingsPageRowSub => '点击进入设置';

  @override
  String get settingsPageSectionsTitle8 => '音频类型偏好';

  @override
  String get settingsPageSectionsText8 => '检测模型列表';

  @override
  String get settingsPageProxySettingsTooltip => '清空代理地址';

  @override
  String get settingsPageSectionsTitle9 => '上一曲快捷键';

  @override
  String get settingsPageSectionsTitle10 => '关闭省电优化';

  @override
  String get settingsPageSectionsSwitchRow5 => '忽略音频焦点';

  @override
  String get settingsPageSectionsSwitchRow6 => '自动检测更新';

  @override
  String get settingsPageMediaCacheLimitRowText => '媒体缓存上限';

  @override
  String get settingsPageSectionsTitle11 => '下一曲快捷键';

  @override
  String get translationTargetLanguage => '翻译目标语言';

  @override
  String get followInterfaceLanguage => '跟随界面语言';

  @override
  String get settingsPageSectionsText9 => '添加自建站点';

  @override
  String get settingsPageSectionsLockRow2 => '安卓（横屏）';

  @override
  String get settingsPageSectionsLockRow3 => '安卓（竖屏）';

  @override
  String get settingsPageSectionsTitle12 => '完全重置软件';

  @override
  String get settingsPageProxySettingsSwitchRow => 'HTTP 代理';

  @override
  String get settingsPageAiModelInputTooltip => '选择已检测模型';

  @override
  String get settingsPageSectionsTitle13 => '恢复默认快捷键';

  @override
  String get settingsPageSectionsSwitchRow7 => '不记忆播放进度';

  @override
  String get settingsPageSectionsSection6 => '歌词与桌面歌词';

  @override
  String settingsPageSectionsToast(String e) {
    return '连接失败：$e';
  }

  @override
  String get settingsPageSectionsToast2 => '正在检测连接…';

  @override
  String get settingsPageSectionsSwitchRow8 => '拔出耳机自动暂停';

  @override
  String get settingsPageSectionsTitle14 => '播放/暂停快捷键';

  @override
  String get settingsPageSectionsSub2 => '手动请求更新服务';

  @override
  String get settingsPageSectionsSwitchRow9 => '最顶层悬浮歌词窗';

  @override
  String get settingsPageAiModelInputTooltip2 => '请先检测模型列表';

  @override
  String get settingsPageProxySettingsHelperText => '留空将不使用代理';

  @override
  String get settingsPageLabelsLabels => 'OpenAI 兼容';

  @override
  String get settingsPageSectionsSwitchRow10 => '关闭窗口后保留托盘';

  @override
  String get settingsPageDetectOpenAiModelsToast => '正在获取模型列表…';

  @override
  String get settingsPageSectionsSwitchRow11 => '不显示通知栏媒体卡片';

  @override
  String get settingsPageSectionsSub3 => '歌词中文部分自动转换';

  @override
  String get sourceAndTargetLanguage => '源语言 / 目标语言';

  @override
  String get settingsPageDetectOpenAiModelsToast2 => '请先填写 API 地址';

  @override
  String get settingsPageSectionsSwitchRow12 => '定时关闭后释放系统接口';

  @override
  String get settingsPagePlaybackShortcutRowSub => '播放器页获得焦点时生效';

  @override
  String get settingsPageAiModelInputHintText => '输入模型名或从列表选择';

  @override
  String get settingsPageSectionsSub4 => '防止后台播放被系统中断';

  @override
  String get settingsPageStatusStatus => '已保存地址，开启后生效';

  @override
  String settingsPageLockRowTitle(String label) {
    return '$label 歌词锁定';
  }

  @override
  String settingsPageDetectOpenAiModelsToast3(String e) {
    return '模型列表获取失败：$e';
  }

  @override
  String get settingsPageSectionsToast3 => '正在检测 DeepL…';

  @override
  String get settingsPageSectionsSwitchRow13 => '优先进入包含效果音的目录';

  @override
  String settingsPageSectionsToast4(String e) {
    return '关闭歌词库广播失败：$e';
  }

  @override
  String settingsPageSectionsToast5(String e) {
    return '无法开启歌词库广播：$e';
  }

  @override
  String get settingsPageSectionsSwitchRow14 => '打开作品自动进入最佳目录';

  @override
  String settingsPageSectionsToast6(String e) {
    return 'DeepL 连接失败：$e';
  }

  @override
  String get settingsPageSectionsSwitchRow15 => '自动识别复制的 RJ 链接';

  @override
  String get settingsPageSectionsSwitchRow16 => '到点清除锁屏媒体卡片与通知';

  @override
  String get settingsPageSectionsSwitchRow17 => '启动后 3 秒请求更新服务';

  @override
  String settingsPageSectionsToast7(String r) {
    return 'DeepL 连接正常：$r';
  }

  @override
  String get settingsPageOnVersionTapText3 => '你不会真以为有开发者模式吧？';

  @override
  String get settingsPageProxySettingsHelperText2 => '开启 HTTP 代理后可编辑';

  @override
  String get settingsPageSectionsSwitchRow18 => '拔出耳机或断开蓝牙时自动暂停';

  @override
  String get settingsPageSectionsSwitchRow19 => '与其他应用同时播放，互不打断';

  @override
  String get settingsPageSectionsSwitchRow20 => '播放时不在通知栏显示媒体卡片';

  @override
  String get settingsPageAiModelInputHintText2 => '例如 gpt-4o-mini';

  @override
  String get settingsPageSectionsSwitchRow21 => '通知栏封面显示项目 logo';

  @override
  String settingsPageBuildText3(String count) {
    return '确定重置（$count 秒）';
  }

  @override
  String get settingsPageSectionsSub5 => '清除本机全部数据，恢复初始状态';

  @override
  String get settingsPageSectionsSub6 => '5–60 秒，每次调整 5 秒';

  @override
  String settingsPageEditPlaybackShortcutToast(String conflict) {
    return '该按键已用于$conflict';
  }

  @override
  String get settingsPageDetectOpenAiModelsFormatException => '响应未包含 data[].id';

  @override
  String get settingsPageSectionsInput => 'API Key（本地服务可留空）';

  @override
  String get settingsPageConfirmResetText => '已重置：账号与全部本地数据已清除';

  @override
  String get settingsPageRequestBatteryIgnoreToast => '请在系统设置中允许「忽略电池优化」';

  @override
  String get settingsPageStatusStatus2 => '已启用，请填写 HTTP 代理地址';

  @override
  String get settingsPageMediaCacheLimitRowText2 => '仅限制在线播放缓冲，不影响下载功能';

  @override
  String get settingsPageSectionsSwitchRow22 => '关闭窗口时将停止后台运行并退出程序';

  @override
  String get settingsPageSectionsSub7 => '已加入白名单，后台播放不受省电限制';

  @override
  String get settingsPageSectionsInput2 => 'API 地址 (Base URL)';

  @override
  String get settingsPageSectionsInput3 => 'DeepL 免费版 API Key';

  @override
  String settingsPageSectionsSub8(String asmrUser) {
    return '账号：$asmrUser';
  }

  @override
  String get settingsPageSectionsSwitchRow23 => '关闭后继续在后台播放，可从系统托盘恢复';

  @override
  String get settingsPageSectionsSwitchRow24 => '重启程序后恢复上次曲目，但从头开始播放';

  @override
  String get settingsPageSectionsSwitchRow25 => '只读 API 服务 · 端口 2377';

  @override
  String get settingsPageLockRowSub2 => '已锁定：点击歌词不会响应，可在设置中解锁';

  @override
  String get settingsPageStatusStatus3 => '仅支持 HTTP 协议代理，对所有网络请求生效';

  @override
  String get settingsPageSectionsSwitchRow26 => '开启后封面位置显示项目 logo，不显示真实封面';

  @override
  String settingsPageDetectOpenAiModelsToast4(String length) {
    return '已获取 $length 个模型';
  }

  @override
  String settingsPageOnVersionTapToast(String value) {
    return '再执行 $value 步进入开发者模式';
  }

  @override
  String settingsPageStatusStatus4(String trim) {
    return '已启用：$trim';
  }

  @override
  String get settingsPageSectionsInput4 => '在 deepl.com 免费注册后获取（api-free）';

  @override
  String get settingsPageSectionsSub9 => 'Space / PageUp / PageDown / 方向键←→';

  @override
  String settingsPageAiModelInputHelperText(String length) {
    return '已检测到 $length 个模型';
  }

  @override
  String get settingsPageSectionsSub10 =>
      'Google / Microsoft 免费 · DeepL 免费 Key · OpenAI 兼容';

  @override
  String get settingsPageSectionsInput5 =>
      'https://api.openai.com/v1 或 http://127.0.0.1:11434/v1';

  @override
  String settingsPageSectionsSub11(String translationTargetLabel) {
    return '日语 → $translationTargetLabel';
  }

  @override
  String settingsPageNextKeyIdText(String shortcutLabel) {
    return '当前按键：$shortcutLabel\n\n按下新的单个按键';
  }

  @override
  String get settingsPageBuildText4 =>
      '将清除本机全部数据，且不可恢复：\n\n· ASMR.ONE 账号与自建站点配置\n· 收藏 / 播放历史 / 歌单 / 黑名单\n· 翻译结果、均衡器、桌面歌词、定时关闭等全部设置\n\n请确认是否继续。';

  @override
  String get mark => '标记';

  @override
  String get confirm => '确定';

  @override
  String get refresh => '刷新';

  @override
  String get workPageBuildLabel => '评论';

  @override
  String get translate => '翻译';

  @override
  String get workPageRefreshWorkToast => '已刷新';

  @override
  String get workPageBuildTooltip => '上一张';

  @override
  String get workPageBuildText => '已收藏';

  @override
  String get workPageBuildText2 => '翻译中';

  @override
  String get workPageBuildTooltip2 => '下一张';

  @override
  String get workPageLanguageEditionsButtonText => '多语言';

  @override
  String get workPageSimilarWorksSliversText => '相似作品';

  @override
  String get workPageBuildText3 => '曲目列表';

  @override
  String get workPageConfirmedText => '删除标记';

  @override
  String get workPageConfirmedText2 => '删除作品';

  @override
  String get workPageRefreshWorkToast2 => '刷新失败';

  @override
  String get workPageShowTextViewerTooltip => '切换编码';

  @override
  String get workPageBuildText4 => '我的评论';

  @override
  String get workPageAddToPlaylistText => '确认添加';

  @override
  String get workPageBuildHintText => '写评论…';

  @override
  String get workPageBuildText5 => '取消翻译';

  @override
  String get workPageOkText => '加入黑名单';

  @override
  String get workPageAddToPlaylistText2 => '添加到歌单';

  @override
  String get workPageTranslateTitlesToast => '已取消翻译';

  @override
  String get workPageSelectedText => '选择 CV';

  @override
  String get workPageBuildText6 => '添加至歌单';

  @override
  String get workPageBuildText7 => '下载选中项目';

  @override
  String get workPageOpenVideoChooserText => '选择打开方式';

  @override
  String get workPageOpenVideoChooserText2 => '音频方式打开';

  @override
  String get workPageSelectedText2 => '切换翻译引擎';

  @override
  String get workPageTranslateTitlesToast2 => '未知翻译引擎';

  @override
  String get workPageTranslateTitlesFormatException => '翻译结果为空';

  @override
  String get workPageAllFilesRowText => '查看全部文件';

  @override
  String get workPageDownloadSelectedToast => '已加入下载队列';

  @override
  String get workPageAddToPlaylistText3 => '请输入歌单名称';

  @override
  String get workPageOpenVideoChooserText3 => '外部播放器打开';

  @override
  String workPageDeleteNotify(String e) {
    return '删除失败：$e';
  }

  @override
  String get workPageBuildLabel2 => '添加到播放列表';

  @override
  String workPageSetProgressToast(String e) {
    return '标记失败：$e';
  }

  @override
  String get workPageBuildLabel3 => '仅显示媒体文件';

  @override
  String get workPageTreePlaceholderText => '该作品暂无曲目';

  @override
  String workPageTranslateTitlesToast3(String e) {
    return '翻译失败：$e';
  }

  @override
  String workPageRateWorkToast(String e) {
    return '评分失败：$e';
  }

  @override
  String workPageApplyEncodingToast(String e) {
    return '解码失败：$e';
  }

  @override
  String workPageSubmitNotify(String e) {
    return '保存失败：$e';
  }

  @override
  String get workPageSimilarWorksSliversText2 => '加载更多相似作品';

  @override
  String get workPageDownloadSelectedToast2 => '曲目列表尚未加载';

  @override
  String workPageClearRatingToast(String e) {
    return '取消评分失败：$e';
  }

  @override
  String get workPageRefreshWorkToast3 => '已刷新本地下载记录';

  @override
  String workPageDownloadSelectedToast3(String e) {
    return '加入下载失败：$e';
  }

  @override
  String get workPageSimilarWorksSliversText3 => '已显示全部相似作品';

  @override
  String get workPageOpenLanguageEditionToast => '无法加载该语言版本';

  @override
  String workPageBuildToast(String e) {
    return '收藏操作失败：$e';
  }

  @override
  String get workPageConfirmedText3 => '确定要删除标记吗？';

  @override
  String workPageSetProgressToast2(String e) {
    return '取消标记失败：$e';
  }

  @override
  String get workPageBuildLabel4 => '跳转 DLsite';

  @override
  String get workPageAddToPlaylistToast => '请先勾选文件或文件夹';

  @override
  String get workPageBuildText8 => '曲目列表（文件夹结构）';

  @override
  String get workPageBuildLabel5 => '跳转 asmr.one';

  @override
  String workPageAddToPlaylistToast2(String name) {
    return '已添加到「$name」';
  }

  @override
  String get workPageAddToServerPlaylistToast => '只能添加到自建播放列表';

  @override
  String get workPageOnMoreActionToast => '曲目列表加载中，请稍候';

  @override
  String get workPageTreePlaceholderText2 => '该作品没有音频或视频文件';

  @override
  String get workPageAddToServerPlaylistToast2 => '该作品缺少编号，无法添加';

  @override
  String get workPageOpenReviewDialogToast => '该作品缺少编号，无法评价';

  @override
  String get workPageDeleteSelectedLocalFilesToast => '所选项目中没有已下载文件';

  @override
  String get workPageDeleteSelectedLocalFilesToast2 => '请先勾选要删除的本地文件';

  @override
  String get workPageOnMoreActionToast2 => '曲目加载失败，请刷新后重试';

  @override
  String get workPageTreePlaceholderText3 => '无网络连接，无法获取曲目列表';

  @override
  String workPageBuildText9(String dur) {
    return '时长 $dur';
  }

  @override
  String get workPageEnginesEngines => 'DeepL（免费版 Key）';

  @override
  String get workPageEnginesEngines2 => 'OpenAI 兼容（可配置）';

  @override
  String workPageCopyRjToast(String rj) {
    return '已复制 $rj';
  }

  @override
  String get workPageDownloadSelectedToast4 => '请先勾选要下载的项目或文件夹';

  @override
  String get workPageAddToPlaylistToast3 => '所选项目中没有可播放的音频文件';

  @override
  String get workPageOnMoreActionToast3 => '请先勾选需要听写翻译的媒体文件';

  @override
  String get workPagePlayAsAudioToast => 'SFW 模式下不能播放非全年龄作品';

  @override
  String get workPageOpenLanguageEditionToast2 => 'SFW 模式下不能打开非全年龄作品';

  @override
  String get workPagePlayFilesToast => '暂无音频文件（文件流需登录后可用）';

  @override
  String get workPageEnginesEngines3 => 'Google（免费，无需 Key）';

  @override
  String workPageNodeRowToast(String title) {
    return '已复制文件名：$title';
  }

  @override
  String workPageDeleteSelectedLocalFilesToast3(String deleted) {
    return '已删除 $deleted 个本地文件';
  }

  @override
  String get workPageTranslateTitlesToast4 => '请先在设置中配置 API 地址与模型名';

  @override
  String get workPageEnginesEngines4 => 'Microsoft（免费，无需 Key）';

  @override
  String workPageOpenFileToast(String title) {
    return '暂不支持查看该类型：$title';
  }

  @override
  String get workPageEnginesEngines5 => 'Index-Translate（官方接口）';

  @override
  String get workPageConfirmDeleteWorkToast => '删除失败，请关闭正在占用该作品的程序后重试';

  @override
  String workPageTranslateTitlesToast5(String length) {
    return '正在翻译 $length 行标题…';
  }

  @override
  String get workPageTranslateTitlesToast6 => '请先在设置中填写 DeepL 免费版 API Key';

  @override
  String workPageAddToPlaylistText4(String length) {
    return '已选择 $length 个音频文件';
  }

  @override
  String get workPageOnMoreActionToast4 => '所选项目中没有可提交给 kikoeta-transl 的媒体文件';

  @override
  String workPageTranslateTitlesToast7(String length) {
    return '翻译完成（标题 + $length 个曲目）';
  }

  @override
  String workPageOkText2(String t) {
    return '将标签「$t」加入黑名单？\n加入后，含该标签的作品将从首页与搜索中过滤。';
  }

  @override
  String workPageConfirmedText4(String title) {
    return '确定删除“$title”的全部本地文件吗？此操作无法撤销。';
  }

  @override
  String get liked => '喜欢';

  @override
  String get privatePlaylist => '私有';

  @override
  String get publicPlaylist => '公开';

  @override
  String get sharedByLink => '链接共享';

  @override
  String get apiServiceMapPlaylistName => '未命名歌单';

  @override
  String get apiServiceMapWorkVa => 'CV. 未知';

  @override
  String get apiServiceFetchWorkFormatException => '作品详情格式无效';

  @override
  String get apiServiceFetchPlaylistMetadataFormatException => '歌单详情格式无效';

  @override
  String get apiServiceFetchAdvancedFilterEntriesValue => '不支持的高级筛选类型';

  @override
  String get apiServiceFetchAdvancedFilterEntriesFormatException =>
      '高级筛选数据格式无效';

  @override
  String get apiServiceToggleFavoriteException => '该作品缺少编号，无法收藏';

  @override
  String get apiServiceClearReviewRatingException => '该作品缺少编号，无法取消评分';

  @override
  String get apiServiceClearReviewProgressException => '该作品缺少编号，无法取消标记';

  @override
  String get apiServiceDeleteReviewException => '该作品缺少编号，无法删除标记';

  @override
  String get search => '搜索';

  @override
  String clipboardWatcherCheckText(String rj) {
    return '检测到 $rj，点击搜索';
  }

  @override
  String get desktopLyricsOverlayEnsureWindowToNativeUtf16 => 'Kikoeta 桌面歌词';

  @override
  String get downloadServiceDownloadFileHttpException => '下载文件为空';

  @override
  String get downloadServiceRunStateError => '没有可下载的文件';

  @override
  String get downloadServiceRunStateError2 => '下载文件地址为空';

  @override
  String get downloadTransferDownloadToFileHttpException => '下载响应不完整';

  @override
  String get downloadTransferDownloadToFileHttpException2 => '下载分片长度发生变化';

  @override
  String get downloadTransferDownloadToFileHttpException3 => '下载文件长度校验失败';

  @override
  String get downloadTransferDownloadToFileHttpException4 => '下载响应的字节范围不匹配';

  @override
  String get downloadTransferDownloadToFileHttpException5 => '下载响应超过声明的文件长度';

  @override
  String get downloadTransferDownloadToFileHttpException6 => '下载响应使用了非原始字节编码';

  @override
  String downloadTransferDownloadToFileHttpException7(String status) {
    return '下载失败 HTTP $status';
  }

  @override
  String get ktServiceNormalizeEndpointFormatException => '连接地址格式应为 IP/域名:端口';

  @override
  String get ktServiceDecodeFormatException => 'kikoeta-transl 返回了无效响应';

  @override
  String get ktServiceNormalizeEndpointFormatException2 =>
      '请输入 kikoeta-transl 的 IP/域名与端口';

  @override
  String ktServiceErrorMessageText(String statusCode) {
    return 'kikoeta-transl 请求失败（HTTP $statusCode）';
  }

  @override
  String get lyricsLibraryRemoteClientValidateWorkIdFormatException => '无效的作品号';

  @override
  String get lyricsLibraryRemoteClientFetchWorksFormatException =>
      '远程歌词库分页游标无效';

  @override
  String get lyricsLibraryRemoteClientFetchWorksFormatException2 =>
      '远程歌词库未提供作品列表';

  @override
  String get lyricsLibraryRemoteClientFetchLyricsFormatException =>
      '远程作品没有歌词文件列表';

  @override
  String get lyricsLibraryRemoteClientFetchLyricsFormatException2 =>
      '远程作品没有可用歌词文件';

  @override
  String get lyricsLibraryRemoteClientGetJsonFormatException =>
      '远程歌词库返回的数据格式无效';

  @override
  String get lyricsLibraryRemoteClientNormalizeBaseUrlFormatException =>
      '请输入有效的 HTTP 或 HTTPS 地址';

  @override
  String lyricsLibraryRemoteClientGetJsonHttpException(String statusCode) {
    return '远程歌词库返回 HTTP $statusCode';
  }

  @override
  String get lyricsLibraryServiceExtractArchivePhase => '正在解压';

  @override
  String get lyricsLibraryServiceCopyTreePhase => '正在复制';

  @override
  String get lyricsLibraryServiceRemoveRemoteLibraryStateError => '该远程库尚未导入';

  @override
  String get lyricsLibraryServiceSaveTranslatedLyricsArgumentError =>
      '不支持的歌词格式';

  @override
  String get lyricsLibraryServiceSaveTranslatedLyricsArgumentError2 =>
      '文件中没有有效时间轴';

  @override
  String get lyricsLibraryServiceImportRemoteWorkFormatException =>
      '远程作品没有有效歌词文件';

  @override
  String get lyricsLibraryServiceSaveTranslatedLyricsArgumentError3 =>
      '目标文件必须位于作品目录内';

  @override
  String get lyricsLibraryServiceSetRemoteLibraryOrderArgumentError =>
      '远程库列表已变化，请重新打开导入窗口';

  @override
  String lyricsLibraryServiceSubscriptionStateError(String message) {
    return '歌词导入进程异常: $message';
  }

  @override
  String get updateServiceShowUpdateDialogText => '不再提示';

  @override
  String get updateServiceShowUpdateDialogText2 => '跳转下载';

  @override
  String get updateServiceShowUpdateDialogText3 => '发现新版本';

  @override
  String get updateServiceCheckManuallyText => '正在检查更新…';

  @override
  String get updateServiceCheckError => '更新服务连接失败';

  @override
  String get updateServiceCheckManuallyToast => '当前已是最新版本';

  @override
  String get updateServiceShowUpdateDialogToast => '打开下载页面失败';

  @override
  String get updateServiceGetUpdateResponseStateError => '更新服务请求未执行';

  @override
  String get updateServiceParseReleaseResponseFormatException => '更新响应缺少版本信息';

  @override
  String get updateServiceCheckError2 => '更新服务未返回有效版本信息';

  @override
  String get updateServiceCheckError3 => '无法连接更新服务或 GitHub';

  @override
  String updateServiceShowUpdateDialogText4(
    String version,
    String currentVersion,
  ) {
    return '最新版本：$version\n当前版本：$currentVersion';
  }

  @override
  String get pause => '暂停';

  @override
  String get quit => '退出';

  @override
  String get windowsTrayServiceSetContextMenuLabel => '显示首页';

  @override
  String get sheetsShowSleepSheetSuffixText => '分钟';

  @override
  String get sheetsBuildText => '应用';

  @override
  String get sheetsShowSiteSheetField => '别名';

  @override
  String get sheetsShowSiteSheetField2 => '地址';

  @override
  String get account => '账号';

  @override
  String get sheetsPresetsPresets => '人声';

  @override
  String get sheetsPresetsPresets2 => '低音';

  @override
  String get sheetsPresetsPresets3 => '平直';

  @override
  String get sheetsPresetsPresets4 => '流行';

  @override
  String get sheetsPresetsPresets5 => '摇滚';

  @override
  String get sheetsShowEqSheetText => '未启用';

  @override
  String get sheetsShowEqSheetText2 => '已应用';

  @override
  String get sheetsShowSleepSheetText => '取消定时';

  @override
  String get sheetsShowSleepSheetText2 => '开始定时';

  @override
  String get playbackComplete => '播放完毕';

  @override
  String get sheetsTimePickerText => '关闭时间';

  @override
  String get sheetsShowSleepSheetLabel => '指定时间';

  @override
  String sheetsShowSleepSheetLabel2(String m) {
    return '$m 分钟';
  }

  @override
  String get sheetsShowSleepSheetLabel3 => 'N 分钟后';

  @override
  String get sheetsBuildTitle => '选择服务器';

  @override
  String get sheetsShowEqSheetText3 => '启用均衡器';

  @override
  String get sheetsShowSiteSheetTitle => '编辑自建站点';

  @override
  String get sheetsBuildText2 => '管理自建站点';

  @override
  String get sheetsShowSleepSheetHintText => '自定义分钟数';

  @override
  String get sheetsBuildText3 => '暂无自建站点';

  @override
  String get sheetsBuildText4 => '选择自建站点';

  @override
  String get sheetsShowSiteSheetHint => '如：家庭 NAS';

  @override
  String get sheetsBuildText5 => '请先添加自建站点';

  @override
  String get sheetsShowOneConfigSheetTitle => 'ASMR.ONE 账号';

  @override
  String get sheetsShowOneConfigSheetHint => 'asmr.one 账号';

  @override
  String get sheetsShowOneConfigSheetSub => '账号信息仅保存在本地（演示）';

  @override
  String get sheetsShowSleepSheetText3 => '当前播放列表播完后自动停止并关闭';

  @override
  String get sheetsShowSleepSheetText4 => '剩余时间 · 到点后自动停止并退出';

  @override
  String get sheetsBuildSub => '官方服务或自建 Kikoeru 站点';

  @override
  String get sheetsShowEqSheetSub => '真 10 段 · ±12 dB · 全平台';

  @override
  String get sheetsShowSleepSheetText5 => '当前播放列表的内容播放完毕后自动停止并关闭';

  @override
  String get sheetsShowSleepSheetSub => '到点后停止播放并释放系统接口（锁屏卡片 / 通知全部清除）';

  @override
  String sheetsBuildLabel(String length) {
    return '自定义配置（$length）';
  }

  @override
  String playbackSeekSecondsControlBuildTooltip(String label) {
    return '减少$label秒数';
  }

  @override
  String playbackSeekSecondsControlBuildTooltip2(String label) {
    return '增加$label秒数';
  }

  @override
  String get name => '名称';

  @override
  String get description => '描述';

  @override
  String get playlistPickerRowsMapEntry => '权限';

  @override
  String get language => '语言';

  @override
  String get confirmAction => '确认';

  @override
  String get create => '新建';

  @override
  String get playlistPickerShowEditorLabelText => '类型';

  @override
  String get playlistPickerRowsMapEntry2 => '创建人';

  @override
  String get playlistPickerRowsMapEntry3 => '更新时间';

  @override
  String get playlistPickerReviewsItemName => '我的收藏';

  @override
  String get playlistPickerRowsMapEntry4 => '播放次数';

  @override
  String get playlistPickerRowsMapEntry5 => '作品数量';

  @override
  String get playlistPickerCopyText => '歌单详情';

  @override
  String get playlistPickerLinkLabelText => '分享链接';

  @override
  String get playlistPickerCopyText2 => '复制链接';

  @override
  String get playlistPickerRowsMapEntry6 => '创建时间';

  @override
  String get playlistPickerBuildText => '切换播放列表';

  @override
  String get playlistPickerPlaylistItemTooltip => '移除播放列表';

  @override
  String get playlistPickerPlaylistItemTooltip2 => '编辑播放列表';

  @override
  String get playlistPickerShowEditorText => '创建播放列表';

  @override
  String get playlistPickerLinkText => '导入播放列表';

  @override
  String get playlistPickerOkText => '删除播放列表';

  @override
  String playlistPickerRemoveLikedToast(String e) {
    return '移除失败：$e';
  }

  @override
  String playlistPickerCreatePlaylistToast(String e) {
    return '创建失败：$e';
  }

  @override
  String get playlistPickerLoadSetState => '无法加载播放列表';

  @override
  String get playlistPickerImportPlaylistToast => '无法识别播放列表链接';

  @override
  String get playlistPickerReviewsItemSubtitle => '我的评价/收藏（所有作品）';

  @override
  String get playlistPickerCreatePlaylistToast2 => '已创建，但列表中未找到该播放列表';

  @override
  String get playlistPickerImportPlaylistToast2 => '已添加，但列表中暂未找到该播放列表';

  @override
  String playlistPickerSubtitleSubtitle(String worksCount) {
    return '$worksCount 个作品';
  }

  @override
  String get playlistPickerLinkText2 => '粘贴别人分享的播放列表链接，会收藏到我的播放列表。';

  @override
  String playlistPickerOkText2(String name) {
    return '确定删除“$name”吗？此操作无法撤销。';
  }

  @override
  String playlistPickerOkText3(String name) {
    return '确定从我的播放列表中移除“$name”吗？';
  }

  @override
  String playlistPickerSubtitleSubtitle2(String worksCount, String replaceAll) {
    return '$worksCount 个作品 · $replaceAll';
  }

  @override
  String get widgetsFilterButtonTooltip => '筛选';

  @override
  String get widgetsFilterButtonLabel => '仅字幕';

  @override
  String get allAges => '全年龄';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter => '排除语言';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter2 => '搜索社团';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter3 => '搜索声优';

  @override
  String get widgetsBuildBuilder => 'AI歌词';

  @override
  String get widgetsBuildBuilder2 => '远程歌词';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter4 => '筛选语言';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter5 => '排除标签';

  @override
  String get widgetsBuildBuilder3 => '本地歌词';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter6 => '排除社团';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter7 => '排除声优';

  @override
  String get widgetsInputRowMessage => '高级搜索';

  @override
  String get widgetsHistoryPanelText => '搜索历史';

  @override
  String get widgetsBuildBuilder4 => '在线歌词';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter8 => '搜索标签';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter9 =>
      '筛选年龄分级';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter10 =>
      '排除年龄分级';

  @override
  String get widgetsBuildText => '高级搜索参数';

  @override
  String get widgetsHistoryPanelText2 => '暂无搜索历史';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter11 =>
      '包含低愿力标签';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter12 =>
      '排除低愿力标签';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter13 =>
      '筛选评分（大于）';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter14 =>
      '筛选销量（大于）';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter15 =>
      '筛选价格（大于）';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter16 =>
      '筛选作品时长（小于）';

  @override
  String get widgetsAdvancedSearchParametersAdvancedSearchParameter17 =>
      '筛选作品时长（大于）';

  @override
  String widgetsHistoryPanelText3(String value) {
    return '已删除「$value」';
  }

  @override
  String get widgetsInputRowHintText => '搜索 RJ 号、作品名、声优…';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn() : super('zh_CN');
}
