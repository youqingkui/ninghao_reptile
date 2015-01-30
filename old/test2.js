/**
 * Created by youqingkui on 15/1/30.
 */
a = "jwplayer("nhplayer").setup({
// 这不是秘密哦 ：）
file: "http://ninghao.net/system/dynamics/video/atom-theme-01-settings-1022812620.mp4",
  image: "http://ninghao.net/files/screenshot/atom-theme-01-settings.jpg",
  skin: "http://ninghao.net/sites/player/skin/ninghao.zip",
  duration: "120.576",
  width: "100%",
  height: "100%",
  modes: [
  { type: "flash", src: "http://ninghao.net/sites/player/player.swf" },
  { type: "html5" },
],
  dock: 'false'
});"

jwplayer = {}

JSON.parse(a)