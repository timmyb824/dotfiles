alias dockerps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.CreatedAt}}\t{{.Networks}}\t{{.State}}\t{{.RunningFor}}"'
alias dockerports='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}\t{{.State}}\t{{.RunningFor}}"'
alias podmanps='podman ps --format "table {{.ID}}\t{{.Names}}\t{{.CreatedAt}}\t{{.Networks}}\t{{.State}}\t{{.RunningFor}}"'
alias podmanports='podman ps --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}\t{{.State}}\t{{.RunningFor}}"'