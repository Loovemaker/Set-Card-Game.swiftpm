# Set纸牌游戏


![RO6o4A](https://raw.githubusercontent.com/Loovemaker/pictures/master/uPic/RO6o4A.png)

![](https://img.shields.io/badge/iPadOS-15.2-green)![](https://img.shields.io/badge/macOS-12.4-brightgreen)![](https://img.shields.io/badge/Swift-5.5-blue)![](https://img.shields.io/badge/SwiftUI-2.0-blue)
![](https://img.shields.io/badge/Game-Card-orange)![](https://img.shields.io/badge/From-CS193p-lightgrey)![](https://img.shields.io/badge/Status-🕷Refactor🕷Ready🕷-red)
![](https://img.shields.io/badge/CodingFor-Fun!-brightgreen)

Set纸牌游戏的App项目，充分地利用了Apple的[Swift编程语言](https://developer.apple.com/cn/swift/)和[SwiftUI技术](https://developer.apple.com/cn/xcode/swiftui/)，源于斯坦福大学iOS开发公开课（`CS193p`）的一个作业。

>   人人能编程

## 咋玩？

Set纸牌游戏的规则可在以下地方找到：

-	App内
-   [Wikipedia](https://en.wikipedia.org/wiki/Set_(card_game))
-   [另一个百科网站](https://baike.baidu.com/item/SET纸牌/8059167)

## 如何运行该App？

### 环境要求

你需要满足以下所有环境要求：

-   选择一个开发环境App：
    -   [Swift Playgrounds](https://apps.apple.com/cn/app/swift-playgrounds/id1496833156)（iPad/Mac，支持简体中文）
    -   [Xcode](https://apps.apple.com/cn/app/xcode/id497799835)（Mac）
-   选择一个运行设备：
    -   与开发环境相同的设备
    -   iPhone（需要使用Xcode开发，并配置Apple Developer身份）
    
-   更新系统软件

### 打开项目

进行以下操作：

-   对于iPad，正确安装（可能需要运行至少一次）Swift Playgrounds后，把项目文件夹移至iCloud云盘的`Playgrounds`文件夹，以便Swift Playgrounds识别到项目
-   对于Mac，`.swiftpm`扩展名的项目可以直接被Swift Playgrounds打开，或者可以被Xcode强制打开。

您可以从原始的项目文件夹名称`Set-Card-Game.swiftpm`进行更改。但为了让开发环境App识别出正确的格式，该文件夹需要保留`.swiftpm`（Swift软件包）的扩展名。

## 打开项目以后我可以做什么

### 你可以体验该App

无论在Xcode还是在Swift Playgrounds，你都可以在窗口的左上方轻点或点击“▶️”（运行）按钮，等待片刻，App即将打开。Enjoy yourself！

### 你可以修改项目源码

哈哈哈，开玩笑的！

>   IT'S MAGIC!☢️DO NOT TOUCH!

代码早已经堆成[S山](https://www.zhihu.com/question/272065178)啦！加上本人并没有精力学习[WWDC](https://developer.apple.com/wwdc/)21公开的DocC文档技术，所以你不太可能对这个项目了如指掌。

但是我并没有说过你100%无法参与这个项目！

 ℹ️注意：在成功运行本项目的App时或者之前，你就应该获取到了本项目的源码，*or something bad happened*...

凭我的经验，可以直接删除但千万不要乱改预览程序（PreviewProvider），SwiftUI的预览程序功能从设计上并不考虑调试功能。

## 项目结构

![rzZ8FU](https://raw.githubusercontent.com/Loovemaker/pictures/master/uPic/rzZ8FU.png)

真的想看？RUSure？我乱写的，你做好心理准备...

项目打开后可以看到：左侧边栏为文件结构，右侧边栏为SwiftUI预览界面，中间就是写代码的地方。

### 文件结构

-   **`original`文件夹**：
    与《Set纸牌游戏》最为相关的业务代码逻辑。

-   **`external`文件夹**：
    一些辅助的功能扩展，用于更轻松地写剩余的代码。

-   **`资源`**（Swift Playgrounds）或**`Assets`资源包**（Xcode）：
    存放静态的美术资源和数据资源。目前该项目只用到了图像资源，SwiftUI可以通过以下代码实现：

    ```swift
    Image("图像名称")	// 得到图像资源的SwiftUI View
    ```

-   **`Set纸牌游戏`**：
    是的，它本身也是可以点的。可以设置App的名称、图标、强调色、版本号等属性。在Xcode中，App图标默认为**`Assets`资源包**的`AppIcon`，它的格式是App图标集（`.appiconset`），你可能需要特殊工具制作。

-   **第三方软件包🧳**：
    Swift Playgrounds和Xcode都有这个功能。但，我并没有！鉴于两国关系，我很想用现成的代码🛞却没有办法正常使用。

-   **版本管理**：
    如果你用Xcode打开，你会注意到本项目已经使用Git进行源码控制。对于初步了解编程的**个人**开发者，可以了解以下Git功能：
    
    -   当项目在完成需求前就出现了混乱，导致开发进程无法继续时，使用`git reset`功能，**抹掉数据**并重置开发进度。在Xcode中命令为`Discard All Changes...`（可以使用快捷键 ⌘? 搜索）。
    
    -   当项目具有一定进展并达到较稳定状态（一般是可以构建可运行的App），使用`git commit`功能，保存进度。在Xcode中命令为`Commit...`。
    
    -   如果想进一步了解并深入学习Git，本人推荐[《Pro Git 第二版》](https://www.git-scm.com/book/zh/v2)。


### 源码结构

首先Swift支持使用`@main`标记App运行时的入口，它写在了`SetGameApp.swift`中。在`SetGameApp`中可以看到在它内部定义了游戏场景的状态。

游戏场景分为以下状态，写在了`GameState.swift`中：

-   介绍（`intro`，初始状态）
-   如何游玩（`tutorial`）
-   进入游戏（`inGame`）

“进入游戏”的场景无疑是游戏的重点，本App使用了SwiftUI所使用的[MVVM](https://zhuanlan.zhihu.com/p/59467370)架构，将该场景分为：

-   模型（**Model**）：
    即为《Set纸牌游戏》中卡片、Set、游戏场景等元素的数学模型和状态模型，写在了`SetGame.swift`中。它充分地利用了Swift的值类型（`struct`），因此性能更高，状态管理更安全，且具有快捷的JSON编解码功能。
-   绑定器（**ViewModel**）：
    组合了模型的对象（`class`），并对用户访问模型的功能进行了权限限制，写在了`SetGameVM.swift`中。此外，ViewModel充分使用了观察者模式和函数响应式编程，在模型和视图之间实现了双向绑定，有效地避免了传统[MVC](https://baike.baidu.com/item/MVC框架/9241230)架构中由于状态与视图之间未及时或未成功完成数据流传输而产生的问题。
-   视图（**View**）：
    即如何让模型显示在用户界面（UI）上，写在了`SetGameView.swift`中。SwiftUI 采用声明式语法，您只需声明用户界面应具备的功能便可。在SwiftUI视图内部可以使用`@State`、`@EnvironmentObject`等定义状态，这些状态的值改变后，用户界面内容会立刻自动刷新。

很可惜，由于这3个文件定义了太多的逻辑内容，其它场景的部分逻辑对其耦合并依赖。例如“如何游玩”的场景依赖卡片显示，并因此依赖游戏场景`SetGameVM`的ID值。

除了以上较高程度耦合的依赖，其它逻辑**主要都是静态的视图**，而且你很容易**动手修改**与视图相关的代码。SwiftUI的实时编译并预览功能将反映你所做的修改，只是它还不够快，你需要耐心等待。

## 作者感想

麻了都！感想啥感想，都写到这个进度了！**1750行**S山都搭进去了！而且你造嘛，Xcode某一天突然发疯，约每15分钟就意外退出一次，甚至其中有一分钟里面向Apple发送了两次崩溃报告（幸好项目规模不大，能在一分钟里面完全打开）！

但是SwiftUI真香！让我感觉到十几年前极为相似的[闪客文化](https://zhuanlan.zhihu.com/p/99682226)仿佛仍在昨天流行着。那些年，新华书店，家长带着孩子在里面陶冶情操，本人只知道在固定的角落，寻找固定的3ds Max（Autodesk）、Fireworks/Flash/Dreamweaver（Macromedia/Adobe）与Visual Basic（Microsoft）教程书...

在我写这个项目期间，陪伴女朋友的时间明显减少。但由于我讲述有关每天写了多少bug的有趣故事，女朋友非常开心~

如果哪天有机会再扒开这座小S山，给这个项目定下0.3，0.4，0.10乃至1.0的新版本目标，我想要添加的bug/feature有：

-   进一步提升**辅助功能**：

    SwiftUI贯彻了[Apple价值观之辅助功能](https://www.apple.com.cn/accessibility/)，相关开发难度已显著降低，关键在于开发者、老板、市场、这个世界以及人类自己的**态度**。由于我在开始这个项目时起了个坏头，这款App目前只能在Mac下支持正常的朗读功能，但有总比没有好。
    
    >   真正强大的科技，应该是让每一个人都能使用的科技。	——Apple

    我拒绝只活到**35岁**！但目前来看，我无法想象未来的自己随着年龄的增长而被科技抛在身后的感觉...
-   增加游戏本该具有的**互动性**：

    这对我来说就有亿点儿远啦。给《Set纸牌游戏》的同一个游戏场景下新增玩家？听起来很合理，《Set纸牌游戏》的游戏规则也觉得这样。但这需要我：

    -   掌握网络编程
    -   深入理解`async`/`await`、传统threading与事件驱动模型、18层回调地狱等网络编程必备的底层理论基础，这些都是6个月制的培训班并不会告诉你的*abracadabra*
    -   会构建并维护云服务环境（无论是Aliyun还是CloudKit总得来一个吧）
    -   保证合理时间段（就先不要求8✕25了哈）下运行功能稳定正常
    -   以及最绝望的，试图符合越来越苛刻的审核条件（是的，只要这个项目还是游戏类型，就无法符合*Socialism核心价值观*。**中国有电竞**，但从2016年5月24日，或最晚[2020年12月31日](https://raw.githubusercontent.com/Loovemaker/pictures/master/uPic/Ux1JHS.heic)起，**中国没游戏**。)。


>   写到这里，时间已经来到了本项目上线前一天晚上11:30。

## Interesting！我想深入研究一下相关技术！

⚠️你想体验的是**iOS/Flutter/前端工程师**还是**Apple Developer**？若有意图参与企业级iOS/Flutter/前端项目（中国大陆境内，或更大范围），请**优先参考市场环境，并谨慎选择对应的学习路线**。

此外，斯坦福大学iOS开发公开课（`CS193p`）是一个不错的选择。你可以从以下地方学习（English）：

-   官方渠道：[CS193p - Developing Apps for iOS](https://cs193p.sites.stanford.edu/)，包括本项目对应的homework，感兴趣的可以找找看
-   搬运后可访问的视频

