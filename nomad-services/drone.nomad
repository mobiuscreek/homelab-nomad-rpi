job "drone" { 
  region      = "global"
  datacenters = ["homecluster"]
  type = "service"
  priority = 50
  constraint {

      attribute = "${node.unique.name}"
      operator = "="
      value = "node3"
  }

  group "drone" {
    network {
      port "http" {
        static = 3001
        to = 80
        }
       port "http1" {
        static = 9001
        to = 9000
        }
       port "http2" {
        static = 3002
        to = 3000
       }
     }


    task "drone" {
      driver = "docker"
      config {
        image = "drone/drone:2.16.0"
        ports = ["http", "http1"]
        volumes = ["/var/run/docker.sock:/var/run/docker.sock",
                   "/mnt/configs/docker-data/drone:/data"]
      }        
       service {
         name = "drone"
         port = "http"

         tags = [
           "traefik.enable=true",
           "traefik.http.routers.drone.entrypoints=http",
           "traefik.http.routers.drone.rule=Host(`drone.homelab.local`)",
         ]

         check {
           type     = "http"
           path     = "/api/ping"
           interval = "30s"
           timeout  = "2s"
         }
      }
       env {
        DRONE_DATABASE_DRIVER="sqlite3"
       # DRONE_DATABASE_DATASOURCE="/data/drone/database.sqlite"
        DRONE_GITEA_SERVER="http://gitea.homelab.local"
        DRONE_GIT_ALWAYS_AUTH=false
        #DRONE_RPC_SECRET="$(echo ${HOSTNAME} | openssl dgst -md5 -hex)"
        DRONE_RPC_SECRET = "9c3921e3e748aff725d2e16ef31fbc42"
        DRONE_SERVER_PROTO="http"
        DRONE_SERVER_HOST="drone.homelab.local"
        DRONE_TLS_AUTOCERT=false
        GITEA_ADMIN_USER="***REMOVED***"
        DRONE_USER_CREATE="username:${GITEA_ADMIN_USER},machine:false,admin:true,token:${DRONE_RPC_SECRET}"
        DRONE_GITEA_CLIENT_ID="146a9b93-6bd5-46a0-a1d2-f2e4f2f59f45"
        DRONE_GITEA_CLIENT_SECRET="gto_fcwppn5m5btcumbjhr2wrp32l4jt7nu7tikk6tw3zevlk3qkvdrq"
        
      }

      resources {
        memory = 128
      }
      lifecycle {
        hook = "prestart"
        sidecar = true
      }
    }

    task "drone-runner" {
      driver = "docker"
      config {
        image = "drone/drone-runner-docker:1.8.3"
        ports = ["http2"]
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock",
        ]
      }

      env {
        DRONE_RPC_PROTO="http"
        #DRONE_RPC_HOST="http://${NOMAD_ADDR_http1}"
        DRONE_RPC_HOST="drone.homelab.local"
        DRONE_RPC_SECRET = "9c3921e3e748aff725d2e16ef31fbc42"
        DRONE_RUNNER_NAME="${HOSTNAME}-runner"
        DRONE_RUNNER_CAPACITY="2"
        DRONE_DEBUG=true
        DRONE_TRACE=false
      }
      resources {
        memory = 32
      }

    }
  }
}



