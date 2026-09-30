# Requests

- [x] Update the Leeroo web image to the latest local Jaz main, including inline questions, saved answers and partial submission. Source pinned to `fc6dfb83a820b1fcde2c3cece4eb14171237d913`, also including the newly merged Bots changes.
- [x] Include the customer-planning/onboarding skills extracted from 8090, preserving their original instructions and source provenance. All six skill hashes match the extraction.
- [x] Verify the packaged build and skill availability and commit the changes. Linux amd64 image builds and starts; HTTP health/web assets, authenticated skill catalog/Bots API, original skill files in Jaz/Codex directories and existing-volume restart behaviour pass. The earlier `f70e9cc1` build loaded in the integrated browser; final `fc6dfb83` web assets pass HTTP checks.

## Verification

- Local image: `augustinast/testing:jaz-fullstack-custom`.
- Image ID: `sha256:6285bb57d48f702268a35b3332b3204d0a740946f494a299dbe85df388a925d5`.
- Build: `IMAGES=jaz-fullstack-custom PUSH=false deploy/docker/build.sh`.
- All shell scripts parse. A temporary command fixture verifies all four image commands, source staging, skill inclusion, the custom source label, local output and build-context cleanup.
- The six extracted skills remain byte-for-byte identical to `leeroo/skills`; source URLs and hashes are bundled in `8090-provenance.json`.
- Fresh runtime: web assets, Leeroo defaults and authenticated `/v1/skills` and `/v1/bots` return successfully. All six files match their original hashes in the Jaz catalog and Codex profile.
- Existing-volume restart: a user-edited Plan skill is preserved and a missing Phase Planning skill is installed; authenticated catalog access continues.
- Browser check covered the earlier `f70e9cc1` image at its unauthenticated welcome screen. The integrated browser disconnected before the final `fc6dfb83` repeat; final web assets pass HTTP checks. A credentialed migration conversation was not run in this container.
- Image publication and live deployment are separate from this local repository/image update.

## Publication and deployment

- [x] Push the deployment repository. Remote `origin/main` verified at `c4d81971710add8044d0b3d255620d1d0b0bf921`.
- [ ] Publish the verified image. Docker Hub rejects uploads without a login; the configured GHCR credential also rejects uploads because it lacks required scopes. The verified image remains local.
- [ ] Deploy the updated image after choosing the target and making the image available. Ink Cloud MCP and the saved CLI API key authenticate successfully. `uniforge-aws` Kubernetes access also works; two existing custom Jaz deployments were found. Leeroo/Uniforge and Ink Cloud are separate targets, and the target question is pending. No live service was changed.
