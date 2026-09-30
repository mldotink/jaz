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
- The follow-up deployment is completed below; the original local build checks apply to the identical published digest.

## Publication and deployment

- [x] Push the deployment repository. Remote `origin/main` verified at `c4d81971710add8044d0b3d255620d1d0b0bf921`.
- [x] Publish the verified image. Docker Hub/GHCR uploads were rejected, so it was published to Leeroo ECR as `leeroo-jaz:c4d8197`; registry digest matches the verified image. An initial attempt in Ink’s reserved build repository was rejected; the dedicated repository succeeds.
- [x] Deploy through Ink in Leeroo’s AWS cluster, as Augustinas clarified. Used the valid Leeroo Ink API key for workspace `august` and updated existing `jaz-mast-v5` in project `default`. Ink reports `active`; pod digest, HTTP health/web app, authenticated 8090 skill catalog/original hashes, Bots API and connected Uniforge MCP pass. The existing data volume and organisation SSO are retained. Public browser access redirects to Leeroo sign-in.

## Codex deployment configuration repair

- [x] Diagnose the screenshot's `reasoning effort medium: Invalid params`: Codex 0.159.0 lacks gpt-6.1-sol. Jaz preselects this unadvertised model for API-key auth, then tries a reasoning control the adapter omitted. Direct adapter probes reproduce the failure for gpt-6.1-sol and accept medium for gpt-6-sol.
- [x] Explain core Jaz changes before editing. An isolated branch, jaz/leeroo-codex-config-fix, uses native metadata ownership for API-key model selection and rejects unadvertised models explicitly. ACP/server/settings tests, focused races and vet pass. This core fix is not merged or included in this deployment image.
- [x] Replace the obsolete chat-only custom-openai configuration with built-in openai-api-key and an advertised GPT-6 Astra / medium default. Bootstrap Codex once when the deployment supplies OPENAI_API_KEY; preserve subsequent settings and other agents. A temporary HTTP fixture verifies initial setup and preservation on restart.
- [x] Build the configuration repair image from the same pinned Jaz source fc6dfb83. Image digest: sha256:bf06b9d8225334f815f4d6372f5dcb3cb19c88006eaf4f5f4d7d72abffb49608.
- [ ] Deploy and verify an actual Codex answer. GPT-6.1 Sol remains unavailable in the bundled runtime; upgrading it is separate work.
