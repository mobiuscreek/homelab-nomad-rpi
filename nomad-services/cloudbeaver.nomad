job "cloudbeaver" {
  region      = "global"
  datacenters = ["homecluster"]
  type        = "service"

  group "cloudbeaver" {
    count = 1
    network {
      port "http" {
           static = 8978
           to = 8978
       }
    }

    task "cloudbeaver" {
      driver = "docker"

      config {
        image        = "andrisasuke/cloudbeaver:22.3.3"
        ports        = ["http"]
        volumes = [
          "/mnt/configs/docker-data/cloudbeaver/workspace:/opt/cloudbeaver/workspace",
        ]
      }

      env {
        PUID = "1000"
        PGID = "1000"
      }

      service {
        port = "http"
        name = "cloudbeaver"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.cloudbeaver.entrypoints=http",
          "traefik.http.routers.cloudbeaver.rule=Host(`cloudbeaver.homelab.local`)",
        ]
        check {
          type     = "http"
          path     = "/"
          interval = "60s"
          timeout  = "20s"

          check_restart {
            limit = 3
            grace = "240s"
          }
        }
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}

