# Switch Claude Code between client-owned Azure AI Foundry subscriptions.
#
# The API keys are client credentials and are NOT in this repo. Put them in
# ~/.zshrc.local (untracked), which is sourced before this file:
#
#   export INCONTEXT_FOUNDRY_API_KEY=...
#   export SITTADEL_FOUNDRY_API_KEY=...
#
# Without those set, the functions refuse to switch rather than silently
# authenticating with an empty key.

use-incontext-foundry() {
    if [ -z "$INCONTEXT_FOUNDRY_API_KEY" ]; then
        echo "INCONTEXT_FOUNDRY_API_KEY not set — add it to ~/.zshrc.local" >&2
        return 1
    fi
    export CLAUDE_CODE_USE_FOUNDRY=1
    export ANTHROPIC_FOUNDRY_API_KEY="$INCONTEXT_FOUNDRY_API_KEY"
    export ANTHROPIC_DEFAULT_SONNET_MODEL="claude-sonnet-5"
    export ANTHROPIC_DEFAULT_HAIKU_MODEL="claude-haiku-4-5"
    export ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-4-8"
    export ANTHROPIC_FOUNDRY_RESOURCE=incontext-azure-foundry-eastus2
    export AZURE_RESOURCE_NAME=incontext-azure-foundry-eastus2
    export ENABLE_PROMPT_CACHING_1H=1
    export CLAUDE_CODE_ENABLE_AUTO_MODE=1
    echo "Switched to InContext Azure Foundry subscription"
}

use-sittadel-foundry() {
    if [ -z "$SITTADEL_FOUNDRY_API_KEY" ]; then
        echo "SITTADEL_FOUNDRY_API_KEY not set — add it to ~/.zshrc.local" >&2
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
}

# Default to the Claude Code subscription; the functions above opt in per shell.
export CLAUDE_CODE_USE_FOUNDRY=0
