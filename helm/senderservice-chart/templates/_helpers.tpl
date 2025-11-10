{{/*
Define chart name
*/}}
{{- define "senderservice.name" -}}
{{ .Chart.Name }}
{{- end -}}

{{/*
Define a fully qualified name (Used in Service/Deployment name)
*/}}
{{- define "senderservice.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end -}}

{{/*
Chart Name and Version for 'labels'
*/}}
{{- define "senderservice.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Selector labels (Used in Deployment matchLabels and Service selector)
*/}}
{{- define "senderservice.selectorLabels" -}}
app.kubernetes.io/name: {{ include "senderservice.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels (Used in Deployment metadata and Service metadata)
This template provides the full set of recommended Kubernetes labels.
*/}}
{{- define "senderservice.labels" -}}
helm.sh/chart: {{ include "senderservice.chart" . }}
{{ include "senderservice.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}