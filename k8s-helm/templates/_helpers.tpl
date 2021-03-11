# Image pull secret used to access private docker.stackstorm.com Docker registry with Enterprise images
{{- define "imagePullSecret" }}
{{- if required "Missing context '.Values.professional.enabled'!" .Values.professional.enabled -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" "docker.io" (printf "%s:%s" .Values.professional.license .Values.professional.license | b64enc) | b64enc }}
{{- end -}}
{{- end }}

# Generate support Level
{{- define "supportLevel" -}}
{{- if required "Missing context '.Values.professional.enabled'!" .Values.professional.enabled -}}
Professionaal
{{- else -}}
community
{{- end -}}
{{- end }}

# Generate '-PE' suffix only when it's needed for docker images, etc
{{- define "licensedSuffix" -}}
{{ if required "Missing context '.Values.professional.enabled'!" .Values.professional.enabled }}-PE{{ end }}
{{- end -}}

# Full registry and registry path resolver
{{- define "imageRepository" -}}
{{- if .Values.global.image.registry }}
{{- .Values.global.image.registry }}/
{{- else if required "Missing context '.Values.professional.enabled'!" .Values.professional.enabled  -}}
store/
{{- end -}}
thingsboard
{{- end -}}

# Allow calling helpers from nested sub-chart
# https://stackoverflow.com/a/52024583/4533625
# https://github.com/helm/helm/issues/4535#issuecomment-477778391
# Usage: "{{ include "nested" (list . "kafka" "kafa.fullname") }}"
{{- define "nested" }}
{{- $dot := index . 0 }}
{{- $subchart := index . 1 | splitList "." }}
{{- $template := index . 2 }}
{{- $values := $dot.Values }}
{{- range $subchart }}
{{- $values = index $values . }}
{{- end }}
{{- include $template (dict "Chart" (dict "Name" (last $subchart)) "Values" $values "Release" $dot.Release "Capabilities" $dot.Capabilities) }}
{{- end }}

# Generate list of nodes for Kafka connection string, based on number of replicas and service name
{{- define "kafka-nodes" -}}
{{- $replicas := (int (index .Values "kafka" "replicaCount")) }}
{{- $clientPort := (int (index .Values "kafka" "service" "port"))}}
{{- $kafka_fullname := include "nested" (list $ "kafka" "kafka.fullname") }}
  {{- range $index0 := until $replicas -}}
    {{- $index1 := $index0 | add1 -}}
{{ $kafka_fullname }}-{{ $index0 }}.{{ $kafka_fullname }}-headless:{{ $clientPort }}{{ if ne $index1 $replicas }},{{ end }}
  {{- end -}}
{{- end -}}

# Generate list of nodes for ZooKeeper connection string, based on number of replicas and service name
{{- define "zookeeper-nodes" -}}
{{- $replicas := (int (index .Values "kafka" "zookeeper" "replicaCount")) }}
{{- $clientPort := (int (index .Values "kafka" "zookeeper" "service" "port"))}}
{{- $zookeeper_fullname := include "nested" (list $ "kafka" "zookeeper.fullname") }}
{{- range $index0 := until $replicas -}}
    {{- $index1 := $index0 | add1 -}}
{{ $zookeeper_fullname }}-{{ $index0 }}.{{ $zookeeper_fullname }}-headless:{{ $clientPort }}{{ if ne $index1 $replicas }},{{ end }}
  {{- end -}}
{{- end -}}

# Generate list of nodes for Postgres connection string, based on number of replicas and service name
{{- define "postgresql-nodes" -}}
{{- $replicas := (int (index .Values "postgresql-ha" "replicaCount")) }}
{{- $clientPort := (int (index .Values "postgresql-ha" "service" "port"))}}
{{- $postgresql_fullname := include "nested" (list $ "postgresql-ha" "postgresql-ha.postgresql") }}
{{- range $index0 := until $replicas -}}
    {{- $index1 := $index0 | add1 -}}
{{ $postgresql_fullname }}-{{ $index0 }}.{{ $postgresql_fullname }}-headless:{{ $clientPort }}{{ if ne $index1 $replicas }},{{ end }}
  {{- end -}}
{{- end -}}

# Generate list of nodes for cassandra connection string, based on number of replicas and service name
{{- define "cassandra-nodes" -}}
{{- $clientPort := (int (index .Values "cassandra" "service" "port"))}}
{{- $cassandra_fullname := include "nested" (list $ "cassandra" "cassandra.seeds") }}
{{- $cassandra_fullname }}:{{- $clientPort }}
{{- end -}}

# Generate list of nodes for redis connection string, based on number of replicas and service name
{{- define "redis-nodes" -}}
{{- $replicas := (int (index .Values "redis" "replicaCount")) }}
{{- $clientPort := (int (index .Values "redis" "master" "service" "port"))}}
{{- $redis_fullname := include "nested" (list $ "redis" "redis.fullname") }}
{{- range $index0 := until $replicas -}}
    {{- $index1 := $index0 | add1 -}}
{{ $redis_fullname }}-{{ $index0 }}.{{ $redis_fullname }}-headless:{{ $clientPort }}{{ if ne $index1 $replicas }},{{ end }}
  {{- end -}}
{{- end -}}

