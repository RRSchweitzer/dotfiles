# Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(gitfast)
fpath=( $XDG_CONFIG_HOME/ohmyzsh/plugins/gitfast $fpath )
source $ZSH/oh-my-zsh.sh

# Prompt
PROMPT='%n %{%f%b%k%}%{$fg[blue]%}%1~ %{${reset_color}%}%# $(git_prompt_info)'

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Autoload .nvmrc files
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"
  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# Ruby (Apple Silicon)
if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
  export PATH=/opt/homebrew/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi

# PATH
export PATH="$NVM_DIR/versions/node/$(nvm current)/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/scripts:$PATH"
export PATH="./node_modules/.bin:$PATH"

# Environment
export AWS_PROFILE=ryan
COREPACK_ENABLE_AUTO_PIN=0

# Aliases
alias sd="yarn start-dev"
alias pi="ssh rschweitzer@192.168.68.52"
alias big="ssh -p 78 rschweitzer@192.168.68.62"
alias run="python3 -m http.server"
alias host="sudo vim /etc/hosts"
alias flasky="export FLASK_APP=index.py && export FLASK_DEBUG=1 && flask run"
alias clean="clear && printf '\e[3J'"
alias ckey="pbcopy < ~/.ssh/id_rsa.pub"
alias bs="yarn build && yarn start"
alias rs="yarn packages/core build:dev && yarn start"
alias yi="yarn install && cd node_modules/prebid.js && npm install && cd ../../"
alias pretty="yarn prettier"
alias deletebs="git branch -vv | grep ': gone]'|  grep -v "\*" | awk '{ print $1; }' | xargs git branch -D"
alias portal="open https://portal.adthrive.com/employee"
alias startcmp="yarn build && node_modules/.bin/serve build -s -c 1"
alias bsg="yarn build-gdpr && yarn start"
alias audio="sudo kill -9 `ps ax|grep 'coreaudio[a-z]' | awk '{print $1}'`"
alias pbjs="npm run adthrive-dev"
alias gTest="gulp --max-old-space-size=8192 test"
alias tm="log stream --level debug --predicate 'subsystem == \"com.apple.TimeMachine\"'"
alias rsg="yarn packages/core build-gdpr:dev && yarn start"
alias bl="sudo pfctl -f Documents/blocklist.pf"
alias zsh="vim ~/.zshrc"
alias gb="grunt && python3 ./server.py"
alias inc="open -n /Applications/Google\ Chrome.app --args --user-data-dir=\"/tmp/chrome_dev_test\" --disable-web-security"
alias scripts='ls ~/bin ~/scripts 2>/dev/null'
alias awslog='aws sso --profile ryan login'
