# Switch Claude Code between client-owned Azure AI Foundry subscriptions.
#
# The API keys are client credentials and are NOT in this repo. Put them in
# ~/.shell.local (untracked), which is sourced before this file. The older
# ~/.zshrc.local is still sourced too, so existing machines keep working:
#
#   export INCONTEXT_FOUNDRY_API_KEY=...
#   export SITTADEL_FOUNDRY_API_KEY=...
#
# Without those set, the functions refuse to switch rather than silently
# authenticating with an empty key.

use-incontext-foundry() {
    # As of the 2026-08-31 APIM cutover, this routes through the APIM gateway
    # (not direct to Foundry) so usage gets metered in App Insights. See
    # vault: Projects/InContext Solutions/AI/Foundry AI Tooling.md
    #
    # INCONTEXT_FOUNDRY_API_KEY must hold the APIM subscription primaryKey
    # (mint via the runbook in that note), not a raw Foundry resource key.
    if [ -z "$INCONTEXT_FOUNDRY_API_KEY" ]; then
        echo "INCONTEXT_FOUNDRY_API_KEY not set — add it to ~/.shell.local" >&2
        return 1
    fi
    export CLAUDE_CODE_USE_FOUNDRY=1
    export ANTHROPIC_FOUNDRY_BASE_URL="https://incontext-azure-foundry-aigateway.azure-api.net/incontext-azure-foundry-eastus2/anthropic"
    # Claude Code's Foundry client reads ANTHROPIC_FOUNDRY_API_KEY specifically
    # (not ANTHROPIC_API_KEY) — confirmed against CLI 2.1.258. Setting the
    # wrong var here means no x-api-key header goes out at all, which APIM
    # reports as "missing subscription key" (not "invalid").
    export ANTHROPIC_FOUNDRY_API_KEY="$INCONTEXT_FOUNDRY_API_KEY"
    unset ANTHROPIC_API_KEY
    unset ANTHROPIC_FOUNDRY_RESOURCE
    unset AZURE_RESOURCE_NAME
    export ANTHROPIC_DEFAULT_SONNET_MODEL="claude-sonnet-5"
    export ANTHROPIC_DEFAULT_HAIKU_MODEL="claude-haiku-4-5"
    export ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-5"
    export ENABLE_PROMPT_CACHING_1H=1
    export CLAUDE_CODE_ENABLE_AUTO_MODE=1
    echo "Switched to InContext Azure Foundry subscription (via APIM gateway)"
    # Always paired with yolo — this switch is only ever a prelude to opening
    # Claude Code against the InContext subscription, never a standalone step.
    yolo
}

use-sittadel-foundry() {
    if [ -z "$SITTADEL_FOUNDRY_API_KEY" ]; then
        echo "SITTADEL_FOUNDRY_API_KEY not set — add it to ~/.shell.local" >&2
        return 1
    fi
    export CLAUDE_CODE_USE_FOUNDRY=1
    export ANTHROPIC_FOUNDRY_API_KEY="$SITTADEL_FOUNDRY_API_KEY"
    export ANTHROPIC_DEFAULT_SONNET_MODEL="claude-sonnet-4-6"
    export ANTHROPIC_DEFAULT_HAIKU_MODEL="claude-haiku-4-5"
    export ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-4-7"
    export ANTHROPIC_FOUNDRY_RESOURCE=foundry-sittadel-prod
    export AZURE_RESOURCE_NAME=foundry-sittadel-prod
    export ENABLE_PROMPT_CACHING_1H=1
    export CLAUDE_CODE_ENABLE_AUTO_MODE=1
    echo "Switched to Sittadel Azure Foundry subscription"
    # Always paired with yolo — this switch is only ever a prelude to opening
    # Claude Code against the Sittadel subscription, never a standalone step.
    yolo
}

# Default to the Claude Code subscription; the functions above opt in per shell.
export CLAUDE_CODE_USE_FOUNDRY=0
