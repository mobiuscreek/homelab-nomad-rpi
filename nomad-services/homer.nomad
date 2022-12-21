job "homer" {
  region      = "global"
  datacenters = ["homecluster"]
  type        = "service"

  group "homer" {
    count = 1
    network {
      port "http" {
           static = 8080
       }
    }

    task "homer" {
      driver = "docker"

      config {
        image        = "b4bz/homer"
        ports        = ["http"]
        args = [ 
        "-bind", "9000" ]
        volumes = [
          "/configs/docker-data/homer/assets:/www/assets",
        ]
      }

      env {
        PUID = "1000"
        PGID = "1000"
      }

      service {
        port = "http"
        name = "homer"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.homer.entrypoints=http",
          "traefik.http.routers.homer.rule=Host(`homer.homelab.local`)",
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

