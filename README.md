# Dotfiles

Review existing files before linking over them.

```bash
brew bundle --file=packages/Brewfile
bash .macOS

ln -sfn "$PWD/shell/.zshrc" "$HOME/.zshrc"
ln -sfn "$PWD/shell/.p10k.zsh" "$HOME/.p10k.zsh"

mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
ln -sfn "$PWD/terminal/ghostty/config" \
  "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
```

Install NVM, Node, Claude Code, Codex, OpenCode, and FFF separately. Install the
packages listed in `packages/npm-global.txt` after Node and npm are ready.

Link agent configuration as needed:

```bash
mkdir -p "$HOME/.claude" "$HOME/.codex" "$HOME/.config/opencode"
ln -sfn "$PWD/agents/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -sfn "$PWD/agents/claude/settings.json" "$HOME/.claude/settings.json"
ln -sfn "$PWD/agents/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
ln -sfn "$PWD/agents/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
ln -sfn "$PWD/agents/codex/config.toml" "$HOME/.codex/config.toml"
ln -sfn "$PWD/agents/codex/hooks.json" "$HOME/.codex/hooks.json"
ln -sfn "$PWD/agents/opencode/cli.json" "$HOME/.config/opencode/cli.json"
ln -sfn "$PWD/agents/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
```

Never copy authentication files, `.npmrc`, service files, session data, caches,
project trust lists, SSH keys, or `.env` files.
