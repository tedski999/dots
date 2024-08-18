# newsbeuter but better
{ ... }: {
  # TODO(later): newsboat config
  # https://newsboat.org/releases/2.36/docs/newsboat.html#_introduction
  programs.newsboat.enable = true;
  programs.newsboat.reloadTime = 360;
  programs.newsboat.reloadThreads = 32;
  programs.newsboat.extraConfig = ''
    #show-keymap-hint false
    #swap-title-and-hints true
    #notify-always yes
    #notify-program notify-send
    #feed-sort-order lastupdated

    #feedlist-title-format "%u unread feeds - %N %V"
    #articlelist-title-format "%T - %u unread articles"
    #itemview-title-format "%T - %u unread articles"
    #searchresult-title-format "Search results - %u unread"
    #selecttag-title-format "Select tag"
    #selectfilter-title-format "Select filter"
    #urlview-title-format "URLs"
    #dialogs-title-format "Dialogs"

    #notify-format "%d new articles (%n unread articles, %f unread feeds)"
    #feedlist-format "%t"
    #articlelist-format "%D  %?T?|%-17T| ?%t"

    #highlight article  "(^Feed:.*|^Title:.*|^Author:.*)"    color75  default
    #highlight article  "(^Link:.*|^Date:.*)"                color75  default
    #highlight article  "^Podcast Download URL:.*"           color71  default
    #highlight article  "^Links:"                            white    color240 underline
    #highlight article  "\\[[0-9][0-9]*\\]"                  color72  default  bold
    #highlight article  "\\[image [0-9][0-9]*\\]"            color72  default  bold
    #highlight article  "\\[embedded flash: [0-9][0-9]*\\]"  color72  default  bold
    #highlight article  ":.*\\(link\\)$"                     color74  default
    #highlight article  ":.*\\(image\\)$"                    color74  default
    #highlight article  ":.*\\(embedded flash\\)$"           color74  default

    #unbind-key h
    #unbind-key j
    #unbind-key k
    #unbind-key l

    #bind-key h quit
    #bind-key j down
    #bind-key k up
    #bind-key l open
    #bind-key ^U halfpageup
    #bind-key ^D halfpagedown

    #bind-key J next-feed
    #bind-key K prev-feed

    #macro v set browser "notify-send -i 'camera-video' 'Opening video...' '%u' && setsid -f mpv --no-terminal --ytdl-format='bestvideo[height<=?720]+bestaudio/best' '%u'" ; open-in-browser ; set browser "xdg-open '%u'"

    bind-key h quit
    bind-key j down
    bind-key k up
    bind-key l open
    bind-key H prev-feed
    bind-key L next-feed
    bind-key g home
    bind-key G end
    bind-key SPACE macro-prefix
    bind-key b bookmark
    bind-key ^F pagedown
    bind-key ^B pageup
    bind-key ^H toggle-show-read-feeds

  '';

  programs.newsboat.urls = [
    # TODO(later): newsboat urls
    # https://github.com/tedski999/dotfiles/blob/ac7498be315fb3ffc7103af2e40e66563e609c59/.config/newsboat/urls
    { url = "https://news.ycombinator.com/rss"; tags = [ "news" ]; }
    { url = "http://rss.slashdot.org/Slashdot/slashdotMain"; tags = [ "news" ]; }
  ];
}
