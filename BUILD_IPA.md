# 如何得到 IPA 安装包并装到 iPhone

重要说明：iOS 的 IPA 必须经过苹果签名才能安装，这不是技术限制能绕过的。
- 免费 Apple ID：在 Xcode 里真机运行即可装到自己手机，有效期 7 天，到期重新运行一次。
- 付费 Apple Developer（99 美元/年）：可以 Archive 导出 IPA，通过 TestFlight 或 Ad Hoc 分发，有效期 1 年。
- 没有签名的 IPA 文件，iPhone 会拒绝安装。

## 步骤（免费版即可自用）
1. 在 Mac 上安装 Xcode（App Store 免费）。
2. 解压 `XiaoYuMuJiZhang-iOS.zip`，双击打开 `XiaoYuMuJiZhang.xcodeproj`。
3. 在 Xcode 左上角登录你的 Apple ID：Settings > Accounts > + 添加。
4. 选中项目 > Signing & Capabilities，勾选 Automatically manage signing，Team 选你的 Personal Team。
   如果 Bundle Identifier 冲突，改成你自己的，例如 `com.yourname.xiaoyumu`。
5. 用数据线连接 iPhone，在 Xcode 顶部选择你的 iPhone 作为运行设备。
6. 点 Run（▶）。首次需要在 iPhone 上：设置 > 通用 > VPN与设备管理 > 信任你的开发者证书；
   并开启：设置 > 隐私与安全性 > 开发者模式。
7. App 就会以「榆木记账」的名字装到桌面。

## 导出 IPA（付费开发者）
Xcode 菜单 Product > Archive，完成后在 Organizer 里点 Distribute App 导出 IPA。

## 侧载工具（可选）
也可以用 AltStore / SideStore 把已签名的 IPA 装到 iPhone，原理仍然是用你的 Apple ID 签名。
