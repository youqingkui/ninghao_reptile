request = require("request")
async   = require("async")
fs      = require("fs")
cheerio = require("cheerio")

reqOp = (url) ->
  options =
    url:url
    headers:
      'User-Agent': 'request',
      'Cookie':''

  return options

op = reqOp("http://ninghao.net/files/styles/cover/public/poster/git-cd.jpg?itok=5l4Q7fp6")

request.get op, (err, res, body) ->
  if err
    return console.log "err"

  fs.writeFile('out.jpg', body, 'binary')
  console.log "ok"

.pipe(fs.createWriteStream('a11123.jpg'))


a = fs.createWriteStream "err.log"

log = (data) ->
  console.log data
  a.write(data)

