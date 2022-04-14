job "traefik" {
  region      = "global"
  datacenters = ["homecluster"]
  type        = "system"

  group "traefik" {
    count = 1

    network {
      port "http" {
        static = 80
      }
     
      port "https" {
        static = 443
      }

      port "api" {
        static = 8081
      }
    }

    service {
      name = "traefik"

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:v2.5"
        network_mode = "host"
        ports = ["http", "api", "https"]

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
          "/var/run/docker.sock:/var/run/docker.sock",
          "/local/traefik/letsencrypt:/etc/traefik/letsencrypt",
        ]
      }

      template {
        data = <<EOF
[entryPoints]
    [entryPoints.http]
    address = ":80"
    [entryPoints.traefik]
    address = ":8081"
    [entryPoints.https]
    address = ":443"

[certificatesResolvers.letsEncrypt.acme]
  email = "test@example.com"
  storage = "/etc/traefik/letsencrypt/acme.json"
  tlsChallenge = true
#  [certificatesResolvers.letsEncrypt.acme.httpChallenge]
    # used during the challenge
#    entryPoint = "http"

[api]
    dashboard = true
    insecure  = true
[log]
    level = "DEBUG"
[providers.docker]
# Enable Consul Catalog configuration backend.
[providers.consulCatalog]
    prefix           = "traefik"
    exposedByDefault = false

    [providers.consulCatalog.endpoint]
      address = "127.0.0.1:8500"
      scheme  = "http"
EOF

        destination = "local/traefik.toml"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}

