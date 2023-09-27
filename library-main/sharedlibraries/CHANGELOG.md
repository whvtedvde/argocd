## 1.0.16 (24/08/2023)

### Added

- awx instance template

## 1.0.14 (17/08/2023)

### Added

- openshift logging ClusterLogging template
- openshift logging ClusterLogForwarder template


## 1.0.13 (05/07/2023)

### Added

- monitoring service monitor template

## 1.0.12 (29/06/2023)

### Added

- rbacmanager definition template

## 1.0.11 (29/06/2023)

### Fixed (1 changes)

- eso:
  - add variable to check enable ressources
- networkpolicy:
  - remove check podselector and refactor comments

### Added

- cronjob template


## 1.0.10 (27/06/2023)

### Fixed (1 changes)

- resolve job installplan

## 1.0.9 (15/06/2023)

### Added

- Add template for:
  - storage pvc

### Fixed (1 changes)

- typo on additionalLabels for some template
- fix some helm template format

## 1.0.8 (05/06/2023)

### Added

- Add template for:
  - eso clusterSecretStore

## 1.0.7 (24/05/2023)

### Fixed (1 changes)

- add CRD check on metalLB

## 1.0.6 (24/05/2023)

### Fixed (1 changes)

- none

## 1.0.5 (22/05/2023)

### Fixed (1 changes)

- fix validation rbac.rb.subject

## 1.0.4 (17/05/2023)

### Fixed (2 changes)

- fix documentation/help in each template with helm-docs

## 1.0.3 (16/05/2023)

### Fixed (2 changes)

- Remove prefix from all template
- Fixe help on all files

### Added

- Add template for:
  - mariadb
	- traefik serverTransport

## 1.0.2 (09/05/2023)

### Fixed (2 changes)

- fix a lot of bug

## 1.0.1 (09/05/2023)

### Fixed (2 changes)

- Remove prefix from all template
- Fixe help on all files

### Added

- Add template for:
  - Traefik
  - Minio
  - ESO
  - Certificate
  - Reloader
  - Workload
  - Secret / ConfigMap
  - Network

## 1.0.0 (09/05/2023)

### Added

- First release with a lot of template
