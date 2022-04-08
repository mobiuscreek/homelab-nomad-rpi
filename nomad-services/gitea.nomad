job "gitea" {
  datacenters = ["homecluster"]
  type        = "service"

  group "app" {
    count = 1

    network {
      port "http" {
        to = 3000
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

    task "web" {
      driver = "docker"

      service {
        name = "gitea-web"
        tags = ["gitea", "web"]
        port = "http"
      }

      service {
        name = "gitea-ssh"
        tags = ["gitea", "ssh"]
        port = "ssh"
      }

      config {
        image = "gitea/gitea:latest"

        ports = ["http", "ssh"]
        volumes = [
          "local/gitea.ini:/data/gitea/conf/app.ini",
          "/data:/data/gitea/"
         ]
        }

      template {
        source = "local/app.ini"
        destination = "local/gitea.ini" # Rendered template.
        change_mode = "restart"

        # HACK:
        # https://github.com/hashicorp/nomad/issues/5020#issuecomment-778608068
        perms = "777"
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

