# k8s

Kubernetes 기반의 이미지 변환 서비스 인프라 구성 리포지토리입니다.
이 저장소는 GitOps 방식으로 관리되며, Argo CD를 통해 클러스터에 자동 배포됩니다.

## 개요

이 저장소는 이미지 → ASCII 변환 서비스의 인프라 및 어플리케이션을 Kubernetes 위에 배포하기 위해 구성되었습니다.
모든 리소스는 Kustomize를 기반으로 환경별 Overlay 구조로 관리되며, Argo CD를 통해 Git 리포지토리 변경 사항이 자동으로 반영됩니다.

## 디렉토리 구조

```sh
.
├── apps/                   # 어플리케이션별 Kustomize 디렉토리
│   ├── api/                # Spring Boot 기반 API 서버
│   ├── auth/               # NestJS 기반 인증 서버
│   ├── frontend/           # React 기반 프론트엔드
│   ├── rabbitmq/           # RabbitMQ 메시지 브로커
│   ├── websocket/          # WebSocket 서버
│   └── worker/             # Rust 기반 ASCII 변환 워커
│
├── clusters/
│   └── image-converter/    # Argo CD 애플리케이션 정의
│       ├── apps/           # 각 앱에 대한 Application 매니페스트
│       └── infrastructures/ # 인프라 Application 매니페스트
│
├── infrastructures/        # 인프라 구성 요소
│   ├── argocd/             # Argo CD Ingress 설정
│   ├── base/               # 공통 네임스페이스 정의
│   ├── cert-manager/       # TLS 인증서 발급자 및 인증서 설정
│   ├── ingress/            # ingress-nginx 설정
│   └── nfs/                # 외부 NFS 마운트를 위한 PV/PVC 설정
```

## 주요 구성

**GitOps with Argo CD**

모든 앱은 `clusters/image-converter/apps/*.yaml`에 정의된 Argo CD 애플리케이션으로 관리됩니다.
환경은 현재 `dev`만 존재하며, 필요시 `prod` overlay 추가 가능.

**Kustomize 기반 구성**

`apps/*/base`: 공통 배포 리소스 (Deployment, Service 등)
`apps/*/overlays/dev`: 환경별 설정 (Secret, SealedSecret, HPA 등)

**Secret 관리: Sealed Secrets**

모든 민감한 정보는 `kubeseal`을 통해 암호화되며, Git에 안전하게 커밋됩니다.

**Storage: NFS 마운트**

GCP VM에서 운영 중인 NFS 서버를 외부 PersistentVolume으로 마운트합니다.
`infrastructures/nfs`에서 PV/PVC 정의

**HTTPS: cert-manager + ingress-nginx**

`cert-manager`와 Let's Encrypt를 통해 자동 인증서를 발급합니다.
`infrastructures/ingress`에서 `ingress-nginx` 관련 리소스를 관리합니다.

## Bootstrap

```
# 1. Argo CD, cert-manager, ingress-nginx 설치
kubectl apply -k infrastructures/base
kubectl apply -k infrastructures/cert-manager
kubectl apply -k infrastructures/ingress
kubectl apply -k infrastructures/argocd

# 2. Argo CD UI 접속 후 로그인
# 3. clusters/image-converter/kustomization.yaml 을 통해 App of Apps 구성
kubectl apply -f clusters/image-converter/kustomization.yaml
```

## Future Enhancements

- HorizontalPodAutoscaler 설정 (apps/*/overlays/dev/hpa.yaml)
- StatefulSet 기반의 Redis/PostgreSQL 클러스터 구성
- Monitoring (Prometheus + Grafana)
- Log Aggregation (Loki or ELK)

## Refrences

- 《쿠버네티스 교과서》 | 엘튼 스톤맨 저, 심효섭 역https://product.kyobobook.co.kr/detail/S000208711643

- 《GitOps Cookbook》 | 나탈리 빈토, 알렉스 소토 부에노 저, 이병준 역https://ebook-product.kyobobook.co.kr/dig/epd/ebook/E000010494149

- kubectl 공식 문서 | https://kubectl.docs.kubernetes.io/

- Argo CD 공식 문서 | https://argo-cd.readthedocs.io/en/stable/
