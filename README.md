# 说明

这是一个支持 Laravel 和 Lumen 框架运行的 Docker 镜像。根据中国国情做了一些改进，包括

* 基础镜像来自 DaoCloud 的 Ubuntu 14.04
* 使用中科大的 apt 源
* php5.5
* Nginx:lastest
* 没有 MySQL，请自己使用 LeanCloud 等 Saas 或者 link 另外的 MySQL 容器
* 构建完成后，对 Laravel 应用进行优化

# 使用方法

## 如果代码已经稳定，需要上线，可以直接把代码构建到镜像中去

1. 在 Ubuntu（虚拟机或服务器） 中安装好 Docker
2. 运行`$ git clone https://github.com/my101du/docker-nginx-php-composer-laravel-or-lumen.git`
 克隆本项目到某个路径，例如用户工作目录 `~/`下。
3. 运行`$ mv docker-nginx-php-composer-laravel-or-lumen laravel-app`，将目录改名，例如 `laravel-app`，进入目录 `cd laravel-app`
4. 将你正在开发中或已完成的 Laravel 应用代码全部复制到子目录`/wwwroot`中去
5. 运行 `$ sudo docker build -t image-laravel .`，构建一个包含了源代码和运行环境的新镜像
6. 运行 `$ sudo docker run --name docker-laravel -d -p 80:80 image-laravel` 运行容器，加载镜像

## 如果在开发中频繁修改代码，用 `Volumn` 方式挂载宿主机的目录，分离容器服务和工作目录

构建完镜像后，运行 `$ sudo docker run --name docker-laravel -v ~/laravel-app/wwwroot:/app -d -p 80:80 image-laravel` 。