# load brew
if [[ "$(uname -p)" == arm && "$(uname -a)" == *Darwin* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ "$(uname -a)" == Linux* ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

