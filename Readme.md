# 魔法相机

**中文版** | [English Version](Readme_EN.md)

*文档持续更新中，后续会有详细教程*

## 简介

魔法相机是一款基于SwiftUI和CoreML开发的 iOS AI 相机应用，实现了下列功能：

 - 人像卡通化，可以让你的照片变成卡通头像
 - 人像风格迁移，可以让你的照片变老、变年轻、变发色等
 - 美颜相机，支持磨皮、瘦脸和各种滤镜效果
 - 艺术效果，让你的照片别成各种艺术风格
<p align="center">
    <img src="screenshot/image1.jpg" width="200px">
    <img src="screenshot/image2.jpg" width="200px">
    <img src="screenshot/image3.jpg" width="200px">
</p>

## 实现

各种AI特效都基于苹果的CoreML开发，不需要访问网络，iOS13 以上设备都可以使用。

### 一、准备模型

#### 人像卡通化

- photo2cartoon模型转换为CoreML模型文件。项目地址：
[https://github.com/william0wang/photo2cartoon](https://github.com/william0wang/photo2cartoon)

- AnimeGANv2模型转换为CoreML模型文件。项目地址：
[https://github.com/william0wang/CoreML-Models](https://github.com/william0wang/CoreML-Models)

#### 人像风格迁移

- 风格迁移AttGAN-PyTorch模型转换为CoreML模型文件。项目地址：
[https://github.com/william0wang/AttGAN-PyTorch](https://github.com/william0wang/AttGAN-PyTorch)

#### 艺术效果

- 艺术效果fast-neural-style模型转换为CoreML模型文件。项目地址：
[https://github.com/william0wang/fast-neural-style](https://github.com/william0wang/fast-neural-style)

### 二、集成模型

未完待续...
