let videos = ('~/Videos' | path expand)
let model = ('~/models/ggml-large-v3-turbo-q5_0.bin' | path expand)

let recordings = (
    ls $videos
    | where type == file
    | where name =~ '(?i)\.(mp4|mkv|mov|flv|ts)$'
    | sort-by modified --reverse
)

if ($recordings | is-empty) {
    print $"No supported recordings in ($videos)"
    exit 1
}

let selected = ($recordings | input list --fuzzy --display name 'Choose a recording')
if $selected == null { exit 0 }

let stem = ($selected.name | path parse | get stem)
let output = ($videos | path join $stem)
let wav = $"($output).whisper.wav"

ffmpeg -y -i $selected.name -vn -ar 16000 -ac 1 -c:a pcm_s16le $wav
if $env.LAST_EXIT_CODE != 0 { exit $env.LAST_EXIT_CODE }

whisper-cli -m $model -f $wav -l auto -otxt -osrt -of $output
if $env.LAST_EXIT_CODE != 0 { exit $env.LAST_EXIT_CODE }

rm $wav
print $"Saved ($output).txt and ($output).srt"
