job "portainer" {
  region      = "global"
  datacenters = ["homecluster"]
  type        = "service"
   constraint {
     attribute = "${node.unique.name}"
     value = "node3"
    }

  group "portainer" {
    count = 1
    network {
      port "http" {
           static = 9000
           to = 9000
       }
      port "api" {
           static = 8000
           to = 8000
       }
    }

    task "portainer" {
      driver = "docker"

      config {
        image        = "portainer/portainer"
        ports        = ["http", "api"]
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:z",
          "/data/portainer:/data",
        ]
      }


      service {
        port = "http"
        name = "portainer"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.portainer.entrypoints=http",
          "traefik.http.routers.portainer.rule=Host(`portainer.homelab.local`)",
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

