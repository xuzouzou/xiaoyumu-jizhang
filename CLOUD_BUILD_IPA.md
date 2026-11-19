# 没有 Mac，也能得到 IPA：云端 Mac 自动打包（免费）

本工程已带 GitHub Actions 配置 `.github/workflows/build-ipa.yml`，
它会在 GitHub 的 macOS 云电脑上用 Xcode 编译，并产出未签名 IPA。
未签名 IPA 再用你自己的 Apple ID 在 iPhone 上签名安装（SideStore），不需要 Mac。

## 第 1 步：得到 IPA 文件
1. 登录 github.com，点 New repository，新建一个仓库，例如 `xiaoyumu-jizhang`（Public 或 Private 都可）。
2. 把本 ZIP 解压后的全部文件上传到仓库根目录（注意 `.github` 文件夹也要传；
   网页上传看不到隐藏文件夹时，可用 GitHub Desktop 或 git 命令上传）。
3. 打开仓库的 Actions 页，点 `Build IPA` > `Run workflow`。
4. 等待约 5-10 分钟变绿勾，点进这次运行，在 Artifacts 里下载
   `XiaoYuMuJiZhang-unsigned-ipa`，解压得到 `XiaoYuMuJiZhang-unsigned.ipa`。

## 第 2 步：在 iPhone 上签名安装（SideStore，免费）
1. 按 sidestore.io 官网指引在 iPhone 上安装 SideStore（首次需要用电脑辅助一次，
   之后可在手机上自行续签）。
   替代工具：AltStore（原理相同，需要电脑上的 AltServer 辅助）。
2. 在 SideStore 里点 +，选择下载好的 `.ipa` 文件，用你的 Apple ID 登录签名。
3. 签名完成后，「小榆木记账」会出现在桌面。免费 Apple ID 签名的 App 有效期 7 天，
   SideStore 可在到期前在手机上点 Refresh 续签。

## 说明
- 为什么 IPA 不能预先签好给你：签名绑定的是安装者本人的 Apple 证书和设备，
  别人的证书签出来的包，在你的手机上装不上，也随时会被苹果吊销。
- 有付费开发者账号（99 美元/年）时，可改用 TestFlight 分发，有效期更长、体验最稳。
