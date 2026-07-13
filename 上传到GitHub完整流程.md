# 把当前项目上传到 GitHub 的完整流程

目标仓库：
`https://github.com/li-jinhang/26-102MobileSoftware`

当前项目状态：

- 本地已经是 Git 仓库
- 当前分支是 `main`
- 远程仓库暂未配置
- `.gitignore` 已经忽略了 `oh_modules`、`local.properties`、`.idea`、`.hvigor`、`build` 等本地文件

## 一、先确认 GitHub 仓库已创建

先在浏览器打开下面这个地址：

`https://github.com/li-jinhang/26-102MobileSoftware`

需要确认：

- 这个仓库已经存在
- 你有该仓库的推送权限

如果仓库是空仓库，最适合直接执行下面流程。

如果仓库里已经有内容，比如自动生成了 `README.md`、`.gitignore` 或 `LICENSE`，建议优先用下面命令拉取并合并后再推送：

```bash
git pull origin main --allow-unrelated-histories
```

## 二、进入项目根目录

在终端中进入项目目录：

```bash
cd /d d:\_Projects\_assignment\Mobile_software_development
```

如果你使用的是 PowerShell，也可以直接：

```powershell
Set-Location "d:\_Projects\_assignment\Mobile_software_development"
```

## 三、检查当前 Git 状态

执行：

```bash
git status -sb
git remote -v
```

你当前项目的状态是：

- 分支：`main`
- 远程：还没有配置

## 四、把远程仓库地址绑定到本地项目

执行：

```bash
git remote add origin https://github.com/li-jinhang/26-102MobileSoftware.git
```

绑定完成后检查：

```bash
git remote -v
```

正常会看到：

```bash
origin  https://github.com/li-jinhang/26-102MobileSoftware.git (fetch)
origin  https://github.com/li-jinhang/26-102MobileSoftware.git (push)
```

如果提示 `remote origin already exists`，说明之前已经配过远程，此时改用：

```bash
git remote set-url origin https://github.com/li-jinhang/26-102MobileSoftware.git
```

## 五、把项目文件加入暂存区

执行：

```bash
git add .
```

建议再检查一次：

```bash
git status
```

重点确认：

- 没有把不该上传的本地缓存文件加入版本控制
- 已修改的源码文件都已经进入暂存区

## 六、提交本地版本

执行：

```bash
git commit -m "feat: 初始化鸿蒙移动应用项目"
```

如果提示没有可提交内容，说明之前可能已经提交过了，这种情况可以直接进入推送步骤。

## 七、第一次推送到 GitHub

执行：

```bash
git push -u origin main
```

参数说明：

- `origin`：远程仓库名称
- `main`：推送的分支名
- `-u`：把本地 `main` 和远程 `origin/main` 建立跟踪关系

第一次推送成功后，以后只需要：

```bash
git push
```

## 八、如果推送时需要登录

GitHub 现在通常不支持直接使用账号密码推送，常见方式有两种：

### 方式 1：浏览器登录授权

如果你的 Git 已安装 Git Credential Manager，执行 `git push` 后通常会弹出浏览器登录 GitHub，按提示授权即可。

### 方式 2：使用 Personal Access Token

如果终端要求输入用户名和密码：

- 用户名：你的 GitHub 用户名
- 密码位置：填写 GitHub 的 Personal Access Token，不是账号登录密码

Token 可在 GitHub 设置中创建：

`Settings -> Developer settings -> Personal access tokens`

## 九、如果远程仓库不是空仓库

如果推送时报错类似：

```bash
! [rejected] main -> main (fetch first)
```

说明远程仓库已经有提交历史。按下面顺序处理：

```bash
git pull origin main --allow-unrelated-histories
```

如果出现冲突：

1. 手动修改冲突文件
2. 再执行 `git add .`
3. 执行 `git commit -m "merge: 合并远程仓库初始化内容"`
4. 最后执行：

```bash
git push -u origin main
```

## 十、上传完成后检查

推送成功后：

1. 打开仓库页面  
   `https://github.com/li-jinhang/26-102MobileSoftware`
2. 检查源码目录是否完整
3. 检查是否误传了本地配置文件
4. 检查默认分支是否为 `main`

## 十一、后续更新项目的标准流程

以后每次更新项目，使用下面 3 步即可：

```bash
git add .
git commit -m "chore: 更新项目内容"
git push
```

## 十二、推荐直接执行的一套命令

如果远程仓库是空的，并且你现在就要上传，可以直接按顺序执行：

```bash
cd /d d:\_Projects\_assignment\Mobile_software_development
git remote add origin https://github.com/li-jinhang/26-102MobileSoftware.git
git add .
git commit -m "feat: 初始化鸿蒙移动应用项目"
git push -u origin main
```

## 十三、常见问题

### 1. `remote origin already exists`

执行：

```bash
git remote set-url origin https://github.com/li-jinhang/26-102MobileSoftware.git
```

### 2. `src refspec main does not match any`

说明当前还没有提交记录，先执行：

```bash
git add .
git commit -m "feat: 初始化项目"
```

然后再推送。

### 3. `failed to push some refs`

通常是远程仓库已有内容，先执行：

```bash
git pull origin main --allow-unrelated-histories
```

处理完冲突后再重新推送。

### 4. 登录失败

优先检查：

- GitHub 账号是否有该仓库权限
- 是否使用了 Token 而不是密码
- 本机 Git 登录状态是否过期

## 十四、可选的 Git 配置

如果这台电脑还没配置 Git 用户信息，可以先执行：

```bash
git config --global user.name "你的GitHub用户名"
git config --global user.email "你的GitHub邮箱"
```

检查配置：

```bash
git config --global --list
```
