job "emulatorjs" {
  region      = "global"
  datacenters = ["homecluster"]
  type        = "service"
  constraint {
     attribute = "${node.unique.name}"
     value = "node3"
   }

  group "emulatorjs" {
    count = 1
    network {
      mode = "bridge"
      port "http" {
           static = 8080
           to = 80
       }
      port "ui" {
           static = 3000
           to = 3000
           }
    }

    task "emulatorjs" {
      driver = "docker"

      config {
        image        = "lscr.io/linuxserver/emulatorjs"
        ports        = ["http", "ui"]
        volumes = [
          "/local/emulatorjs/config:/config",
          "/data/emulatorjs/data:/data",
        ]
      }

      env {
        PUID = "1000"
        PGID = "1000"
        TZ="Europe/London"
        SUBFOLDER="/"
      }

      service {
        port = "http"
        name = "emulatorjs"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.emulatorjs.entrypoints=http",
          "traefik.http.routers.emulatorjs.rule=Host(`emulatorjs.homelab.local`)",
          "traefik.http.services.emulatorjs.loadbalancer.server.port=3000",
          
        ]
       }
      service {
        port = "http"
          name = "emulatorjs-ui"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.emulatorjs_ui.entrypoints=http",
          "traefik.http.routers.emulatorjs_ui.rule=Host(`emulatorjs-ui.homelab.local`)",
          "traefik.http.services.emulatorjs_ui.loadbalancer.server.port=8080",
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

