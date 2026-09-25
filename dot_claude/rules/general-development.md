1. Do not automatically commit changes unless explicitly asked to do so.
2. When referencing a vault secret in Kubernetes with the argocd-vault-plugin, an annotation is not necessary if you use the full path, such as `"<path:secret/data/argocd#SOME_SECRET>"`. This approach enables referencing secrets from multiple paths, while an annotation is limited to a single path.
