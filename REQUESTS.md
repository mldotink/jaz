# Requests

- [x] Use the supplied Postimg image as the deployment's home logo via `homeWordmark`. Packaged and live-served configuration preserve the exact URL and hidden model icons. Image loads from the deployment with HTTP 200 (1280 × 427 PNG). Published/deployed image tag `608ad64`, digest `sha256:29b319acde9257c0972d6f1bd902837e299cfb9259e914390b83a859acd68bb9`; rollout and health pass. Browser rendering remains SSO-blocked.
- [x] Add an MCP server named Customers for https://crm.jaz.chat. Verified the documented/discovered endpoint `https://crm.jaz.chat/mcp`, created enabled server `mcp_ddbf0a8ee78f61ef`, and read it back after rollout. Connection status is `needs_auth`: OAuth sign-in is required in Settings → MCP → Customers. No CRM credentials were copied and no authenticated tools are claimed.

- [x] Hide model icons in the Leeroo deployment using the existing `showModelIcons: false` appearance default. Packaged web configuration and the served `/jaz-defaults.js` both verify false. Published image tag `234e3f0`, digest `sha256:f76602b8b4788b206818a4e7da0dae7f17ecb04af3fc2ffd6470b2a223f854cb`, deployed through Leeroo Ink; rollout and health pass. GPT-6 Sol / medium and saved credential are preserved. Explicit browser appearance choices continue to override deployment defaults. Rendered browser verification remains blocked by Leeroo SSO.

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

- [x] Diagnose the screenshot's `reasoning effort medium: Invalid params`: the cloud Codex catalog lacks gpt-6.1-sol. Jaz preselects this unadvertised model for API-key auth, then tries a reasoning control the adapter omitted. Direct adapter probes reproduce the failure for gpt-6.1-sol and accept medium for gpt-6-sol.
- [x] Explain core Jaz changes before editing. An isolated branch, jaz/leeroo-codex-config-fix, uses native metadata ownership for API-key model selection and rejects unadvertised models explicitly. ACP/server/settings tests, focused races and vet pass. Core commit c39a7033 is not merged or included in this deployment image. Its API-key regression fails against the old implementation as expected; full native parity has not been certified.
- [x] Replace the obsolete chat-only custom-openai configuration with built-in openai-api-key and an advertised GPT-6 Astra / medium default. Bootstrap Codex once when the deployment supplies OPENAI_API_KEY; preserve subsequent settings and other agents. A temporary HTTP fixture verifies initial setup and preservation on restart.
- [x] Build the configuration repair image from the same pinned Jaz source fc6dfb83. Image digest: sha256:bf06b9d8225334f815f4d6372f5dcb3cb19c88006eaf4f5f4d7d72abffb49608.
- [x] Deploy the configuration repair through Leeroo Ink: ready pod uses the exact bf06b9d8 digest, Codex is enabled with API-key auth and GPT-6 Astra / medium, and the bootstrap marker exists.
- [x] Verify an actual Codex answer: the initial test failed with 401 invalid_api_key. On 2026-10-01, the user supplied a valid replacement; it was installed through Leeroo Ink and in the saved Codex API-key profile. A real GPT-6 Sol / medium session returned exactly LEEROO_READY with idle status and no error. Both scratch sessions were archived; temporary verification files were removed. Health returns 200 and rollout is complete.

- [x] Use GPT-6 Sol as requested on 2026-10-01: saved live Codex model `gpt-6-sol` with medium effort through the settings API and verified readback. Deployment source configuration matches for future builds. The running image is unchanged; settings persist on the existing volume. The deployed key still returns 401 on `/v1/models`.

- [x] Install the user-supplied replacement API key: `/v1/models` returns 200 and lists `gpt-6-sol`; Ink secret import merges only OPENAI_API_KEY and restarts the existing service. The persisted Codex profile initially retained the old key, so its API-key value was also replaced. Profile and environment now match. Real reply verification above passes; no Jaz code changes or image rebuild were needed.

- [x] Repair the existing conversation shown in the October 1 screenshot: thread 20260930T220216-a5b95522 retained its September 30 gpt-6.1-sol override and bootstrap error despite the new default. It had no native session. A guarded transaction changed only that thread's model/effort and timestamp; the prior values are recorded under `.state/20261001-hi-model-repair.json` on the data volume. History and the queued hi were preserved. Retried that queued message through the queue API: GPT-6 Sol / medium replied "Hi! What can I help you with?", status idle, no error, empty queue. Browser visual verification is SSO-blocked; live transcript API verification passes.

Model-discovery clarification: local Jaz uses the same Codex 0.159.0 with
ChatGPT OAuth and a freshly downloaded catalog containing GPT-6.1 Sol. The cloud
uses API-key auth with no model cache and advertises its bundled catalog. This
alone does not establish GPT-6.1 Sol's availability through the OpenAI API;
inference with GPT-6.1 Sol has not been retested with the replacement key. No OAuth credentials were
copied and no authentication-mode switch was performed.
