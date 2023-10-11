
if test -n (commandline)
    set sgpt_prev_cmd (commandline)
    commandline -a "⌛"
    commandline -f repaint
    commandline (echo "$sgpt_prev_cmd" | sgpt --shell)
    commandline -f end-of-line
end
