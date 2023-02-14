variable "paperless_admin" {}
variable "paperless_***REMOVED***" {}
job "paperless" { 
  region      = "global"
  datacenters = ["homecluster"]
  type = "service"
  priority = 50

  group "main" {
    network {
      port "http" {
        static = 8001
        to = 8000
      }
    }

    service {
      name = "paperless"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.paperless.entrypoints=http",
        "traefik.http.routers.paperless.rule=Host(`paperless.homelab.local`)",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "30s"
        timeout  = "10s"
      }
    }

    task "paperless-ng" {
      driver = "docker"
      config {
        image = "jonaswinkler/paperless-ng:1.5.0"
        ports = ["http"]
        volumes = [
          "/mnt/configs/docker-data/paperless-ng/data:/usr/src/paperless/data",
          "/mnt/configs/docker-data/paperless-ng/media:/usr/src/paperless/media",
          "/mnt/configs/docker-data/paperless-ng/export:/usr/src/paperless/export",
          "/mnt/configs/docker-data/paperless-ng/consume:/usr/src/paperless/consume",
          ]
      }
      env {
        PAPERLESS_ADMIN_USER = "${var.paperless_admin}"
        PAPERLESS_ADMIN_PASSWORD = "${var.paperless_***REMOVED***}"
        }


      resources {
        memory = 128
      }
    }

    task "redis" {
      driver = "docker"
      config {
        image = "redis:6.0"
      }

      env {
        PAPERLESS_REDIS = "redis://${NOMAD_TASK_NAME}:6379"
      }

      resources {
        memory = 32
      }

      lifecycle {
        hook = "prestart"
        sidecar = true
      }
    }
  }
}



