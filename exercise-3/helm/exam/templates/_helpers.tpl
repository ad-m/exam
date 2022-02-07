{{/*
Expand the name of the chart.
*/}}
{{- define "exam.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "exam.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "exam.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "exam.labels" -}}
helm.sh/chart: {{ include "exam.chart" . }}
{{ include "exam.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "exam.selectorLabels" -}}
app.kubernetes.io/name: {{ include "exam.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "exam.flower.selectorLabels" -}}
app.kubernetes.io/component: flower
{{ include "exam.selectorLabels" . }}
{{- end }}

{{- define "exam.worker.selectorLabels" -}}
app.kubernetes.io/component: worker
{{ include "exam.selectorLabels" . }}
{{- end }}

{{- define "exam.producer.selectorLabels" -}}
app.kubernetes.io/component: producer
{{ include "exam.selectorLabels" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "exam.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "exam.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
