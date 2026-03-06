# Reminder-app

一个原生 macOS 菜单栏小应用：

- 常驻状态栏
- 顶部固定激励文段
- 底部 `+` 添加事项
- `●` 表示已经做过
- `○` 表示待办提醒
- 数据自动保存在本地

## 直接安装

要求：

- macOS 13 或更高
- 已安装 Apple Command Line Tools

下载仓库后，在项目目录执行：

```bash
./Scripts/install.sh
```

它会自动：

1. 编译 release 版本
2. 打包成 `.app`
3. 安装到 `/Applications/MotivateBar.app`
4. 自动打开应用

也可以用：

```bash
make install
```

## 开发运行

```bash
swift run
```

运行后会在 macOS 状态栏出现一个列表图标，点击即可打开面板。

## 打包成可双击的 app

```bash
./Scripts/package_app.sh
```

打包完成后，生成物在：

```bash
dist/MotivateBar.app
```

你可以把这个 `.app` 拖进 `Applications`，之后就不依赖这个源码目录继续使用。

## 命令摘要

```bash
make build
make package
make install
make run
```

## 说明

- 中文字体优先使用 `Songti SC`
- 英文字体通过级联字体优先回退到 `Palatino`
- 事项点击后可在“待办 / 已做”之间切换
