{{- if eq .chezmoi.os "linux" -}}
[[ -e "/home/tbryant/oracle-cli/lib/python3.11/site-packages/oci_cli/bin/oci_autocomplete.sh" ]] && source "/home/tbryant/oracle-cli/lib/python3.11/site-packages/oci_cli/bin/oci_autocomplete.sh"
{{- end }}

eval "$(op completion zsh)"; compdef _op op
source <(chezmoi completion zsh)

if command -v ngrok &>/dev/null; then
eval "$(ngrok completion)"
fi
