# Djosix 2017.05.30

local label_color='white'
local user_color='green';
test $UID -eq 0 && user_color='red'

PROMPT="
%{$fg_bold[$label_color]%}%n@%m \
%{$fg_bold[$user_color]%}%d
%{$fg_bold[$label_color]%}%(!.#.>) %{$reset_color%}"
