#!/usr/bin/env bash
# Build from a committed Jaz snapshot plus this repository's Docker overlay.
set -euo pipefail

REPO="${REPO:-augustinast/testing}"
JAZ_VERSION="${JAZ_VERSION:-latest}"
PLATFORM="${PLATFORM:-linux/amd64}"
IMAGES="${IMAGES:-jaz-backend jaz-web jaz-fullstack jaz-fullstack-custom}"
PUSH="${PUSH:-true}"

deploy_root="$(cd "$(dirname "$0")/../.." && pwd)"
JAZ_SOURCE="${JAZ_SOURCE:-${deploy_root}/../jaz}"
JAZ_REF="${JAZ_REF:-$(cat "${deploy_root}/deploy/docker/jaz-source-ref")}"
jaz_revision="$(git -C "${JAZ_SOURCE}" rev-parse --verify "${JAZ_REF}^{commit}")"

case "${PUSH}" in
	true)
		output=(--push)
		;;
	false)
		output=(--load)
		;;
	*)
		echo "PUSH must be true or false" >&2
		exit 1
		;;
esac

build_context="$(mktemp -d "${TMPDIR:-/tmp}/jaz-image-build.XXXXXX")"
trap 'rm -rf "${build_context}"' EXIT
git -C "${JAZ_SOURCE}" archive "${jaz_revision}" frontend backend dist/acp-adapters.json | tar -x -C "${build_context}"
mkdir -p "${build_context}/deploy"
cp -R "${deploy_root}/deploy/docker" "${build_context}/deploy/docker"

for image in ${IMAGES}; do
	case "${image}" in
		jaz-backend|jaz-web|jaz-fullstack|jaz-fullstack-custom)
			;;
		*)
			echo "Unknown image: ${image}" >&2
			exit 1
			;;
	esac
	build_args=(buildx build --platform "${PLATFORM}"
		-f "${build_context}/deploy/docker/${image}.Dockerfile"
		--build-arg JAZ_VERSION="${JAZ_VERSION}")
	if [ "${image}" = "jaz-fullstack-custom" ]; then
		build_args+=(--label "org.opencontainers.image.revision=${jaz_revision}")
	fi
	build_args+=(-t "${REPO}:${image}" "${output[@]}" "${build_context}")
	echo ">> building ${REPO}:${image} (Jaz source ${jaz_revision}, ${PLATFORM})"
	docker "${build_args[@]}"
done
