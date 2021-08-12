source ~/antigen.zsh
source ~/.nvm/nvm.sh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle osx
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle npm
antigen bundle yarn
antigen bundle Composer
antigen bundle command-not-found
export NVM_AUTO_USE=true
antigen bundle lukechilds/zsh-nvm

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting
#antigen bundle zsh-users/sudo
#antigen bundle zsh-users/vscode

# Load the theme.
antigen theme https://github.com/denysdovhan/spaceship-prompt spaceship

cecho () {
  local _color=$1; shift
  echo -e "$(tput setaf $_color)$@$(tput sgr0)"
}
black=0;
red=1;
green=2;
yellow=3;
blue=4;
pink=5;
cyan=6;
white=7;

alias glff="git pull --ff-only"
alias reset-packages="rm -rf node_modules && yarn install"
alias reset-packages="rm -rf node_modules && yarn install"

function gpr() {
  git push --set-upstream origin $(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')
  gh pr create --title "$1" --body "" --assignee tbekaert --label "Do not merge (WIP)" --draft
}

function hotfix() {
  cecho $green "→ Commit and push hotfix"
  git commit -m "$1"
  git push
  HASH=$(git rev-parse HEAD)
  cecho $cyan "Commit hash: $HASH"
  cecho $green "→ Updating staging"
  git checkout staging
  git reset --hard origin/staging
  cecho $green "→ Cherry pick commit and push it on staging"
  echo "git cherry-pick $HASH"
  git cherry-pick $HASH
  git push
  cecho $green "→ Go back to master branch"
  git checkout -
}

function mergeOn() {
  BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
  MERGE_ON="$1"
  HAS_CHANGED_FILES=$(git status --porcelain)
  if [ -n "${HAS_CHANGED_FILES}" ]; then
    cecho $red "→ Uncommited change detected, stashing"
    git stash save
  fi
  cecho $green "→ Switching to $MERGE_ON and update local version"
  git checkout $MERGE_ON
  git reset --hard origin/$MERGE_ON
  cecho $green "→ Merging branch $BRANCH_NAME"
  git merge $BRANCH_NAME --no-edit
  git push
  cecho $green "→ Switching back to $BRANCH_NAME"
  git checkout $BRANCH_NAME
  if [ -n "${HAS_CHANGED_FILES}" ]; then
    cecho $red "→ Restoring uncommited changes"
    git stash pop
  fi
}

alias prl="gh pr list"
alias pro="gh pr view --web"
alias prr="gh pr ready"
alias prc="gh pr checkout"

# Tell Antigen that you're done.
antigen apply

[[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh # This loads NVM

