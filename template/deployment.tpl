
# templates/common/deployment.tpl
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "yourchart.fullname" . }}
  labels:
    {{- include "yourchart.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "yourchart.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "yourchart.name" . }}
        app.kubernetes.io/instance: {{ .Release.Name }}
        {{- toYaml .Values.podLabels | nindent 8 }}
      annotations:
        {{- toYaml .Values.podAnnotations | nindent 8 }}
    spec:
      {{- if .Values.serviceAccount.create }}
      serviceAccountName: {{ include "yourchart.serviceAccountName" . }}
      {{- else if .Values.serviceAccount.name }}
      serviceAccountName: {{ .Values.serviceAccount.name }}
      {{- end }}
      
      {{- if .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml .Values.imagePullSecrets | nindent 8 }}
      {{- end }}
      
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.service.targetPort }}
              name: http
          env:
            {{- if .Values.env.enabled }}
            {{- toYaml .Values.env | nindent 12 }}
            {{- end }}
          livenessProbe:
            {{- if and .Values.livenessProbe.enabled .Values.livenessProbe.httpGet }}
            httpGet:
              path: {{ .Values.livenessProbe.httpGet.path }}
              port: {{ .Values.livenessProbe.httpGet.port }}
            initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
            successThreshold: {{ .Values.livenessProbe.successThreshold }}
            timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
            {{- end }}
          readinessProbe:
            {{- if and .Values.readinessProbe.enabled .Values.readinessProbe.httpGet }}
            httpGet:
              path: {{ .Values.readinessProbe.httpGet.path }}
              port: {{ .Values.readinessProbe.httpGet.port }}
            initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
            successThreshold: {{ .Values.readinessProbe.successThreshold }}
            timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
            {{- end }}
          resources:
            {{- if .Values.resources.enabled }}
            limits:
              cpu: "{{ .Values.resources.limits.cpu }}"
              memory: "{{ .Values.resources.limits.memory }}"
            requests:
              cpu: "{{ .Values.resources.requests.cpu }}"
              memory: "{{ .Values.resources.requests.memory }}"
            {{- end }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          volumeMounts:
            {{- if .Values.volumeMounts.create }}
            {{- range .Values.volumeMounts.mountPoint }}
            - name: {{ .name }}
              mountPath: {{ .mountPath }}
              {{- if .readOnly }}
              readOnly: true
              {{- end }}
              {{- if .subPath }}
              subPath: {{ .subPath }}
              {{- end }}
            {{- end }}
            {{- end }}
      {{- if or .Values.nodeSelector .Values.tolerations .Values.affinity }}
      nodeSelector:
        {{- toYaml .Values.nodeSelector | nindent 8 }}
      tolerations:
        {{- toYaml .Values.tolerations | nindent 8 }}
      affinity:
        {{- toYaml .Values.affinity | nindent 8 }}
      {{- end }}
      
      {{- if .Values.podSecurityContext }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      {{- end }}
      
      {{- if .Values.volumes.create }}
      volumes:
        {{- range .Values.volumes.mount }}
        - name: {{ .name }}
          {{- if .emptyDir }}
          emptyDir: {}
          {{- end }}
          {{- if .configMap }}
          configMap:
            name: {{ .configMap.name }}
            defaultMode: {{ .configMap.defaultMode }}
            optional: {{ .configMap.optional }}
            {{- if .configMap.items }}
            items:
              {{- range .configMap.items }}
              - key: {{ .key }}
                path: {{ .path }}
              {{- end }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
