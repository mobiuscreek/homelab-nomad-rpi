
job "joplin" { 
  region      = "global"
  datacenters = ["homecluster"]
  type = "service"
  priority = 60

  group "main" {
    network {
      mode = "bridge"
      port "http" {
        to = 22300
      }
    }

    service {
      name = "joplin"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.joplin.entrypoints=http",
        "traefik.http.routers.joplin.rule=Host(`joplin.homelab.local`)",
      ]

      check {
        type     = "http"
        path     = "/api/ping"
        interval = "30s"
        timeout  = "2s"
      }
    }

    task "server" {
      driver = "docker"
      config {
        image = "joplin/server:2.7.3-beta"
        ports = ["http"]
      }

      template {
        destination = "secrets/env"
        env = true
        data = <<-EOF
        DB_CLIENT=pg
        APP_BASE_URL=http://joplin.homelab.local
        EOF
      }

      resources {
        memory = 128
      }
    }

    task "postgres" {
      driver = "docker"
      config {
        image = "postgres:13-alpine"

        volumes = [
          "/opt/joplin/postgres:/var/lib/postgresql/data",
        ]
      }

      env {
        POSTGRES_USER = "joplin"
        POSTGRES_PASSWORD = "joplin"
        POSTGRES_DB = "joplin"
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



