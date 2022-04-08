job "gitea" {
  datacenters = ["homecluster"]
  type        = "service"

  group "app" {
    count = 1

    network {
       
      port "http" {
        static = 3000
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

    task "gitea" {
      driver = "docker"

      service {
        name = "gitea"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.gitea.entrypoints=http",
          "traefik.http.routers.gitea.rule=Host(`gitea.homelab.local`)",
           ]
        check {
          type = "http"
          path = "/"
          interval = "60s"
          timeout = "20s"      
         }
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
          "/config:/etc/gitea",
          "/data:/data"
         ]
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

