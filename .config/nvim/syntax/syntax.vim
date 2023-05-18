autocmd Syntax * syntax match Todo '\v\_.<(TODO|FIX(ME)?|NOTE|WARN(ING)?|BUG|TBD|XXX|TEST(ING)?)(\([^\)]*\))?:?'hs=s+1 containedin=.*Comment
