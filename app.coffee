request = require("request")
async   = require("async")
fs      = require("fs")
cheerio = require("cheerio")


reqOp = (url) ->
  options =
    url:url
    headers:
      'User-Agent': 'request',
      'Cookie':'SESSeb41eba184e0681dc06c8ef121645e44=ugctmqZ4DmVSPR88qaztetX3TwwE7HNU-kzPz62byhY'

  return options


async.auto
  # 获取课程页面信息
  getPage: (cb) ->
    console.log "获取课程页面信息 start"
    url = "http://ninghao.net/course/1882"
    op  = reqOp(url)
    request.get op, (err, res, body) ->
      if err
        return cb("get page error: #{err}")
      console.log "获取课程页面信息 end"
      cb(null,body)

  # 解析组装课程链接
  analysisBody:["getPage", (cb, result) ->
    console.log "解析组装课程链接  start"
    body = result.getPage
    $ = cheerio.load(body);
    link = $("tr > td a")
    linkLen = link.length
    console.log "find link number #{linkLen}"
    unless linkLen
      return cb("analysisBody no find link")
    href = []
    link.each (idx, element) ->
      href.push($(element).attr("href"))

    unless href.length
      cb("err analysisBody not find link")

    console.log "find link => #{href}"
    console.log "解析组装课程链接 end"
    cb(null, href)

  ]
  # 执行下载总任务
  doTask:["analysisBody", (cb, result) ->
    console.log "执行下载总任务 start"
    hrefArr = result.analysisBody
    task(cb, hrefArr)
  ]
  (err, result) ->
    console.log "iiii.............."
    if err
      return console.log err

    console.log "do all task"



task = (cb ,result) ->
  hrefArr = result
  async.eachSeries hrefArr, (item, callback) ->
    url = "http://ninghao.net" + item
    op  = reqOp(url)
    async.auto
      # 获取下载信息
      getDownInfo:(childCB) ->
        getInfo(childCB, op)

      # 执行下载任务
      downTask:["getDownInfo", (chiidCb, result) ->
        dInfo = result.getDownInfo
        downVideo(chiidCb, dInfo)
      ]
      (errAuto, autoRes) ->
        if errAuto
          console.log errAuto
        callback()

  ,(eachErr, eachRes) ->
    if eachErr
      console.log eachErr

    cb()



getInfo = (cb, option) ->
  console.log "获取下载信息 start"
  op = option
  request.get op, (err, res, body) ->
    if err
      return cb("#{op.url}  get info error:#{err}")

    $ = cheerio.load(body)
    info = {}
    findElent = $("#sidebar section div.box")
    info.url  = findElent.eq(0).find("a").attr("href")
    info.name = findElent.eq(1).find("strong").find("a").text()
    if not info.url && not info.name
      return cb("#{op.url} get info not find info")
    console.log "获取下载信息 end"
    cb(null, info)

downVideo = (cb, result) ->
  console.log "开始下载视频"
  dowInfo = result
  op = reqOp(dowInfo.url)
  write = fs.createWriteStream(dowInfo.name + ".mp4")
  request.get op
  .on "response", (res) ->
    console.log "................................."
    console.log "#{dowInfo.name}  #{dowInfo.url}"
    console.log(res.statusCode)
    console.log(res.headers['content-type'])
    if res.statusCode is 200
      cb()
    console.log "................................"
  .on "error", (err) ->
    "console.log #{dowInfo.name}  #{downInfo.url} down error: #{err}"
    cb()
  .pipe(write)







