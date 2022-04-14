job "vaultwarden" {
  region      = "global"
  datacenters = ["homecluster"]
  type        = "service"

  group "vaultwarden" {
    count = 1
    network {
      port "http" {
           static = 7000
           to = 80
       }
    }

    task "vaultwarden" {
      driver = "docker"

      config {
        image        = "vaultwarden/server:1.24.0"
        ports        = ["http"]
        volumes = [
          "/data/vw-data/:/data/",
        ]
      }

      service {
        port = "http"
        name = "vaultwarden"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.vaultwarden_https.rule=Host(`vaultwarden.homelab.local`)",
          "traefik.http.routers.vaultwarden_https.entrypoints=https",
          "traefik.http.routers.vaultwarden_https.tls.certresolver=letsEncrypt",
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
        cpu    = 80
        memory = 128
      }
    }
  }
}

