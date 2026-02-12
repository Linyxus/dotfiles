if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Initialize homebrew
eval (/opt/homebrew/bin/brew shellenv)

# Setup Hydro prompt symbol
# set --global hydro_symbol_prompt 'λ'
set --global hydro_symbol_prompt '>'

# Setup emacs alias
alias em="emacsclient -nc -a \"emacs -daemon\""
alias ec="emacsclient -t -a \"emacs -daemon\""
alias codex="bunx @openai/codex@latest"
alias gemini="bunx @google/gemini-cli@latest"

# Local binaries
fish_add_path ~/.local/bin

# Doom emacs
fish_add_path ~/.config/emacs/bin

# direnv
direnv hook fish | source

fish_add_path ~/.bun/bin

function po
    export http_proxy="http://127.0.0.1:7897"
    export https_proxy="http://127.0.0.1:7897"
    export all_proxy="socks5://127.0.0.1:7897"
end


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '/Users/linyxus/.opam/opam-init/init.fish' && source '/Users/linyxus/.opam/opam-init/init.fish' > /dev/null 2> /dev/null; or true
# END opam configuration

fish_add_path '/Users/linyxus/.opam/default/bin/'

# Added by `rbenv init` on Wed Feb 11 19:31:52 CST 2026
status --is-interactive; and rbenv init - --no-rehash fish | source
