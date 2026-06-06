# PianoWizard iOS .dylib 插件构建指南

## 环境要求

- macOS 12+ 或 Linux (需交叉编译工具链)
- Xcode 15+ (macOS)
- Theos (越狱开发框架)
- iOS 14.0+ target device (越狱)

## 安装 Theos

```bash
# 安装 Theos
bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"

# 设置环境变量
export THEOS=~/theos
export PATH=$THEOS/bin:$PATH
```

## 项目结构

```
pianowizard-ios/
├── Makefile                    # Theos 构建配置
├── control                     # 包信息
├── Tweak.xm                    # ObjC 入口 (hook SpringBoard)
├── Sources/
│   ├── PWPluginLoader.swift    # Swift 插件入口
│   ├── PWOverlayManager.swift  # 悬浮窗管理
│   ├── PWPlayerView.swift      # 播放器 (毛玻璃风格)
│   ├── PWMainPanelView.swift   # 主面板
│   ├── PWSettingsView.swift    # 设置面板
│   ├── PWFloatingBallView.swift# 悬浮球
│   ├── PWCardInfoView.swift    # 卡密信息
│   ├── PWTheme.swift           # 主题色彩
│   ├── PWModels.swift          # 数据模型
│   └── PWNetworkClient.swift   # 网络请求
└── Resources/
```

## 构建

```bash
# 编译
make package

# 输出: packages/com.pianowizard.tweak_1.6.2_iphoneos-arm.deb
```

## 安装到设备

```bash
# 通过 SSH 安装
scp packages/com.pianowizard.tweak_*.deb root@<device_ip>:/tmp/
ssh root@<device_ip> "dpkg -i /tmp/com.pianowizard.tweak_*.deb && killall -9 SpringBoard"

# 卸载
ssh root@<device_ip> "dpkg -r com.pianowizard.tweak && killall -9 SpringBoard"
```

## 注入原理

1. `Tweak.xm` hook SpringBoard 的 `applicationDidFinishLaunching:`
2. 调用 `PWPluginBridge.shared.startPlugin()`
3. `PWOverlayManager` 创建多个 `UIWindow` 实例
4. 每个 window 使用 `UIWindow.Level.statusBar + 100`
5. 背景透明的 `UIHostingController` 承载 SwiftUI 视图
6. 悬浮球默认在右上角，可拖拽

## 注意事项

- iOS 14+ 需要 windowScene 初始化 UIWindow
- SwiftUI 在 UIHostingController 内运行不会被 release
- 内存管理：手动管理 UIWindow 引用，remove 时设置为 nil
- 手势冲突：每个 window 独立处理 pan gesture
- 不支持 .dylib 直接注入非越狱设备（需 App 签名 + 动态库链接）

## 非越狱替代方案

如果目标设备未越狱，可改为 .framework 静态库：
- 集成到宿主 App 中
- App 内部运行（无系统级悬浮窗）
- 使用 `UIScene` 的 `UIWindowScene` 管理窗口

## API 兼容性说明

| iOS 能力 | 替代方案 |
|-----------|---------|
| Accessibility dispatchGesture | 不支持，只能在 App 内模拟 |
| 读取其他 App 界面 | 不支持 |
| 全局悬浮窗 | 仅越狱可用 UIWindow level |
| 自动弹奏 | 需 Cydia Substrate hook 触摸事件 |
