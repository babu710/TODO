 docker version
Client:
 Version:           26.1.3
 API version:       1.45
 Go version:        go1.22.2
 Git commit:        26.1.3-0ubuntu1~24.04.1
 Built:             Mon Oct 14 14:29:26 2024
 OS/Arch:           linux/amd64
 Context:           default

Server:
 Engine:
  Version:          26.1.3
  API version:      1.45 (minimum version 1.24)
  Go version:       go1.22.2
  Git commit:       26.1.3-0ubuntu1~24.04.1
  Built:            Mon Oct 14 14:29:26 2024
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.7.24
  GitCommit:
 runc:
  Version:          1.1.12-0ubuntu3.1
  GitCommit:
 docker-init:
  Version:          0.19.0
  GitCommit:
root@vsphere3:/home/vsphere# docker compose version
Docker Compose version v2.27.0
root@vsphere3:/home/vsphere# netstat -tulpn
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 127.0.0.54:53           0.0.0.0:*               LISTEN      666/systemd-resolve
tcp        0      0 127.0.0.1:41013         0.0.0.0:*               LISTEN      16324/containerd
tcp        0      0 0.0.0.0:3000            0.0.0.0:*               LISTEN      32275/docker-proxy
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      666/systemd-resolve
tcp        0      0 0.0.0.0:5432            0.0.0.0:*               LISTEN      12365/postgres
tcp        0      0 0.0.0.0:5433            0.0.0.0:*               LISTEN      32061/docker-proxy
tcp        0      0 0.0.0.0:5000            0.0.0.0:*               LISTEN      32176/docker-proxy
tcp6       0      0 :::3000                 :::*                    LISTEN      32281/docker-proxy
tcp6       0      0 :::22                   :::*                    LISTEN      1/init
tcp6       0      0 :::5432                 :::*                    LISTEN      12365/postgres
tcp6       0      0 :::5433                 :::*                    LISTEN      32067/docker-proxy
tcp6       0      0 :::5000                 :::*                    LISTEN      32184/docker-proxy
udp        0      0 127.0.0.54:53           0.0.0.0:*                           666/systemd-resolve
udp        0      0 127.0.0.53:53           0.0.0.0:*                           666/systemd-resolve
udp        0      0 172.16.1.121:68         0.0.0.0:*                           614/systemd-network
root@vsphere3:/home/vsphere# pwd
/home/vsphere
root@vsphere3:/home/vsphere# cat docker-compose.yml
version: "3.9"
services:
  db:
    image: postgres:14
    environment:
      POSTGRES_PASSWORD: todo_pass
      POSTGRES_USER: todo_user
      POSTGRES_DB: tododb
    volumes:
      - db_data:/var/lib/postgresql/data
      - ./todo-app/db/init.sql:/docker-entrypoint-initdb.d/init.sql
    restart: always # Ensures container restarts on failure or reboot
    ports:
      - "5433:5432"
    networks:
      - todo_network
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "todo_user", "-d", "tododb"]
      interval: 10s
      retries: 5
      start_period: 10s
      timeout: 5s

  backend:
    build: ./todo-app/backend
    ports:
      - "5000:5000"
    environment:
      - DATABASE_HOST=db
      - DB_USER=todo_user
      - DB_PASS=todo_pass
      - DB_NAME=tododb
    depends_on:
      - db
    restart: always # Ensures container restarts on failure or reboot
    networks:
      - todo_network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      retries: 5
      start_period: 10s
      timeout: 5s

  frontend:
    build: ./todo-app/frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend
    networks:
      - todo_network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/"]
      interval: 30s
      retries: 5
      start_period: 10s
      timeout: 5s

volumes:
  db_data:

networks:
  todo_network:
    driver: bridge
