job "gitea" {
  datacenters = ["homecluster"]
  constraint {
        attribute = "${node.unique.name}"
        operator = "="
        value = "node2"
        }
  group "app" {
    count = 1

    network {
       
      port "http" {
        static = 3000
      }

      port "ssh" {
        to = 22

        # Need a static assignment for SSH ops.
        static = 4222

      }
    }

    restart {
      attempts = 2
      interval = "2m"
      delay    = "30s"
      mode     = "fail"
    }

    task "gitea" {
      template {
        change_mode = "noop"
        destination = "local/app.ini"
        data = <<EOH
APP_NAME = Gitea: Git with a cup of tea
RUN_MODE = prod
RUN_USER = git

[repository]
ROOT = /data/git/repositories

[repository.local]
LOCAL_COPY_PATH = /data/gitea/tmp/local-repo

[repository.upload]
TEMP_PATH = /data/gitea/uploads

[server]
APP_DATA_PATH    = /data/gitea
DOMAIN           = localhost
SSH_DOMAIN       = localhost
HTTP_PORT        = 3000
ROOT_URL         = http://gitea.homelab.local
DISABLE_SSH      = false
SSH_PORT         = 22
SSH_LISTEN_PORT  = 22
LFS_START_SERVER = true
LFS_JWT_SECRET   = vyN7t-vbc8PzxuMev-UabQdgxlEith-FLQF2A08tUb0
OFFLINE_MODE     = false

[database]
PATH     = /data/gitea.db
DB_TYPE  = sqlite3
HOST     = localhost:3306
NAME     = gitea
USER     = root
PASSWD   = 
LOG_SQL  = false
SCHEMA   = 
SSL_MODE = disable
CHARSET  = utf8

[indexer]
ISSUE_INDEXER_PATH = /data/gitea/indexers/issues.bleve

[session]
PROVIDER_CONFIG = /data/gitea/sessions
PROVIDER        = file

[picture]
AVATAR_UPLOAD_PATH            = /data/gitea/avatars
REPOSITORY_AVATAR_UPLOAD_PATH = /data/gitea/repo-avatars
ENABLE_FEDERATED_AVATAR       = false

[attachment]
PATH = /data/gitea/attachments

[log]
MODE      = console
LEVEL     = info
ROUTER    = console
ROOT_PATH = /data/log

[security]
INSTALL_LOCK                  = true
SECRET_KEY                    = 
REVERSE_PROXY_LIMIT           = 1
REVERSE_PROXY_TRUSTED_PROXIES = *
INTERNAL_TOKEN                = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYmYiOjE2NjkxMzA3NTh9.Mt5I8E6OAjLu4ohI_Gwcw_5eR5HAn83_4f42yDBCuqM
PASSWORD_HASH_ALGO            = pbkdf2

[service]
DISABLE_REGISTRATION              = false
REQUIRE_SIGNIN_VIEW               = false
REGISTER_EMAIL_CONFIRM            = false
ENABLE_NOTIFY_MAIL                = false
ALLOW_ONLY_EXTERNAL_REGISTRATION  = false
ENABLE_CAPTCHA                    = false
DEFAULT_KEEP_EMAIL_PRIVATE        = false
DEFAULT_ALLOW_CREATE_ORGANIZATION = true
DEFAULT_ENABLE_TIMETRACKING       = true
NO_REPLY_ADDRESS                  = noreply.localhost

[lfs]
PATH = /data/git/lfs

[mailer]
ENABLED = false

[openid]
ENABLE_OPENID_SIGNIN = true
ENABLE_OPENID_SIGNUP = true

[repository.pull-request]
DEFAULT_MERGE_STYLE = merge

[repository.signing]
DEFAULT_TRUST_MODEL = committer

EOH 
}
      driver = "docker"

      service {
        name = "gitea"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.gitea.entrypoints=http",
          "traefik.http.routers.gitea.rule=Host(`gitea.homelab.local`)",
           ]
        check {
          type = "http"
          path = "/"
          interval = "60s"
          timeout = "20s"      
         }
         }
 

      service {
        name = "gitea-ssh"
        tags = ["gitea", "ssh"]
        port = "ssh"
      }

      config {
        image = "gitea/gitea:1.18.0-rc0"

        ports = ["http", "ssh"]
        volumes = [
          "/mnt/configs/docker-data/gitea:/data",
          "local/app.ini:/data/gitea/conf/app.ini"
         ]
        }


      env {
        # owner of `/data/gitea` on host.
        USER_UID = 1000
        USER_GID = 1000
      }

      resources {
        cpu    = 200
        memory = 300
      }
    }
  }
}

