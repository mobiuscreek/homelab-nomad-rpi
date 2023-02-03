job "mediatracker" {
  region      = "global"
  datacenters = ["homecluster"]
  type        = "service"
  constraint {
  attribute = "${node.unique.name}"
  operator = "="
  value = "node3"
  }

  group "mediatracker" {
    count = 1
    network {
      port "http" {
           static = 7481
           to = 7481
       }
    }

    task "mediatracker" {
      driver = "docker"

      config {
        image        = "bonukai/mediatracker:0.1.0-beta.19"
        ports        = ["http"]
        volumes = [
          "/mnt/configs/docker-data/mediatracker/.config/mediatracker/data:/storage",
          "/mnt/configs/docker-data/mediatracker/assets:/assets"
        ]
      }

      env {
        PUID = "1000"
        PGID = "1000"
        SERVER_LANG = "en"
        TMDB_LANG = "en"
      }

      service {
        port = "http"
        name = "mediatracker"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.mediatracker.entrypoints=http",
          "traefik.http.routers.mediatracker.rule=Host(`mediatracker.homelab.local`)",
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

